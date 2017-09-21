#!/bin/bash
currFolder=`pwd`
export_path=/docker/works/v1.6.2/tar_v1.6.2
cd $export_path
tars=$(ls $export_path)
for tar in $tars
do
  if [[ $tar != "$(basename $0)" ]]; then
    docker load -i $tar
  fi
done
docker images
cd $currFolder
