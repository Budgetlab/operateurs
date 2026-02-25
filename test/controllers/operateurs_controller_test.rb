require "test_helper"

class OperateursControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organisme = organismes(:one)
    @operateur = operateurs(:one)
    @mission = missions(:one)
    @programme = programmes(:one)

    # Admin user with statut '2B2O' required by authenticate_admin!
    @admin = User.create!(
      email: "admin2b2o@test.com",
      password: "password123",
      statut: "2B2O",
      nom: "Admin Test"
    )
    sign_in @admin
  end

  teardown do
    @admin.destroy
  end

  # --- create ---

  test "create: saves operator and calls activer! when operateur_actif is true with annee_debut" do
    new_org = organismes(:two)
    # Ensure no operateur exists for this organisme
    Operateur.where(organisme: new_org).destroy_all

    assert_difference("Operateur.count", 1) do
      post operateurs_url, params: {
        operateur: {
          organisme_id: new_org.id,
          operateur_actif: "true",
          annee_debut: "2026",
          presence_categorie: "false",
          mission_id: @mission.id,
          programme_id: @programme.id
        }
      }
    end

    op = Operateur.find_by(organisme: new_org)
    assert_not_nil op
    assert_includes op.annees, 2026
    assert new_org.reload.operateur_actif
    assert_redirected_to organisme_path(new_org)
  end

  test "create: does not save when operateur_actif is false" do
    new_org = organismes(:two)
    Operateur.where(organisme: new_org).destroy_all

    assert_no_difference("Operateur.count") do
      post operateurs_url, params: {
        operateur: {
          organisme_id: new_org.id,
          operateur_actif: "false",
          annee_debut: "",
          presence_categorie: "false",
          mission_id: @mission.id,
          programme_id: @programme.id
        }
      }
    end

    assert_redirected_to organisme_path(new_org)
  end

  test "create: does not save when operateur_actif is true but annee_debut is missing" do
    new_org = organismes(:two)
    Operateur.where(organisme: new_org).destroy_all

    assert_no_difference("Operateur.count") do
      post operateurs_url, params: {
        operateur: {
          organisme_id: new_org.id,
          operateur_actif: "true",
          annee_debut: "",
          presence_categorie: "false",
          mission_id: @mission.id,
          programme_id: @programme.id
        }
      }
    end
  end

  test "create: links programmes when operateur is saved" do
    new_org = organismes(:two)
    Operateur.where(organisme: new_org).destroy_all

    post operateurs_url, params: {
      operateur: {
        organisme_id: new_org.id,
        operateur_actif: "true",
        annee_debut: "2026",
        presence_categorie: "false",
        mission_id: @mission.id,
        programme_id: @programme.id,
        programmes: [@programme.id.to_s]
      }
    }

    op = Operateur.find_by(organisme: new_org)
    assert_not_nil op
    assert_includes op.operateur_programmes.pluck(:programme_id), @programme.id
  end

  test "create: does not crash when operateur_actif is false and programmes present" do
    new_org = organismes(:two)
    Operateur.where(organisme: new_org).destroy_all

    assert_nothing_raised do
      post operateurs_url, params: {
        operateur: {
          organisme_id: new_org.id,
          operateur_actif: "false",
          annee_debut: "",
          presence_categorie: "false",
          mission_id: @mission.id,
          programme_id: @programme.id,
          programmes: [@programme.id.to_s]
        }
      }
    end

    assert_redirected_to organisme_path(new_org)
  end

  # --- update ---

  test "update: calls desactiver! when operateur_actif is false" do
    @organisme.update!(operateur_actif: true)
    @operateur.update!(annees: [2024])

    patch operateur_url(@operateur), params: {
      operateur: {
        organisme_id: @organisme.id,
        operateur_actif: "false",
        presence_categorie: "false",
        mission_id: @mission.id,
        programme_id: @programme.id
      }
    }

    @organisme.reload
    @operateur.reload
    refute @organisme.operateur_actif
    assert_redirected_to organisme_path(@organisme)
  end

  test "update: calls activer! when operateur_actif is true and annee_debut present" do
    @organisme.update!(operateur_actif: false)
    @operateur.update!(annees: [])

    patch operateur_url(@operateur), params: {
      operateur: {
        organisme_id: @organisme.id,
        operateur_actif: "true",
        annee_debut: "2025",
        presence_categorie: "false",
        mission_id: @mission.id,
        programme_id: @programme.id
      }
    }

    @operateur.reload
    @organisme.reload
    assert_includes @operateur.annees, 2025
    assert @organisme.operateur_actif
    assert_redirected_to organisme_path(@organisme)
  end

  test "update: does not call activer! when operateur_actif is true but annee_debut missing" do
    original_annees = @operateur.annees.dup

    patch operateur_url(@operateur), params: {
      operateur: {
        organisme_id: @organisme.id,
        operateur_actif: "true",
        annee_debut: "",
        presence_categorie: "false",
        mission_id: @mission.id,
        programme_id: @programme.id
      }
    }

    @operateur.reload
    assert_equal original_annees, @operateur.annees
    assert_redirected_to organisme_path(@organisme)
  end

  # --- index ---

  test "index: renders table with operateurs" do
    @organisme.update!(operateur_actif: true)
    @operateur.update!(annees: [2024])

    get operateurs_url
    assert_response :success
    assert_select "table"
    assert_select "td", text: /#{@organisme.nom}/
  end

  test "index: shows Rendre inactif button for active operator" do
    @organisme.update!(operateur_actif: true)
    @operateur.update!(annees: [2024])

    get operateurs_url
    assert_response :success
    assert_select "button", text: /Rendre inactif/
  end

  test "index: does not show Rendre inactif button for inactive operator" do
    @organisme.update!(operateur_actif: false)
    @operateur.update!(annees: [2022, 2023])

    get operateurs_url
    assert_response :success
    assert_select "button", text: /Rendre inactif/, count: 0
  end

  # --- deactivate ---

  test "deactivate: calls desactiver! and redirects with flash" do
    @organisme.update!(operateur_actif: true)
    @operateur.update!(annees: [2024])

    patch deactivate_operateur_url(@operateur), params: { annee_fin: "2025" }

    @organisme.reload
    @operateur.reload
    refute @organisme.operateur_actif
    assert_includes @operateur.annees, 2025
    assert_redirected_to operateurs_path
    assert_equal "#{@organisme.nom} est maintenant inactif.", flash[:notice]
  end

  test "deactivate: rejects invalid annee_fin and redirects with alert" do
    @organisme.update!(operateur_actif: true)
    @operateur.update!(annees: [2024])

    patch deactivate_operateur_url(@operateur), params: { annee_fin: "" }

    @organisme.reload
    assert @organisme.operateur_actif, "Operator should still be active"
    assert_redirected_to operateurs_path
    assert_equal "Année invalide.", flash[:alert]
  end

  test "deactivate: requires authentication" do
    sign_out @admin
    patch deactivate_operateur_url(@operateur), params: { annee_fin: "2025" }
    assert_redirected_to new_user_session_path
  end

  # --- unauthenticated ---

  test "redirects to login when not authenticated" do
    sign_out @admin
    get new_operateur_url(organisme_id: @organisme.id)
    assert_redirected_to new_user_session_path
  end
end
