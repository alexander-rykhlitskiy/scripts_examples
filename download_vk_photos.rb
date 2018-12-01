# on page:
# Array.from(document.querySelectorAll('img')).map(function(i) { return i.getAttribute('src') })
#
# and run it in BASH like
# ruby download_vk_photos.rb ["https://pp.userapi.com/c627229/v627229225/14621/HrSRmM8kj0k.jpg", "https://pp.userapi.com/c627229/v627229225/1462b/_xRE7yhP6as.jpg"] ["https://pp.userapi.com/c627229/v627229225/14635/gar_kwwduZ0.jpg"]
# paste JSON string arrays after ruby download_vk_photos.rb

links = ARGV

links.map! { |link| link.gsub(/[\"\\\[\]\,]/, '') }
links.each { |link| `wget #{link}` }
