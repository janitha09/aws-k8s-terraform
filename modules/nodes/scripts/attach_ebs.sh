#!/bin/bash
sudo mkfs -t ext4 /dev/xvdb
sudo mkdir /data
sudo mount /dev/xvdb /data
echo /dev/xvdb  /data ext4 defaults,nofail 0 2 >> sudo /etc/fstab