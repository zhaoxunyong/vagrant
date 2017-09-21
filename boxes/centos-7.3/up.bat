@echo off
SET FOLDER=D:\Vagrant\boxes\centos-7.3
::vagrant box add centos-7.3 centos73-0.1.0.box
cd %FOLDER%
vagrant up
