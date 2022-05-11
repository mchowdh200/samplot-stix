#!/bin/env bash

beds=$1
ped=$2
outdir=$3
stix_bin=$4

cd $outdir

$stix_bin -i $(basename $beds) -p $(basename $ped) -d $(basename $ped).db -c 7

