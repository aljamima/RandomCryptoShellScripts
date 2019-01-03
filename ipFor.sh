#!/bin/bash
ip a s|grep -A8 -m1 MULTICAST|grep -m1 inet|cut -d' ' -f6
