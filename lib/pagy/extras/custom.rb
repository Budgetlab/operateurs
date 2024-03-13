# lib/pagy/extras/custom.rb

require 'pagy/frontend'

class Pagy
  module Frontend

    def pagy_nav_custom(pagy, link_extra: '')

      html = %(<nav role="navigation" class="fr-pagination" aria-label="Pagination"><ul class="fr-pagination__list">)
      pagy.series.each do |item|
        html.concat case item
                    when Integer
                      link = pagy_link_proc(pagy, link_extra: item == pagy.page ? 'class="fr-pagination__link" aria-current="page"' : 'class="fr-pagination__link"')
                      %(<li>#{link.call item}</li>)
                    when String
                      link = pagy_link_proc(pagy, link_extra: item == pagy.page ? 'class="fr-pagination__link" aria-current="page"' : 'class="fr-pagination__link"')
                      %(<li>#{link.call item}</li>)
                    when :prev
                      link = pagy_link_proc(pagy, link_extra: 'class="fr-pagination__link"')
                      if pagy.prev
                        %(<li>#{link.call pagy.prev}</li>)
                      else
                        %(<li><a role="link" aria-disabled="true" class="fr-pagination__link" aria-label="Previous"></a></li>)
                      end
                    when :next
                      link = pagy_link_proc(pagy, link_extra: 'class="fr-pagination__link"')
                      if pagy.next
                        %(<li>#{link.call pagy.next}</li>)
                      else
                        %(<li><a role="link" aria-disabled="true" class="fr-pagination__link" aria-label="Next"></a></li>)
                        end
                    else %(<li></li>)
                    end
      end
      html << %(</ul></nav>)
    end
  end
end