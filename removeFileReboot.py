#!/usr/bin/python3
import paramiko
import configparser
#import MySQLdb
from multiprocessing.dummy import Pool as ThreadPool 
import time

def update_rigs(ip_address):
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


def main():
    ip = []
    with open("c2.txt", 'r') as f:
        for line in f:
            ip.append(line.strip())
    
    pool = ThreadPool(4)
    results = pool.map(update_rigs, ip)
    pool.close()
    pool.join()


if __name__ == "__main__":
    print(main())
    #print(update_rigs("10.22.2.2"))
