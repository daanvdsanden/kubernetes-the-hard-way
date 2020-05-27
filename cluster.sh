#!/bin/bash

apt-get update

apt-get install -y pacemaker pcs

echo "hacluster:just-for-learning" | chpasswd

sed -i "/127\.0\.1\.1/d" /etc/hosts
