class AddTresorerieToChiffres < ActiveRecord::Migration[7.0]
  def change
    add_column :chiffres, :tresorerie_finale_flechee, :float
    add_column :chiffres, :tresorerie_finale_non_flechee, :float
    add_column :chiffres, :tresorerie_finale, :float
    add_column :chiffres, :tresorerie_variation, :float
    add_column :chiffres, :tresorerie_variation_flechee, :float
    add_column :chiffres, :tresorerie_variation_non_flechee, :float
    add_column :chiffres, :tresorerie_min, :float
    add_column :chiffres, :tresorerie_max, :float
    add_column :chiffres, :tresorerie_min_date, :date
    add_column :chiffres, :tresorerie_max_date, :date
  end
end
