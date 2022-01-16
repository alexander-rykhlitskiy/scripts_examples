require 'nokogiri'

csv = File.read(ARGV[0]).split("\n").map do |row|
  row.gsub!(/<a.*?>(.*?)<\/a>/, '\1')
  row.gsub!('[anki:play:a:0]', '')
  row.gsub!('&nbsp;', ' ')
  cells = row.split(/\t/)
  cell0 = cells[1].scan(/<b>(.*?)<\/b>/).map(&:first).map(&:strip).join(', ')
  cell0 = cells[1] if cell0.nil? || cell0.empty?
  cell0 = Nokogiri::HTML(cell0).text.strip
  cell0.gsub!(/[А-Яа-я]+/, '')
  cells.prepend(cell0)
  cells.join("\t")
end.sort.join("\n")

File.write(ARGV[1], csv)
