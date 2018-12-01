sms_log_path = ARGV.first

require 'date'

def parse_date(subject)
  if date = subject.match(/\d{2}-\d{2}-\d{2}/).to_a.first
    Date.strptime(date, '%d-%m-%y')
  elsif date = subject.match(/\d{2}\/\d{2}/).to_a.first
    Date.strptime(date, '%d/%m')
  end
end

def convert(amount, currency)
  case currency
  when 'BYR' then amount / 19_500.0
  when 'BYN' then amount / 1.9
  when 'EUR' then amount * 1.1
  when 'USD' then amount
  end
end

subjects = File.read(sms_log_path).split("\n").select do |line|
  line.match?(/Subject.*bank/) &&
    !line.match?(/zachislen/i) &&
    !line.match?(/Izmenenie parametrov dostupa/)
end

uber_sum = subjects.grep(/uber/i).inject(0) do |obj, subject|
  # 380 000 BYR
  price = subject.match(/[\d\.\s]+[A-Z]{3}/).to_a.first
  next obj unless price
  amount, currency = price.gsub(/[A-Z]{3}/, '').tr(' ', '').to_f, price.match(/[A-Z]{3}/).to_a.first
  obj += convert(amount, currency)
end

puts uber_sum
