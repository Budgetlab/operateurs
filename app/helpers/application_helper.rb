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
    unless date.nil?
      date = date.strftime('%d/%m/%Y')
    end
  end

  def format_nombre(nombre)
    nombre = number_with_delimiter(nombre, precision: 2, significant: true, strip_insignificant_zeros: true, delimiter: ' ')
  end
end
