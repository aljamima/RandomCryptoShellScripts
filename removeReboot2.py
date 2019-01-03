#!/usr/bin/python3
import os
import requests
import json
import errno
from socket import error as socket_error
import sys
import configparser
import paramiko
#import MySQLdb
from multiprocessing.dummy import Pool as ThreadPool 
import time

sys.stdout = open('loggyMcLoggerson.txt','wt')

def remove_reboot(ip_address):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh_client.connect(ip_address, username='rigx', password='rigx', timeout=10)
        ssh_stdin, ssh_stdout, ssh_stderr = ssh_client.exec_command("sudo -S rm -rf /home/rigx/elixir_xmr/amd.txt; reboot now")
        ssh_stdin.write('rigx' + '\n')
        ssh_stdin.flush()
        ssh_stdin, ssh_stdout, ssh_stderr = ssh_client.exec_command("sudo -S reboot now")
        ssh_stdin.write('rigx' + '\n')
        ssh_stdin.flush()
        print("Updated " + ip_address)
        return "Successfully updated!"
    except Exception:
        # Return none if needs reboot, let the tech figure it out
        # Log parse failed: Tech interaction needed (logs, or reboot) *** old response ***
        print("Conn error " + ip_address)
        return "Cannot connect"




ip_add_file = open(r'./c2.txt','r')
output = './output.txt'
try:
    os.remove(output)
except OSError:
    pass

for host in ip_add_file:
    host = host.strip()
    url = 'http://' + host + ':4028/api.json'
    try:
        r = requests.get(url,timeout=3)
        r.raise_for_status()
    except requests.exceptions.HTTPError as errh:
        pass
        #print (host + "Http Error:",errh)
    except requests.exceptions.ConnectionError as errc:
        pass
        #print (host + "Error Connecting:",errc)
    except requests.exceptions.Timeout as errt:
        pass
        #print (host + "Timeout Error:",errt)
    except requests.exceptions.RequestException as err:
        pass
        #print (host + "OOps: Something Else",err)
    try:
        data = r.json()
    except ValueError as ve:
        #print("bad request.json i think?")
        pass
    else:
        #print("I dont know what the problem is but there certainly IS a problem...")
        pass
    try:
        json_data = json.loads(r.text)
    except ValueError as ve:
        pass
        #print("we got an error, looks a like response WAS NOT valid json")
    my_dic = (json_data["hashrate"])
#    print("data = " + str(data))
#    print("json_data = " + str(json_data))
    if my_dic["highest"] > 2000:
        print(host + "   Highest Hashrate: " + str(my_dic["highest"]), file=open("output.txt", "a"))
    else:
        remove_reboot(host)
        print(host + " had low hashrate (" + str(my_dic["highest"]) + "), rebooted it.", file=open("output.txt", "a"))

with open(output, 'r') as fin:
    print(fin.read(), end="")
print("cat loggyMcLoggerson.txt for logs...")
