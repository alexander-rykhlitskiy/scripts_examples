# python 3.7.5
# pip install geopy
# pip install requests

from geopy.geocoders import Nominatim
import requests
import json
import os.path
import pprint
import os

url = 'https://api.dze.chat/markers.json?ver=1'

os.makedirs('tmp', exist_ok=True)
file_name = 'tmp/dze_chat_result_stats.json'
markers_data = None
pp = pprint.PrettyPrinter(depth=2)
pprint.sorted = lambda x, key=None: x

if os.path.isfile(file_name):
    with open(file_name) as json_file:
        markers_data = json.load(json_file)
else:
    markers_data = requests.get(url=url).json()
    for marker in markers_data['markers']:
        geolocator = Nominatim(user_agent="dze_chat_stats")
        coords = f"{marker['lat']}, {marker['long']}"
        location = geolocator.reverse(coords, language='en')
        marker['raw_location'] = location.raw
        pp.pprint(marker)

    with open(file_name, 'w', encoding='utf-8') as f:
        json.dump(markers_data, f, ensure_ascii=False, indent=4)

def print_result(by_country=None):
    result = {}
    for marker in markers_data['markers']:
        country = marker['raw_location']['address']['country']
        if by_country:
            city = marker['raw_location']['address'].get('city')
            if country != by_country: continue
            result[city] = result.get(city) or 0
            result[city] += marker['count_members']
        else:
            result[country] = result.get(country) or 0
            result[country] += marker['count_members']

    result = {k: v for k, v in sorted(result.items(), key=lambda item: -item[1])}

    pp.pprint(result)

print_result()
print_result('Poland')
