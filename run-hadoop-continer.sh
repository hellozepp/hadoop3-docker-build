docker build -t hadoop3 .

docker run --hostname=hadoop3 \
  -p 8088:8088 \
  -p 9870:9870 \
  -p 9864:9864 \
  -p 19888:19888 \
  -p 8042:8042 \
  -p 8888:8888 \
  --name hadoop3 -d hadoop3
