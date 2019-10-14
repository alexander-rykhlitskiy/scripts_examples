require 'nokogiri'

doc = Nokogiri::HTML(File.read('Takeout/YouTube/история/история-просмотров.html'));
videos = doc.css('.content-cell:contains("Просмотрено видео")')

p videos.group_by { |v| v.at_css('a').text }.transform_values(&:count).sort_by(&:last).reverse
