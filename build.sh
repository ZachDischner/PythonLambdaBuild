set -x

# 1. Freeze your pipenv env into a requirements.txt file
pipenv lock -r > requirements.txt

# 2. Use docker to pull in src, requirements.txt, output a zip
docker build --tag pythonbundler .
docker run -it --detach --name bundlercontainer pythonbundler
docker cp bundlercontainer:/var/task/lambda.zip .
docker container kill bundlercontainer
docker container rm bundlercontainer
