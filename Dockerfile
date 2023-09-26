FROM ubuntu:22.04
ARG GIT_ACCESS_TOKEN
ARG USER=offline
ARG BRANCH=master
ARG CORES=2
SHELL ["/bin/bash", "-c"]
RUN apt-get update -y \
&& apt-get install -y git \
&& useradd --uid 1000 --create-home ${USER}  \
&& mkdir /home/${USER}/src \
&& git clone  https://${GIT_ACCESS_TOKEN}@gitlab.com/jem-euso/offline.git /home/${USER}/src \
&& cd /home/${USER}/src/pkgtools/ \
&& bash setup-packages-ubuntu.sh \
&& rm -rf /var/lib/apt/lists/* \
&& rm -r -f /home/${USER}/src/

USER ${USER}

RUN mkdir /home/${USER}/offline_build/  /home/${USER}/offline_install/ \
&& chmod -R 777 /home/${USER}/ \
&& git clone  https://${GIT_ACCESS_TOKEN}@gitlab.com/jem-euso/offline.git --branch ${BRANCH} /home/${USER}/src \
&& cd /home/${USER}/src/pkgtools/ \
&& bash setup-conda.sh \
&& bash setup-offline-env.sh -n \
&& echo "#!/bin/bash" > /home/${USER}/env.sh \
&& echo "source /home/${USER}/mambaforge/bin/activate">> /home/${USER}/env.sh \
&& echo "conda activate offline_env">> /home/${USER}/env.sh \
&& echo "export JEMEUSOOFFLINEROOT="/home/${USER}/offline_install/"">> /home/${USER}/env.sh \
&& chmod 777 /home/${USER}/env.sh \
&& source /home/${USER}/env.sh \
&& cd /home/${USER}/offline_build \
&& cmake /home/${USER}/src/  \
&& cmake --build . -j${CORES}  --target install\
&& echo 'eval `$JEMEUSOOFFLINEROOT/bin/jemeuso-offline-config --env-sh`'>> /home/${USER}/env.sh \
&& rm -r -f /home/${USER}/offline_build \
&& rm -r -f /home/${USER}/src/ \
&& chmod -R 777 /home/${USER}/ \
