Ransack.configure do |c|
  Ransack.configure do |c|
    c.custom_arrows = {
      up_arrow: '<span class="fr-icon--sm fr-icon-arrow-down-fill" aria-hidden="true"></span>',
      down_arrow: '<span class="fr-icon--sm fr-icon-arrow-up-fill" aria-hidden="true"></span>',
      default_arrow: '<span class="fr-icon--sm fr-icon-arrow-down-fill" aria-hidden="true"></span>'
    }
  end
  # c.hide_sort_order_indicators = true
end