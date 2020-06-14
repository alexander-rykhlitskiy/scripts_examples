ffmpeg -y -ss 0:58 -i video.mp4 -vframes 1 -q:v 2 comics.1.jpg
ffmpeg -y -ss 1:01 -i video.mp4 -vframes 1 -q:v 2 comics.2.jpg
ffmpeg -y -ss 1:05 -i video.mp4 -vframes 1 -q:v 2 comics.3.jpg
ffmpeg -y -ss 1:10 -i video.mp4 -vframes 1 -q:v 2 comics.4.jpg


convert comics.1.jpg -pointsize 63 \
                \( -background none -gravity northwest -font Impact \
                  -geometry +10+7 \
                  -fill white -size 684x144 caption:"Как кого зовут?" \) \
                \( -clone 1 -background black -shadow 100x3+3+3 \) \
                \( -clone 1 -clone 2 +swap -background none -layers merge \) \
                -delete 1,2 -composite \
                comics.1.text.jpg

convert comics.2.jpg -debug annotate \
                \( -background none -gravity center -gravity south -font Impact \
                  -geometry +0+7 \
                  -fill white -size 684x144 caption:"Сашу - Саша" \) \
                \( -clone 1 -background black -shadow 100x3+3+3 \) \
                \( -clone 1 -clone 2 +swap -background none -layers merge \) \
                -delete 1,2 -composite \
                comics.2.text.jpg

convert +append comics.1.text.jpg comics.2.text.jpg 1-2.jpg
convert +append comics.3.text.jpg comics.4.text.jpg 3-4.jpg
convert -append 1-2.jpg 3-4.jpg 2.jpg
