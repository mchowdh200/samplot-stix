#!/bin/env bash

giggle_index=$1
ped=$2
outdir=$3
stix_bin=$4

cd $outdir
$stix_bin -i $(basename $beds) -p $(basename $ped) -d $(basename $ped).db -c 8
# $stix_bin -i $giggle_index -p $ped -d $ped.db -c 8

