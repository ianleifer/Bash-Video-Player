#/bin/bash

url="$1"
fps=2
delay=$(awk "BEGIN {print 1/$fps}")
filename="newVideo.webm"

#rm $filename
#youtube-dl $url -o $filename
rm -r images
mkdir images
echo "Chopping video"
ffmpeg -loglevel panic -i $filename -r $fps images/out%5d.png

duration=$(ffprobe -i $filename -show_entries format=duration -v quiet -of csv="p=0")
nsteps=$(awk "BEGIN {printf int($duration/$delay)}")
rm -r sounds
mkdir sounds
echo "Chopping audio"
for((i=0; i<=$nsteps; i++)); do
	echo $i/$nsteps
	start=$(awk "BEGIN {print 0+$delay*$i}");
	ffmpeg -loglevel panic -i $filename -ss $start -t $delay -q:a 0 -map a sounds/sample$(printf %05d $i).mp3
done

images=()
for file in images/*; do
    images=("${images[@]}" "$file")
done

sounds=()
for file in sounds/*; do
    sounds=("${sounds[@]}" "$file")
done

nnsteps=$(( ${#images[@]} < ${#sounds[@]} ? ${#images[@]} : ${#sounds[@]} ))
for((i=0; i<=$nnsteps; i++)); do
	echo "Im = ${images[$i]}, Sound = ${sounds[$i]}"
	viu/viu/target/release/viu ${images[$i]};
	ffplay -nodisp -autoexit ${sounds[$i]} >/dev/null 2>&1
done
