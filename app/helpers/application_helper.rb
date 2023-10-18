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
  def format_nombre_entier(nombre)
    case nombre
    when nil, ''
      '-'
    else
      number_with_delimiter('%.11g' % ('%.0f' % nombre), locale: :fr)
    end
  end
end
