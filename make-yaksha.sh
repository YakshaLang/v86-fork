#!/bin/bash
rm -rf images ; mkdir images
cd tools/docker/debian
./build-container.sh
./build-state.js
cd ../../../images
rm debian-9p-rootfs.tar   
zstd debian-state-base.bin && rm debian-state-base.bin 
mv debian-state-base.bin.zst debian-state-base.bin
cd ../yaksha-playground
rm -rf images
cp -r ../images .
rm -rf state ; mkdir state
mv images/debian-state-base.bin ./state
cd state
split -b 11m debian-state-base.bin
rm debian-state-base.bin
