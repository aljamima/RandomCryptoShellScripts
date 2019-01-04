#!/usr/bin/python3
import os
import requests
import json
import errno
from socket import error as socket_error
import paramiko
import configparser
from multiprocessing.dummy import Pool as ThreadPool 
import time
from termcolor import colored


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
        with open("error.txt", "at") as error_file:
            error_file.write(host + " Has Low Hashrate( " + str(my_dic["highest"]) + ") ATTEMPTING REBOOT" + '\n')
        print("Rebooting " + ip_address)
        return "Successfully Rebooted!"
    except paramiko.SSHException as sshException:
        print("Unable to establish SSH connection: %s" % sshException)
    #except Exception as except_a_rooni_and_cheese:
    #    pass
        # Return none if needs reboot, let the tech figure it out
        # Log parse failed: Tech interaction needed (logs, or reboot) *** old response ***
        #print("Conn error " + ip_address)
        #with open("error.txt", "at") as error_file:
        #    error_file.write(host + " Had Connection Error, Possibly Crashed" + '\n')
        #return "Cannot connect"
######################################################################
######################################################################
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
    #print("data = " + str(data))
    #print("")
    #print("json_data = " + str(json_data))
    #print("")
    if my_dic["highest"] > 2000:
        with open("output.txt", "at") as output_file:
            output_file.write(host + "   Highest Hashrate: " + str(my_dic["highest"]) + '\n')
    else:
        #remove_reboot(host)
        with open("error.txt", "at") as error_file:
            error_file.write(host + " Has Low Hashrate( " + str(my_dic["highest"]) + ") POSSIBLY NEEDS A REBOOT!" + '\n')

with open("output.txt", "r") as output_out:
    print(output_out.read(), end="")
print()
print()
print(colored("Here Are The Rigs That May Have Issues: ", "red"))
with open("errors.txt", "r") as error_out:
    print(error_out.read(), end="")
