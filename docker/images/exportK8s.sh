#!/bin/bash
export_path=tar_v1.7.5
#k8s_imgs=$(docker images |awk '{print $1}'|grep gcr.io|uniq)
k8s_imgs=$(docker images |awk '{print $1":"$2}'|uniq|grep -v REPOSITORY)
if [ ! -d "$export_path" ]; then
  mkdir -p $export_path
fi

for k8s_img in $k8s_imgs
do
  k8s_filename=${k8s_img/:/_}
  file_tar=$export_path/${k8s_filename//\//_}.tar
  if [ ! -e $file_tar ]; then
    docker save -o ${file_tar} $k8s_img
    echo "$k8s_img exported."
  #else
   #echo "$k8s_img skipped."
  fi
done
