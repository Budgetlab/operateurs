require "test_helper"

class OrganismesControllerTest < ActionDispatch::IntegrationTest
  test "should get index unauthenticated" do
    sign_out :user
    get organismes_url
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  # --- Operator section display on show page (Story 2.2) ---

  setup do
    @organisme = organismes(:one)
    @mission = missions(:one)
    @programme = programmes(:one)

    @viewer = User.create!(
      email: "viewer@test.com",
      password: "password123",
      statut: "Bureau Sectoriel",
      nom: "Viewer Test"
    )
    sign_in @viewer
  end

  teardown do
    @viewer.destroy
  end

  test "show: displays Opérateur Oui with start year for active operator" do
    @organisme.update!(operateur_actif: true, statut: "valide")
    Operateur.where(organisme: @organisme).destroy_all
    op = Operateur.create!(organisme: @organisme, mission: @mission, programme: @programme,
                           annees: [2022], presence_categorie: false)

    get organisme_url(@organisme)
    assert_response :success
    assert_match "Opérateur : Oui (depuis 2022)", response.body
  end

  test "show: displays Opérateur Non when organism is not an operator" do
    @organisme.update!(operateur_actif: false, statut: "valide")
    Operateur.where(organisme: @organisme).destroy_all

    get organisme_url(@organisme)
    assert_response :success
    assert_match "Opérateur : Non", response.body
  end

  test "show: displays year history for inactive operator with past years" do
    @organisme.update!(operateur_actif: false, statut: "valide")
    Operateur.where(organisme: @organisme).destroy_all
    Operateur.create!(organisme: @organisme, mission: @mission, programme: @programme,
                      annees: [2020, 2021, 2022], presence_categorie: false)

    get organisme_url(@organisme)
    assert_response :success
    assert_match "Opérateur : Non", response.body
    assert_match "2020, 2021, 2022", response.body
  end

  test "show: displays all years via toutes_annees for active operator" do
    @organisme.update!(operateur_actif: true, statut: "valide")
    Operateur.where(organisme: @organisme).destroy_all
    Operateur.create!(organisme: @organisme, mission: @mission, programme: @programme,
                      annees: [Date.today.year], presence_categorie: false)

    get organisme_url(@organisme)
    assert_response :success
    assert_match "Années opérateur", response.body
    assert_match Date.today.year.to_s, response.body
  end

  test "show: displays Opérateur Oui without year when active operator has empty annees" do
    @organisme.update!(operateur_actif: true, statut: "valide")
    Operateur.where(organisme: @organisme).destroy_all
    Operateur.create!(organisme: @organisme, mission: @mission, programme: @programme,
                      annees: [], presence_categorie: false)

    get organisme_url(@organisme)
    assert_response :success
    assert_match "Opérateur : Oui", response.body
    assert_no_match "depuis", response.body
    assert_no_match "Années opérateur", response.body
  end

  test "show: displays Opérateur Non with no year history when no operateur record" do
    @organisme.update!(operateur_actif: false, statut: "valide")
    Operateur.where(organisme: @organisme).destroy_all

    get organisme_url(@organisme)
    assert_response :success
    assert_match "Opérateur : Non", response.body
    assert_no_match "Années opérateur", response.body
  end

  # --- Story 4.1: Organism Index Filtering — operateur_actif ---

  test "index: filter operateur_actif_in=true returns only active operators" do
    actif = Organisme.create!(nom: "Org Actif", statut: "valide", etat: "Actif",
                              operateur_actif: true, controleur: @viewer)
    inactif = Organisme.create!(nom: "Org Inactif", statut: "valide", etat: "Actif",
                                operateur_actif: false, controleur: @viewer)

    get organismes_url, params: { q: { operateur_actif_in: ['true'] } }
    assert_response :success
    assert_match actif.nom, response.body
    assert_no_match inactif.nom, response.body
  ensure
    actif&.destroy
    inactif&.destroy
  end

  test "index: filter operateur_actif_in=false returns only non-operators" do
    actif = Organisme.create!(nom: "Org Actif F41", statut: "valide", etat: "Actif",
                              operateur_actif: true, controleur: @viewer)
    inactif = Organisme.create!(nom: "Org Inactif F41", statut: "valide", etat: "Actif",
                                operateur_actif: false, controleur: @viewer)

    get organismes_url, params: { q: { operateur_actif_in: ['false'] } }
    assert_response :success
    assert_no_match actif.nom, response.body
    assert_match inactif.nom, response.body
  ensure
    actif&.destroy
    inactif&.destroy
  end

  test "index: no longer accepts legacy operateur_operateur_n_null param" do
    get organismes_url, params: { q: { operateur_operateur_n_null: 'true' } }
    assert_response :success
    # No error — param is simply ignored (not permitted)
  end
end
