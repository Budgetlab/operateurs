require 'application_system_test_case'

class DeviseAuthSystemTest < ApplicationSystemTestCase
  test 'sign in user' do
    user = User.create(email: 'user@finances.gouv.fr', password: 'Budgetlab', statut: '2B2O', nom: '2B2O')
    puts User.all.inspect
    visit root_path
    select '2B2O', from: 'user[statut]'
    fill_in 'user[password]', with: 'Budgetlab'
    click_button 'Connexion'
    assert_current_path root_path
  end
end
