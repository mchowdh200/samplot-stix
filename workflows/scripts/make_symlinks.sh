#!/bin/env bash

beds=$1
beddir=$2
outdir=$3

mkdir -p $outdir
for b in $(cat $beds); do
    ln -s "$beddir/$b" "$outdir/$b"
done
