# frozen_string_literal: true

# Helper Application
module ApplicationHelper
  def format_boolean(string)
    case string
    when nil, ''
      'Non renseigné'
    when true, 'true'
      'Oui'
    when false, 'false'
      'Non'
    else
      string
    end
  end

  def format_texte(string)
    case string
    when nil, ''
      'Aucun'
    when true, 'true'
      'Oui'
    when false, 'false'
      'Non'
    else
      string
    end
  end

  def format_unit(value, unit)
    case value
    when nil, ''
      ''
    else
      unit
    end
  end

  def format_date(date)
    return if date.nil?

    date = date.strftime('%d/%m/%Y')

  end

  def format_nombre(nombre)
    case nombre
    when nil, ''
      'Ø'
    else
      number_with_delimiter('%.11g' % ('%.1f' % nombre), locale: :fr)
    end
  end
  def format_nombre_decimal(nombre)
    case nombre
    when nil, ''
      'Ø'
    else
      number_with_delimiter('%.11g' % ('%.2f' % nombre), locale: :fr)
    end
  end
  def format_nombre_entier(nombre)
    case nombre
    when nil, ''
      'Ø'
    else
      number_with_delimiter('%.11g' % ('%.0f' % nombre), locale: :fr)
    end
  end

  def ratio(a, b, n)
    if !a.nil? && !b.nil? && b != 0
      ((a.to_f/ b.to_f) * n.to_f).round
    else
      nil
    end
  end

  def ratio_excel_percent(a, b, n)
    if !a.nil? && !b.nil? && b != 0
      ((a.to_f/ b.to_f) * n.to_f).round(2) # dans tableau excel on veut 2 décimal pour les pourcentages
    else
      nil
    end
  end

  def render_tag_group(title, param_name, options)
    output = content_tag :div, title, class: 'fr-label fr-text--bold'
    output << content_tag(:ul, class: 'fr-tags-group fr-my-1w') do
      options.map do |val|
        content_tag(:li) do
          content_tag(:button, ' ', class: 'fr-tag', data: { action: 'click->request#checkTag' },
                      'aria-pressed' => (params[:q] && params[:q][param_name].present? && params[:q][param_name].include?(val) ? 'true' : 'false')) do
            content_tag(:label) do
              check_box_tag("q[#{param_name}][]", val, params[:q] && params[:q][param_name].present? && params[:q][param_name].include?(val) ? true : false,
                            { class: 'fr-hidden' }) + format_boolean(val)
            end
          end
        end
      end.join.html_safe
    end
    output
  end

  def render_select_group(title, param_name, options)
    select_group = content_tag :div, class: 'fr-select-group' do
      label = content_tag(:label, title, for: "#{param_name}_list", class: 'fr-label fr-text--bold')
      select = content_tag(:select, class: 'fr-select', id: "#{param_name}_list", data: { tag: "#{param_name}_tag", action: 'change->request#addTagSelected'}) do
        option_tags = content_tag(:option, '- sélectionner -', value: '')
        options.each { |option| option_tags.concat(content_tag(:option, option, value: option)) }
        option_tags
      end
      label.concat(select)
    end
    tags_group = content_tag(:ul, class: 'fr-tags-group', id: "#{param_name}_tag") do
      checkbox_tags = ''.html_safe
      options.each do |option|
        checkbox_tags << check_box_tag("q[#{param_name}][]", option, params[:q] && params[:q][param_name].present? && params[:q][param_name]&.include?(option) ? true : false, {class: "fr-hidden"})
      end
      button_tags = ''.html_safe
      if params[:q] && params[:q][param_name]
        params[:q][param_name].map do |option|
          button_tags << content_tag(:li, data: { action: 'click->request#removeTagSelected', value: option }) do
            content_tag(:button, option, class: 'fr-tag fr-tag--dismiss', aria_label: 'Retirer')
          end
        end
      end
      checkbox_tags.concat(button_tags)
    end
    select_group.concat(tags_group)
  end

  def class_badge(risque_solvabilite)
    case risque_solvabilite
    when 'Situation saine'
      'fr-badge--no-icon fr-badge--success'
    when 'Situation saine a priori mais à surveiller'
      'fr-badge--no-icon fr-badge--green-tilleul-verveine'
    when 'Risque d’insoutenabilité à moyen terme'
      'fr-badge--no-icon fr-badge--warning'
    when 'Risque d’insoutenabilité élevé'
      'fr-badge--no-icon fr-badge--error'
    else
      ''
    end
  end

  def numero_br(chiffre)
    rectificatifs = Chiffre.where(organisme_id: chiffre.organisme_id, exercice_budgetaire: chiffre.exercice_budgetaire, type_budget: "Budget rectificatif").order(:created_at)
    rectificatifs.index(chiffre)+1
  end

  # Custom Pagy navigation compatible avec le DSFR (Système de Design de l'État français)
  def pagy_nav_custom(pagy, **opts)
    return '' unless pagy.pages > 1

    html = +%(<nav role="navigation" class="fr-pagination" aria-label="Pagination">)
    html << %(<ul class="fr-pagination__list">)

    # Bouton Première page
    if pagy.previous
      html << %(<li><a class="fr-pagination__link fr-pagination__link--first" href="#{pagy.page_url(:first, **opts)}" aria-label="Première page">Première page</a></li>)
    end

    # Bouton Page précédente
    if pagy.previous
      html << %(<li><a class="fr-pagination__link fr-pagination__link--prev fr-pagination__link--lg-label" href="#{pagy.page_url(:previous, **opts)}" aria-label="Page précédente">Page précédente</a></li>)
    end

    # Pages numérotées - génération manuelle de la série
    series = pagy_series(pagy, **opts)
    series.each do |item|
      case item
      when Integer
        if item == pagy.page
          html << %(<li><a class="fr-pagination__link" aria-current="page" title="Page #{item}">#{item}</a></li>)
        else
          html << %(<li><a class="fr-pagination__link" href="#{pagy.page_url(item, **opts)}" title="Page #{item}">#{item}</a></li>)
        end
      when String
        html << %(<li><a class="fr-pagination__link" aria-current="page" title="Page #{item}">#{item}</a></li>)
      when :gap
        html << %(<li><a class="fr-pagination__link">...</a></li>)
      end
    end

    # Bouton Page suivante
    if pagy.next
      html << %(<li><a class="fr-pagination__link fr-pagination__link--next fr-pagination__link--lg-label" href="#{pagy.page_url(:next, **opts)}" aria-label="Page suivante">Page suivante</a></li>)
    end

    # Bouton Dernière page
    if pagy.next
      html << %(<li><a class="fr-pagination__link fr-pagination__link--last" href="#{pagy.page_url(:last, **opts)}" aria-label="Dernière page">Dernière page</a></li>)
    end

    html << %(</ul>)
    html << %(</nav>)
    html.html_safe
  end

  # Helper pour générer la série de pages
  def pagy_series(pagy, slots: 7, **opts)
    return [] if pagy.pages <= 1

    series = []

    if slots >= pagy.pages
      series.push(*1..pagy.pages)
    else
      half = (slots - 1) / 2
      start = if pagy.page <= half
                1
              elsif pagy.page > (pagy.pages - slots + half)
                pagy.pages - slots + 1
              else
                pagy.page - half
              end
      series.push(*(start...(start + slots)))

      # Ajouter les gaps et première/dernière page
      unless slots < 7
        series[0] = 1
        series[1] = :gap unless series[1] == 2
        series[-2] = :gap unless series[-2] == pagy.pages - 1
        series[-1] = pagy.pages
      end
    end

    # Convertir la page courante en String
    current = series.index(pagy.page)
    series[current] = pagy.page.to_s if current

    series
  end

end
