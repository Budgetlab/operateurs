
Ransack.configure do |c|
  c.custom_arrows = {
    up_arrow: '<span class="fr-icon--sm fr-icon-arrow-down-fill" aria-hidden="true"></span>',
    down_arrow: '<span class="fr-icon--sm fr-icon-arrow-up-fill" aria-hidden="true"></span>',
    default_arrow: '<span class="fr-icon--sm fr-icon-arrow-up-fill" aria-hidden="true"></span><span class="fr-icon--sm fr-icon-arrow-down-fill" aria-hidden="true"></span>'
  }

  c.add_predicate 'contains', # Name your predicate
                  arel_predicate: 'matches',
                  formatter: proc { |s| ActiveSupport::Inflector.transliterate("%#{s}%") }, # Note the %%
                  validator: proc { |s| s.present? },
                  compounds: true,
                  type: :string

  c.add_predicate 'in_insensitive', # Nom de votre prédicat
                  arel_predicate: 'in',
                  formatter: proc { |s| ActiveSupport::Inflector.transliterate(s) }, # Note the %%
                  validator: proc { |s| s.present? },
                  compounds: true,
                  type: :string
end
# c.hide_sort_order_indicators = true
