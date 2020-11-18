FROM lambci/lambda:build-python3.8

# Idea is to copy source, requirements.txt, and install packages
# into a directory in $WORKDIR. Then zip it up and make it available
# to copy out
# /$WORKDIR/
#          -requirements.txt
# pip install to...
#          -build/dependencies
# copy source to...
#          -build/(src/*)
# create a zip from...
#          -lambda.zip (zip of build)

WORKDIR /opt/assets
ENV WORKDIR /opt/assets

# Very simple image. Doesn't do much, as all of its functionality is exercised at runtime. We
# just want this for its libraries and AWS Lambda compatible architecture

# Future TODO - automatically build the `requirements.txt` into this image at build time
# That way, we can just iterate by including updated src code and zipping, saves tons of 
# time

# Drop into container shell to poke around if you want
CMD ["/bin/bash"]

