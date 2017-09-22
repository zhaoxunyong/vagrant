@echo off
SET FOLDER=D:\Vagrant\boxes\centos-7.4
::vagrant box add centos-7.4 centos7-0.0.99.box 
cd %FOLDER%
vagrant up
