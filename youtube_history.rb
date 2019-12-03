require 'nokogiri'

HISTORY_HTML_FILE_NAME = ARGV[0]

doc = Nokogiri::HTML(File.read(HISTORY_HTML_FILE_NAME));
videos = doc.css('.content-cell:contains("Watched")')

vs = videos.group_by { |v| v.at_css('a')&.text }.sort_by { |v| v.last.count }.reverse
