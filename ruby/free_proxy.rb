require 'net/http'

class Proxy
  def get(uri)
    send(uri, Net::HTTP::Get.new(uri))
  end

  def send(uri, request, retry_500: true)
    retries_count = 0
    begin
      proxy_host, proxy_port = fetch_proxy

      Net::HTTP.start(uri.host, uri.port, proxy_host, proxy_port,
                      open_timeout: 2, read_timeout: 2, ssl_timeout: 2) do |http|
        http.request(request) do |response|
          raise(Net::HTTPFatalError, '5xx') if response.code.start_with?('5') && retry_500
          # it doesn't work with `return response`
          return response.body
        end
      end
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET, Net::OpenTimeout, Net::ReadTimeout, Net::HTTPFatalError => e
      puts "Proxy request failed with '#{e}', '#{e.message}'"
      retries_count += 1
      retries_count < 10 ? retry : puts("Proxy request failed #{retries_count} times. Returning")
    end
  end

  def fetch_proxy
    # 240 requests per 24 hours allowed
    result = JSON.parse(Net::HTTP.get(URI('https://gimmeproxy.com/api/getProxy?country=CA')))
    if result['status_code'].to_i == 429
      puts "Proxy request failed because '#{result['status_message']}'"
      []
    else
      [result['ip'], result['port']]
    end
  end
end

puts JSON.parse(Proxy.new.get(URI('http://ip-api.com/json')))
