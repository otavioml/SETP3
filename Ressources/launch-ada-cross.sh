#!/usr/bin/env sh

sudo apt-get -qq install -y qemu binfmt-support qemu-user-static
sudo apt-get -qq install -y tcl8.6 tk8.6

code .
sudo docker pull registry.ia.ensma.fr/depia-dev/ada-cross-rasp:bullseye-1.0
sudo docker run -it --rm --add-host=host.docker.internal:host-gateway -v $PWD:/Tank-Workspace registry.ia.ensma.fr/depia-dev/ada-cross-rasp:bullseye-1.0 /bin/zsh



