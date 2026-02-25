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
end
