# frozen_string_literal: true

# Helper Application
module ApplicationHelper
  include Pagy::Frontend
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

  def format_date(date)
    return if date.nil?

    date = date.strftime('%d/%m/%Y')

  end

  def format_nombre(nombre)
    case nombre
    when nil, ''
      '-'
    else
      number_with_delimiter('%.11g' % ('%.1f' % nombre), locale: :fr)
    end
  end
  def format_nombre_decimal(nombre)
    case nombre
    when nil, ''
      '-'
    else
      number_with_delimiter('%.11g' % ('%.2f' % nombre), locale: :fr)
    end
  end
  def format_nombre_entier(nombre)
    case nombre
    when nil, ''
      '-'
    else
      number_with_delimiter('%.11g' % ('%.0f' % nombre), locale: :fr)
    end
  end

  def ratio(a, b, n)
    if !a.nil? && !b.nil? && b != 0
      (a / b) * n
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
    rectificatifs = Chiffre.where(exercice_budgetaire: chiffre.exercice_budgetaire, type_budget: "Budget rectificatif").order(:created_at)
    rectificatifs.index(chiffre)
  end

end
