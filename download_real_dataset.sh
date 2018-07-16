#!/usr/bin/bash

url="http://soma.isr.ist.utl.pt/vislab_data/shapes2018/shapes2018.tar.gz" 

# Donwload
wget ${url} -q -O shapes2018.tar.gz
# Unpack
mkdir -p dataset/
tar xzf shapes2018.tar.gz -C dataset/
# Cleanup
mkdir -p workspace/data 
cp dataset/processed/* workspace/data/
cp workspace/data/train.record workspace/data/real.record
rm -rf shapes2018.tar.gz

echo "Sucessfully downloaded dataset!"
