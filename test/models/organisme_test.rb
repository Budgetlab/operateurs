require "test_helper"

class OrganismeTest < ActiveSupport::TestCase
  test "ransackable_attributes includes operateur_actif" do
    assert_includes Organisme.ransackable_attributes, "operateur_actif"
  end

  # Import logic tests simulate row processing with the same dynamic year extraction
  # used in production (grep /Opérateur \d{4}/ on row_data keys).

  test "import builds annees array from OUI year columns and sets operateur_actif true for current year" do
    organisme = organismes(:one)
    programme = programmes(:one)

    organisme.operateur&.destroy

    current_year = Date.today.year
    next_year    = current_year + 1

    row_data = {
      'Programme chef file' => programme.numero.to_s,
      "Opérateur #{next_year}"    => 'Oui',
      "Opérateur #{current_year}" => 'Oui',
      "Opérateur #{current_year - 1}" => 'Non',
      "Opérateur #{current_year - 2}" => 'Non',
      'Appartenance catégorie opérateurs' => 'Non',
      'Nom catégorie' => nil,
      'Autres Programmes financeurs' => '[]'
    }

    call_import_row(organisme, row_data, current_year: current_year)

    organisme.reload
    op = organisme.operateur
    assert op.present?, "operateur should be created"
    assert_includes op.annees, next_year
    assert_includes op.annees, current_year
    refute_includes op.annees, current_year - 1
    assert organisme.operateur_actif, "operateur_actif should be true when a current/future year is OUI"
  end

  test "import sets operateur_actif false when only past years are OUI" do
    organisme = organismes(:two)
    programme = programmes(:two)

    organisme.operateur&.destroy

    current_year = Date.today.year

    row_data = {
      'Programme chef file' => programme.numero.to_s,
      "Opérateur #{current_year + 1}" => 'Non',
      "Opérateur #{current_year}"     => 'Non',
      "Opérateur #{current_year - 1}" => 'Oui',
      "Opérateur #{current_year - 2}" => 'Oui',
      'Appartenance catégorie opérateurs' => 'Non',
      'Nom catégorie' => nil,
      'Autres Programmes financeurs' => '[]'
    }

    call_import_row(organisme, row_data, current_year: current_year)

    organisme.reload
    op = organisme.operateur
    assert op.present?
    assert_includes op.annees, current_year - 1
    assert_includes op.annees, current_year - 2
    refute organisme.operateur_actif, "operateur_actif should be false when only past years are OUI"
  end

  test "import merges new years with existing annees without overwriting history" do
    organisme = organismes(:one)
    programme = programmes(:one)

    organisme.operateur&.destroy
    current_year = Date.today.year
    op = Operateur.create!(
      organisme: organisme,
      mission: missions(:one),
      programme: programme,
      annees: [current_year - 5, current_year - 4],
      presence_categorie: false
    )

    row_data = {
      'Programme chef file' => programme.numero.to_s,
      "Opérateur #{current_year + 1}" => 'Oui',
      "Opérateur #{current_year}"     => 'Non',
      "Opérateur #{current_year - 1}" => 'Non',
      "Opérateur #{current_year - 2}" => 'Non',
      'Appartenance catégorie opérateurs' => 'Non',
      'Nom catégorie' => nil,
      'Autres Programmes financeurs' => '[]'
    }

    call_import_row(organisme, row_data, current_year: current_year)

    op.reload
    assert_includes op.annees, current_year - 5, "existing old year should be preserved"
    assert_includes op.annees, current_year - 4, "existing old year should be preserved"
    assert_includes op.annees, current_year + 1, "new future year should be added"
  end

  test "import destroys operateur when Programme chef file is N/A" do
    organisme = organismes(:one)
    organisme.operateur&.destroy
    Operateur.create!(
      organisme: organisme,
      mission: missions(:one),
      programme: programmes(:one),
      annees: [2024],
      presence_categorie: false
    )
    assert organisme.reload.operateur.present?

    row_data = { 'Programme chef file' => 'N/A' }
    call_import_row(organisme, row_data)

    assert_nil organisme.reload.operateur, "operateur should be destroyed when Programme chef file is N/A"
  end

  # --- desactiver_operateur_si_inactif callback ---

  test "passing etat to Inactif desactivates operator using date_dissolution year" do
    organisme = organismes(:one)
    organisme.operateur&.destroy
    op = Operateur.create!(organisme: organisme, mission: missions(:one), programme: programmes(:one),
                           annees: [2023], presence_categorie: false)
    organisme.update!(operateur_actif: true, date_dissolution: Date.new(2024, 6, 1))

    organisme.update!(etat: 'Inactif')

    organisme.reload
    op.reload
    refute organisme.operateur_actif
    assert_equal (2023..2024).to_a, op.annees
  end

  test "passing etat to Inactif desactivates operator using current year when no date_dissolution" do
    organisme = organismes(:one)
    organisme.operateur&.destroy
    op = Operateur.create!(organisme: organisme, mission: missions(:one), programme: programmes(:one),
                           annees: [2023], presence_categorie: false)
    organisme.update!(operateur_actif: true, date_dissolution: nil)

    organisme.update!(etat: 'Inactif')

    organisme.reload
    op.reload
    refute organisme.operateur_actif
    assert_includes op.annees, Date.today.year
  end

  test "changing etat to non-Inactif does not touch operator" do
    organisme = organismes(:one)
    organisme.operateur&.destroy
    op = Operateur.create!(organisme: organisme, mission: missions(:one), programme: programmes(:one),
                           annees: [2024], presence_categorie: false)
    organisme.update!(operateur_actif: true, etat: 'Actif')

    organisme.update!(etat: 'En cours de dissolution')

    organisme.reload
    op.reload
    assert organisme.operateur_actif
    assert_equal [2024], op.annees
  end

  test "passing etat to Inactif does nothing when no operator exists" do
    organisme = organismes(:one)
    organisme.operateur&.destroy
    organisme.update!(operateur_actif: false)

    assert_nothing_raised { organisme.update!(etat: 'Inactif') }
    refute organisme.reload.operateur_actif
  end

  private

  # Simulates processing a single row from the Organisme import spreadsheet.
  # Uses the same dynamic year extraction as production code (grep /Opérateur \d{4}/).
  def call_import_row(organisme, row_data, current_year: Date.today.year)
    if row_data['Programme chef file'] == 'N/A'
      organisme.operateur&.destroy
      return
    end

    operateur = Operateur.find_or_initialize_by(organisme_id: organisme.id)
    programme_id = Programme.find_by(numero: row_data['Programme chef file'].to_i)&.id if row_data['Programme chef file']
    mission_id   = Mission.where(programme_id: programme_id).first&.id if programme_id

    # Dynamic year extraction — mirrors production Organisme.import logic
    year_columns = row_data.keys
                           .grep(/\AOpérateur \d{4}\z/)
                           .each_with_object({}) { |col, h| h[col] = col[/\d{4}/].to_i }

    new_years = year_columns.select { |col, _| Organisme.convert_to_boolean(row_data[col]) == true }.values
    existing_years = operateur.annees || []
    merged_years = (existing_years + new_years).uniq.sort
    is_active = new_years.any? { |y| y >= current_year }

    operateur.assign_attributes(
      annees: merged_years,
      presence_categorie: Organisme.convert_to_boolean(row_data['Appartenance catégorie opérateurs']),
      nom_categorie: row_data['Nom catégorie'],
      programme_id: programme_id,
      mission_id: mission_id
    )
    if operateur.changed? || operateur.new_record?
      if operateur.save
        organisme.update!(operateur_actif: is_active)
      end
    else
      organisme.update!(operateur_actif: is_active)
    end
  end
end
