#!/bin/bash

# Copied from https://gist.github.com/antarktikali/d4ebdc5ebdc32f449827

mkdir new_frames
cp IMG_2985.png new_frames/previous.png
cp $0 new_frames/previous.png

cd new_frames
counter=0

for f in ../*.png
  do
    for i in {0..20}
      do
        let "counter+=1"
        composite -blend $((i*5)) $f previous.png -matte blend_$counter.png
      done
    cp $f previous.png
  done

rm previous.png

ffmpeg -r "60" -i blend_%d.png -qscale 6 video.mp4
