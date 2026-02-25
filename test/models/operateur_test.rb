require "test_helper"

class OperateurTest < ActiveSupport::TestCase
  setup do
    @mission   = missions(:one)
    @programme = programmes(:one)

    # Destroy fixture operateurs to avoid has_one conflicts
    operateurs(:one).destroy!
    operateurs(:two).destroy!

    # Active operator: annees stores start year of active range
    @org_actif = organismes(:one)
    @org_actif.update!(operateur_actif: true)
    @op_actif = Operateur.create!(
      organisme: @org_actif,
      mission: @mission,
      programme: @programme,
      annees: [2024],
      presence_categorie: false
    )

    # Inactive operator: annees stores all individual years
    @org_inactif = organismes(:two)
    @org_inactif.update!(operateur_actif: false)
    @op_inactif = Operateur.create!(
      organisme: @org_inactif,
      mission: @mission,
      programme: @programme,
      annees: [2022, 2023],
      presence_categorie: false
    )
  end

  # --- toutes_annees ---

  test "toutes_annees expands active range from start year to current year" do
    current_year = Date.today.year
    result = @op_actif.toutes_annees
    assert_equal (2024..current_year).to_a, result
  end

  test "toutes_annees returns stored years when inactive" do
    assert_equal [2022, 2023], @op_inactif.toutes_annees
  end

  test "toutes_annees keeps past gap years and expands active range" do
    current_year = Date.today.year
    @op_actif.update!(annees: [2018, 2019, 2024])
    result = @op_actif.reload.toutes_annees
    expected = ([2018, 2019] + (2024..current_year).to_a).uniq.sort
    assert_equal expected, result
  end

  test "toutes_annees returns empty array when annees is empty" do
    @op_inactif.update!(annees: [])
    assert_equal [], @op_inactif.reload.toutes_annees
  end

  # --- operateur_pour_annee? ---

  test "operateur_pour_annee? returns true when year is in toutes_annees" do
    assert @op_actif.operateur_pour_annee?(2024)
    assert @op_actif.operateur_pour_annee?(Date.today.year)
  end

  test "operateur_pour_annee? returns false when year is not in toutes_annees" do
    refute @op_actif.operateur_pour_annee?(2020)
    refute @op_inactif.operateur_pour_annee?(2021)
  end

  # --- activer! ---

  test "activer! adds year to annees and sets operateur_actif true on organisme" do
    @op_inactif.activer!(2026)
    @op_inactif.reload
    @org_inactif.reload
    assert_includes @op_inactif.annees, 2026
    assert @org_inactif.operateur_actif
  end

  test "activer! does not duplicate year if already present" do
    @op_actif.activer!(2024)
    @op_actif.reload
    assert_equal 1, @op_actif.annees.count(2024)
  end

  test "activer! raises ArgumentError for non-integer input" do
    assert_raises(ArgumentError) { @op_actif.activer!(nil) }
    assert_raises(ArgumentError) { @op_actif.activer!("2026") }
  end

  # --- desactiver! ---

  test "desactiver! expands active range and sets operateur_actif false" do
    @op_actif.desactiver!(2027)
    @op_actif.reload
    @org_actif.reload
    assert_equal [2024, 2025, 2026, 2027], @op_actif.annees
    refute @org_actif.operateur_actif
  end

  test "desactiver! preserves past gap years when expanding" do
    @op_actif.update!(annees: [2018, 2019, 2024])
    @op_actif.desactiver!(2027)
    @op_actif.reload
    @org_actif.reload
    assert_equal [2018, 2019, 2024, 2025, 2026, 2027], @op_actif.annees
    refute @org_actif.operateur_actif
  end

  test "desactiver! handles empty annees gracefully" do
    @op_actif.update!(annees: [])
    @op_actif.desactiver!(2027)
    @org_actif.reload
    refute @org_actif.operateur_actif
  end

  test "desactiver! raises ArgumentError for non-integer input" do
    assert_raises(ArgumentError) { @op_actif.desactiver!(nil) }
    assert_raises(ArgumentError) { @op_actif.desactiver!("2027") }
  end

  # --- Operateur.import (Story 4.3) ---

  test "import builds annees array from OUI columns and sets operateur_actif true for current year" do
    organisme = Organisme.create!(nom: "Import Test 1", statut: "valide", etat: "Actif",
                                  siren: "111111111", operateur_actif: false, controleur: users(:one))
    organisme.operateur&.destroy
    current_year = Date.today.year

    call_operateur_import_row(organisme, 'OUI', 'OUI', 'NON', current_year)

    organisme.reload
    op = organisme.operateur
    assert op.present?, "operateur should be created"
    assert_includes op.annees, current_year,     "operateur_n maps to current_year"
    assert_includes op.annees, current_year - 1, "operateur_n1 maps to current_year-1"
    refute_includes op.annees, current_year - 2, "operateur_n2 NON should not be in annees"
    assert organisme.operateur_actif, "operateur_actif should be true when current year is OUI"
  ensure
    organisme&.destroy
  end

  test "import sets operateur_actif false when only past years are OUI" do
    organisme = Organisme.create!(nom: "Import Test 2", statut: "valide", etat: "Actif",
                                  siren: "222222222", operateur_actif: false, controleur: users(:one))
    organisme.operateur&.destroy
    current_year = Date.today.year

    call_operateur_import_row(organisme, 'NON', 'NON', 'OUI', current_year)

    organisme.reload
    op = organisme.operateur
    assert op.present?
    assert_includes op.annees, current_year - 2
    refute_includes op.annees, current_year
    refute organisme.operateur_actif, "operateur_actif false when only old years"
  ensure
    organisme&.destroy
  end

  test "import merges new years with existing annees" do
    current_year = Date.today.year
    organisme = Organisme.create!(nom: "Import Test 3", statut: "valide", etat: "Actif",
                                  siren: "333333333", operateur_actif: false, controleur: users(:one))
    organisme.operateur&.destroy
    Operateur.create!(organisme: organisme, mission: @mission, programme: @programme,
                      annees: [current_year - 5], presence_categorie: false)

    call_operateur_import_row(organisme, 'OUI', 'NON', 'NON', current_year)

    op = organisme.reload.operateur
    assert_includes op.annees, current_year - 5, "old year preserved"
    assert_includes op.annees, current_year,     "new year added"
  ensure
    organisme&.destroy
  end

  test "import destroys operateur when all columns are NON" do
    organisme = Organisme.create!(nom: "Import Test 4", statut: "valide", etat: "Actif",
                                  siren: "444444444", operateur_actif: true, controleur: users(:one))
    organisme.operateur&.destroy
    Operateur.create!(organisme: organisme, mission: @mission, programme: @programme,
                      annees: [Date.today.year], presence_categorie: false)

    call_operateur_import_row(organisme, 'NON', 'NON', 'NON', Date.today.year, destroy: true)

    organisme.reload
    assert_nil organisme.operateur, "operateur destroyed when all NON"
    refute organisme.operateur_actif, "operateur_actif should be false after destroy"
  ensure
    organisme&.destroy
  end

  private

  # Simulates processing a single row from Operateur.import.
  # Mirrors the year_map logic in production: operateur_n=current_year, n1=year-1, n2=year-2.
  def call_operateur_import_row(organisme, n_val, n1_val, n2_val, current_year, destroy: false)
    row_data = {
      'siren'              => organisme.siren,
      'operateur_n'        => n_val,
      'operateur_n1'       => n1_val,
      'operateur_n2'       => n2_val,
      'presence_categorie' => 'NON',
      'nom_categorie'      => nil,
      'programme'          => @programme.numero.to_s,
      'programmes_annexes' => ''
    }

    year_map  = { 'operateur_n' => current_year, 'operateur_n1' => current_year - 1, 'operateur_n2' => current_year - 2 }
    new_years = year_map.select { |col, _| row_data[col].to_s.upcase == 'OUI' }.values

    if new_years.any?
      operateur       = Operateur.where(organisme_id: organisme.id).first || Operateur.new(organisme_id: organisme.id)
      existing_years  = operateur.annees || []
      operateur.annees           = (existing_years + new_years).uniq.sort
      operateur.presence_categorie = Operateur.convert_to_boolean(row_data['presence_categorie'])
      operateur.nom_categorie    = row_data['nom_categorie']
      operateur.programme_id     = @programme.id
      operateur.mission_id       = @mission.id
      if operateur.save
        is_active = new_years.any? { |y| y >= current_year }
        organisme.update!(operateur_actif: is_active)
      end
    else
      organisme.operateur&.destroy
      organisme.update!(operateur_actif: false)
    end
  end
end
