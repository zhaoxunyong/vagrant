#!/bin/bash
export_path=/docker/works/v1.6.2/tar_v1.6.2
#k8s_imgs=$(docker images |awk '{print $1}'|grep gcr.io|uniq)
k8s_imgs=$(docker images |awk '{print $1":"$2}'|uniq|grep -v REPOSITORY)
if [ ! -d "$export_path" ]; then
  mkdir -p $export_path
fi

for k8s_img in $k8s_imgs
do
  k8s_filename=${k8s_img/:/_}
  docker save -o $export_path/${k8s_filename//\//_}.tar $k8s_img
  echo "$k8s_img exported."
done
