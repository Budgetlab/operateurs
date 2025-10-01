class ChiffresYearsService
  def self.range(start_year = 2019)
    today  = Time.zone ? Time.zone.today : Date.today
    cutoff = Date.new(today.year, 9, 1)
    end_year = today < cutoff ? today.year : today.year + 1
    (start_year..end_year)
  end
end