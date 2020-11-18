set -x
#
# Build this local environment, but for AWS lambda by running the local `buildLocalEnv.sh` script
# from within a container sharing lambda's architecture
#
TAG=$(date +%Y%j-%s)
CONTAINER_NAME=bundle-up-$TAG
WORKDIR=/opt/assets

# 0. Remove current asset
rm lambda.zip

# 1. Freeze your pipenv env into a requirements.txt file
pipenv lock --requirements > requirements.txt

# 2. Create container, drop assets into it, and tell it to build
docker build --tag pythonbundler .
# Start the container, detached, so it will continue to run its CMD (bash) until we kill it
docker run -it --detach --name $CONTAINER_NAME pythonbundler
docker exec -it $CONTAINER_NAME mkdir $WORKDIR
docker cp src $CONTAINER_NAME:/$WORKDIR
docker cp requirements.txt $CONTAINER_NAME:/$WORKDIR

# TODO - figure out how to separate the env (from requirements.txt) and the src code
# Build the env only when Pipfile changes. Otherwise, just zip its contets and our
# source code up. Should be much faster to iterate
docker cp buildLocalEnv.sh $CONTAINER_NAME:/$WORKDIR
#Create artifact zip file
docker exec -it $CONTAINER_NAME $WORKDIR/buildLocalEnv.sh 
# Copy artifact out of the container
docker cp $CONTAINER_NAME:/opt/assets/lambda.zip .

# If you're having issues, or are curious, drop into a terminal in this container
# docker exec -it $CONTAINER_NAME bash

# 3. Cleanup, kill the runninng container (maybe don't? Look a running container we want to iterate within?)
docker container kill $CONTAINER_NAME
docker container rm $CONTAINER_NAME 
