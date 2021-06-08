require 'open-uri'
require 'uri'
require 'cgi'
require 'nokogiri'
require 'fileutils'

CSV_DIR = ARGV[0]
raise 'No dir with CSV files provided' unless CSV_DIR

ALL_WORDS_CSV_FILE_NAME = 'words.csv'
`cat #{CSV_DIR}/* > #{ALL_WORDS_CSV_FILE_NAME}`

words = File.read(ALL_WORDS_CSV_FILE_NAME).scan(/([^\s",\d]+ć),/).flatten.uniq.sort

FileUtils.mkdir_p('html')

def word_url(word)
  "https://en.bab.la/conjugation/polish/#{CGI.escape(word)}"
end

def fetch(word)
  path = "html/#{word}.html"
  if File.exist?(path)
    File.read(path)
  else
    result = begin
      URI.open(word_url(word)).read
    rescue OpenURI::HTTPError
      puts "#{word} not found"
      ''
    end
    File.write(path, result)
    result
  end
end

body_html = ''

words.shuffle.each do |word|
  puts "Fetching #{word}"
  page_html = fetch(word)
  next if page_html.empty?

  page = Nokogiri(page_html)
  tenses = page.css('.conj-tense-block')
  body_html += <<~HTML
  <div>
    <h2><a href="#{word_url(word)}" target="_blank">#{word}</a></h2>
    <div>
      #{tenses[0].to_s}
      #{tenses[1].to_s}
    </div>
  </div>
  HTML
end

result_html = <<~HTML
<html>
  <head>
    <meta content="width=device-width, initial-scale=1" name="viewport">
    <meta http-equiv="content-type" content="text/html;charset=UTF-8">
    <style>
      .conj-person {
        margin-right: 10px;
        color: gray;
        float: left;
        width: 20%;
        text-align: right;
      }
      .conj-person, .conj-result {
        display: inline;
      }
    </style>
  </head>
  <body>#{body_html}</body>
</html>
HTML

result_file_name = 'index.html'
result_dir = 'public'
FileUtils.mkdir_p(result_dir)
result_full_name = File.join(result_dir, result_file_name)
File.write(result_full_name, result_html)
`google-chrome #{result_full_name}`
