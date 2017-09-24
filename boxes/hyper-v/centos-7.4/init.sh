#!/bin/sh
sudo vagrant box add centos-7.4 centos7-0.0.99.box 
sudo vagrant init centos-7.4
#sudo vagrant up
#sudo vagrant halt
vagrant box list
