set -x
TAG=$(date +%Y%j-%s)
# 0. Remove current asset
rm lambda.zip

# 1. Freeze your pipenv env into a requirements.txt file
pipenv lock --requirements > requirements.txt

# 2. Use docker to pull in src, requirements.txt, output a zip
CONTAINER_NAME="bundlercontainer-${TAG}"
docker build --no-cache --tag pythonbundler .
docker run -it --detach --name $CONTAINER_NAME pythonbundler
docker cp $CONTAINER_NAME:/opt/assets/lambda.zip .
# docker container kill $CONTAINER_NAME
# docker container rm $CONTAINER_NAME
