require 'open-uri'
require 'uri'
require 'cgi'
require 'nokogiri'
require 'fileutils'
require 'csv'

CSV_DIR = ARGV[0]
raise 'No dir with CSV files provided' unless CSV_DIR

ANKI = !!ARGV[1]

def read_words
  rows = Dir["#{CSV_DIR}/*"]
    .sort_by { _1.split('/').last.to_i }.first(14)
    .flat_map { |file| CSV.read(file) rescue puts "Error reading csv #{file}" }.compact
  rows.uniq! do |row|
    if row[0]
      row[0] = row[0].split(',').first
      row[0].gsub!('(się)', 'się')
      row[0]
    end
  end
  rows.select { |row| row[0]&.match?(/ć(\z|\s)/) }
end

def word_url(word)
  "https://en.bab.la/conjugation/polish/#{CGI.escape(word).gsub('+', '%20')}"
end

def fetch(word)
  path = "html/#{word}.html"
  if File.exist?(path)
    File.read(path)
  else
    result = begin
      puts "Fetching #{word}"
      URI.open(word_url(word)).read
    rescue OpenURI::HTTPError
      puts "#{word} not found"
      ''
    end
    FileUtils.mkdir_p('html')
    File.write(path, result)
    result
  end
end

def fetch_tenses(word)
  page_html = fetch(word)
  return if page_html.empty?

  page = Nokogiri(page_html.gsub('on/ona/ono', 'on(a,o)'))
  page.css('.conj-tense-block')
end

def write_file(file_name, content)
  result_dir = 'public'
  FileUtils.mkdir_p(result_dir)
  result_full_name = File.join(result_dir, file_name)
  File.write(result_full_name, content)
end

def word_wiki_url(word)
  "https://pl.wiktionary.org/wiki/#{word}"
end

def word_link(word, text = nil)
  <<~HTML
    <a href="#{word_wiki_url(word)}" target="_blank">#{text || word}</a>
  HTML
end

def styles
  <<~HTML
    <style>
      .conj-person {
        margin-right: 10px;
        color: gray;
        float: left;
        width: 20%;
        text-align: right;
      }
      .conj-result {
        text-align: left;
      }
    </style>
  HTML
end

def create_anki_file
  result = read_words.map do |word, translation|
    tenses = fetch_tenses(word) || next
    imperative = tenses.find { _1.to_s.include?('Tryb rozkazujący') }

    [
      word,
      "#{styles}<div><div>#{word_link(word, translation)}</div><br>#{tenses[0]} <br>#{tenses[1]} <br>#{imperative}<br></div>"
    ].map { "\"#{_1.gsub('"', '""')}\"" }.join("\t").gsub(/[\r\n]+/, '')
  end.compact.join("\n")
  write_file('anki.txt', result)
end

def create_html_file
  body_html = ''

  read_words.shuffle.each do |word, translation|
    tenses = fetch_tenses || next

    body_html += <<~HTML
    <div>
      <h2>word_link(word)</h2>
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
      #{styles}
    </head>
    <body>#{body_html}</body>
  </html>
  HTML
  write_file('index.html', result_html)
  `google-chrome #{result_full_name}`
end

if ANKI
  create_anki_file
else
  create_html_file
end

