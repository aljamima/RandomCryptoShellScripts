#!/usr/bin/python3
import os
import subprocess
import time

def main():
    get_avg_tmp = float(subprocess.run(['/home/rigx/.fancontrol/./temp_control.sh'], stdout=subprocess.PIPE).stdout.decode('utf-8').strip())
    print(get_avg_tmp)

    temp_map = {30:15, 35:35, 40:60, 50:65, 55:70, 65:75, 70:85, 75:90, 80:100}

    for temp,speed in temp_map.items():
        if get_avg_tmp >= temp:
            actual = speed

    os.system('/home/rigx/.fancontrol/./fancontrol.sh -s ' + str(actual))

while True:
    main()
    time.sleep(15)