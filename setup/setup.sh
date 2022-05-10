#!/bin/env bash
mkdir -p ../workflows/bin

git clone https://github.com/ryanlayer/giggle.git
cd giggle
make
mv bin/giggle ../workflows/bin/

cd ..
wget http://www.sqlite.org/2017/sqlite-amalgamation-3170000.zip
unzip sqlite-amalgamation-3170000.zip

git clone https://github.com/ryanlayer/stix.git
cd stix
make
mv bin/stix ../workflows/bin/

