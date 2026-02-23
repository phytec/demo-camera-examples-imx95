#!/bin/sh

echo "Stop the Qt Demo and remove from auto start"
echo "==========================================="
systemctl disable phytec-qtdemo
systemctl stop phytec-qtdemo
