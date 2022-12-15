# Banana requires Cuda version 11+.  Below is banana default:
# ARG FROM_IMAGE="pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime"
# xformers available precompiled for:
#   Python 3.9 or 3.10, CUDA 11.3 or 11.6, and PyTorch 1.12.1
#   https://github.com/facebookresearch/xformers/#getting-started
# Below: pytorch base images only have Python 3.7 :(
ARG FROM_IMAGE="pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime"
# Below: our ideal image, but Optimization fails with it.
# ARG FROM_IMAGE="continuumio/miniconda3:4.12.0"
FROM ${FROM_IMAGE} as base
ENV FROM_IMAGE=${FROM_IMAGE}

# Note, docker uses HTTP_PROXY and HTTPS_PROXY (uppercase)
# We purposefully want those managed independently, as we want docker
# to manage its own cache.  This is just for pip, models, etc.
ARG http_proxy
ARG https_proxy
RUN if [ -n "$http_proxy" ] ; then \
    echo quit \
    | openssl s_client -proxy $(echo ${https_proxy} | cut -b 8-) -servername google.com -connect google.com:443 -showcerts \
    | sed 'H;1h;$!d;x; s/^.*\(-----BEGIN CERTIFICATE-----.*-----END CERTIFICATE-----\)\n---\nServer certificate.*$/\1/' \
    > /usr/local/share/ca-certificates/squid-self-signed.crt ; \
    update-ca-certificates ; \
  fi
ARG REQUESTS_CA_BUNDLE=${http_proxy:+/usr/local/share/ca-certificates/squid-self-signed.crt}

ARG DEBIAN_FRONTEND=noninteractive
#RUN apt-get install gnupg2
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC
RUN apt-get update

RUN conda update -n base -c defaults conda
# We need python 3.9 or 3.10 for xformers
# Yes, we install pytorch twice... will switch base image in future
RUN conda create -n xformers python=3.9
SHELL ["/opt/conda/bin/conda", "run", "--no-capture-output", "-n", "xformers", "/bin/bash", "-c"]
RUN python --version
RUN conda install -c pytorch -c conda-forge cudatoolkit=11.6 pytorch=1.12.1
RUN conda install xformers -c xformers/label/dev

# Install latest pip (w/o proxy)
RUN https_proxy="" REQUESTS_CA_BUNDLE="" conda install pip

RUN apt-get install -yq apt-utils
RUN apt-get install -yqq git
RUN apt-get install -yqq zstd
RUN apt-get install -yqq git-lfs
