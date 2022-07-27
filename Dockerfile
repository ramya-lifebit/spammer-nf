

FROM ubuntu

LABEL description="Ubuntu based container with tree" \
      version="1.0.0" \
      maintainer="christina@iifebit.ai" \
      name="quay.io/lifebitaiorg/ubuntu-tree"

RUN apt-get --allow-releaseinfo-change update -y \
  && apt-get install procps tree -y \
  && rm -rf /var/lib/apt/lists/*
