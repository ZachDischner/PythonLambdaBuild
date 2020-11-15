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
RUN rm -rf $WORKDIR/*


# Copy requirements.txt into the working dir
COPY requirements.txt "$WORKDIR"

RUN mkdir -p build

# Copy initial source codes into container.
COPY src "$WORKDIR"

# Install deps into the build dir
COPY src/* "$WORKDIR/build"
# Just in case...
RUN touch $WORKDIR/build/__init__.py
RUN  pip install -r requirements.txt --no-deps -t build/

# Compress all source code and deps. Puts them all top level in a zip
# so that you can just reference your src code directly as if you are 
# working from there AKA
# src/lambda_handler.py
# Tell your handler is just `lambda_handler.handle`
RUN cd build && zip -r9 $WORKDIR/lambda.zip *

# Drop into container shell to poke around if you want
CMD ["/bin/bash"]

# TODO - make this faster, pip install reqs into one dir, then put a 
# CMD/ENTRYPOINT that will just copy updated local src and create the zip