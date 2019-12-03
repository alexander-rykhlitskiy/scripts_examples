#!/usr/bin/env ruby

lines = `git ls-remote 2>&1`.split("\n")
url = lines.grep(/^From/).first.split(/\s+/).last.gsub(':', '/').gsub('git@', 'https://').gsub(/.git$/, '')
commit = lines.grep(/HEAD$/).first.split(/\s+/).first

result = "#{url}/commits/#{commit}"
cmd = `uname`.include?('Linux') ? "echo #{result} | xclip -selection clip" : "pbcopy #{result}"
system(cmd)
puts result
puts 'was copied to clipboard'
