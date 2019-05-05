#!/usr/bin/env ruby

filename = ARGV[0]

new_text = File.read(filename).split("\n").map do |line|
  # remove initial form, part of speech, transcription
  line = line.gsub(/([а-яА-яё][\)\.]*|\t)\t[^\t]*\t[^\t]*\t[^\t]*/, '\1')
  line = line.gsub(/\d+\s\d+\s/, '')
  line.gsub(/^to\s/, '')
end.join("\n")

ext = File.extname(filename)
output_file = "#{File.basename(filename, ext)}_to_memrise#{ext}"
File.write(output_file, new_text)

puts output_file
