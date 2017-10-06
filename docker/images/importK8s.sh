#!/bin/bash
currFolder=`pwd`
export_path=tar_v1.7.5
cd $export_path
#tars=$(ls $export_path)
tars=$(ls .)
for tar in $tars
do
  if [[ $tar != "$(basename $0)" ]]; then
    docker load -i $tar
  fi
done
docker images
cd $currFolder
