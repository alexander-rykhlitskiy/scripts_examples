require 'nokogiri'
require 'date'

def fetch_html_for(day)
  file = "examples/#{day.month}_#{day.day}.html"

  unless File.exist?(file)
    url = "https://www.hockey-reference.com/friv/birthdays.cgi?month=#{day.month}&day=#{day.day}"
    `wget "#{url}" -O #{file}`
  end
  File.read(file)
end

result = {}
((Date.parse('01-01-2018')..Date.parse('01-03-2018')).to_a +
(Date.parse('01-10-2018')..Date.parse('31-12-2018')).to_a).each do |day|
  # (Date.parse('01-01-2018')..Date.parse('31-01-2018')).to_a.each do |day|
  # Thread.new do
  puts day
  result[day] = Nokogiri::HTML(fetch_html_for(day)).at_css('.section_heading h2').text.to_i
  # end
end

p result.group_by { |day, count| day.month }.transform_values { |days| days.sum(&:last).to_f / days.count }
