# Optionally override some pagy default with your own in the pagy initializer
Pagy::DEFAULT[:items] = 5 # items per page
Pagy::DEFAULT[:size]  = [1, 2, 2, 1] # nav bar links
Pagy::DEFAULT[:page_param] = :p
# Better user experience handled automatically
require 'pagy/extras/custom'
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page
Pagy::DEFAULT.freeze