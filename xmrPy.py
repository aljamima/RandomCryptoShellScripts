import requests
import json

response = requests.get('http://10.22.1.4:4028/api.json')
data = response.json()
#print(data["hashrate"])
'''
#print(data["hashrate"]) ## may need to do hashrate in another dict then iterate thru it... 
'''

json_data = json.loads(response.text)

my_dic = (json_data["hashrate"])

print(my_dic["highest"])

with open("data_file.json", "w") as write_file:
    json.dump(my_dic["highest"], write_file)

