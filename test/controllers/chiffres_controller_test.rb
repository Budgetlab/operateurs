require "test_helper"

class ChiffresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organisme = organismes(:one)
    @mission = missions(:one)
    @programme = programmes(:one)

    @controleur = User.create!(
      email: "ctrl_chiffres@test.com",
      password: "password123",
      statut: "Controleur",
      nom: "Ctrl Chiffres"
    )
    sign_in @controleur
  end

  teardown do
    @controleur.destroy
  end

  # --- Story 4.2: select_exercice uses operateur_pour_annee? ---

  test "select_exercice: returns operateur true when organism is operator for given year" do
    @organisme.update!(operateur_actif: true)
    Operateur.where(organisme: @organisme).destroy_all
    Operateur.create!(organisme: @organisme, mission: @mission, programme: @programme,
                      annees: [Date.today.year], presence_categorie: false)

    post select_exercice_url, params: { organisme: @organisme.id, exercice: Date.today.year }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json['operateur']
  end

  test "select_exercice: returns operateur false when organism is not operator for given year" do
    @organisme.update!(operateur_actif: false)
    Operateur.where(organisme: @organisme).destroy_all
    Operateur.create!(organisme: @organisme, mission: @mission, programme: @programme,
                      annees: [Date.today.year - 3], presence_categorie: false)

    post select_exercice_url, params: { organisme: @organisme.id, exercice: Date.today.year }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json['operateur']
  end

  test "select_exercice: returns operateur false when organisme has no operateur record" do
    Operateur.where(organisme: @organisme).destroy_all

    post select_exercice_url, params: { organisme: @organisme.id, exercice: Date.today.year }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json['operateur']
  end

  test "select_exercice: works for past years outside old hardcoded range (e.g. year-5)" do
    @organisme.update!(operateur_actif: false)
    Operateur.where(organisme: @organisme).destroy_all
    Operateur.create!(organisme: @organisme, mission: @mission, programme: @programme,
                      annees: [Date.today.year - 5], presence_categorie: false)

    post select_exercice_url, params: { organisme: @organisme.id, exercice: Date.today.year - 5 }
    assert_response :success
    json = JSON.parse(response.body)
    # old case/when only handled year-2..year+1; operateur_pour_annee? handles any year
    assert_equal true, json['operateur']
  end
end
