
IMAGE="saucydorito/gossett-ceg3120:latest"
CONTAINER_NAME="angular"

docker pull $IMAGE
docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME
docker run -d -p 4200:4200 --name $CONTAINER_NAME $IMAGE
