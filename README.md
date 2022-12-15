# docker-docker-diffusers-api-base

This is just the base Conda / PyTorch / CUDA / xformers image for 
[docker-diffusers-api](https://github.com/kiri-art/docker-diffusers-api).

It includes the above only and not any pip packages.  However, the conda
packages are pretty big and dependency solving takes a while, so this
was a nice way to cut down on build times for first-time users or
repeated builds without a build-cache.

## See the [tags page](https://hub.docker.com/r/gadicc/diffusers-api-base/tags) for available images.

Generally, you have something like:

* python3.9-pytorch1.12.1-cuda11.6-xformers
* python3.9-pytorch1.12.1-cuda11.6-xformers-banana

which I believe are self-explanatory.
