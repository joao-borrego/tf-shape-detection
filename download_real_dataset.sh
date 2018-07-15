#!/usr/bin/bash

#url="http://soma.isr.ist.utl.pt/vislab_data/shape_detection/shape_detection.tar.gz" 
url="http://web.tecnico.ulisboa.pt/~joao.borrego/new_SHAPES_2018.tar.gz" 

# Donwload
wget ${url} -q -O shape_detection.tar.gz
# Unpack
mkdir -p dataset/
tar xzf shape_detection.tar.gz -C dataset/
# Cleanup
mkdir -p workspace/data 
cp dataset/processed/* workspace/data/
cp workspace/data/train.record workspace/data/real.record
rm -rf shape_detection.tar.gz

echo "Sucessfully downloaded dataset!"
