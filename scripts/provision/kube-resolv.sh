#!/usr/bin/env bash

touch /etc/kube-resolv.conf
echo "nameserver 8.8.8.8" >> /etc/kube-resolv.conf 
echo "nameserver 1.1.1.1" >> /etc/kube-resolv.conf
