# frozen_string_literal: true

# Helper Application
module ApplicationHelper
  def format_boolean(string)
    case string
    when nil, ''
      'Non renseigné'
    when true
      'Oui'
    when false
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
end
