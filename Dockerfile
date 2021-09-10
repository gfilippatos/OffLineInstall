FROM ubuntu:20.04
ARG GIT_ACCESS_TOKEN
ARG USER=offline
ARG BRANCH=master
SHELL ["/bin/bash", "-c"]
RUN apt-get update -y \
&& apt-get install -y git \
&& useradd --uid 1000 --create-home ${USER}  \
&& mkdir /home/${USER}/src \
&& git clone  https://:${GIT_ACCESS_TOKEN}@gitlab.com/jem-euso/offline.git /home/${USER}/src \
&& cd /home/${USER}/src/pkgtools/ \
&& bash setup-packages-ubuntu.sh \
&& rm -rf /var/lib/apt/lists/* \
&& rm -r -f /home/${USER}/src/

USER ${USER}

RUN mkdir /home/${USER}/offline \
&& git clone  https://:${GIT_ACCESS_TOKEN}@gitlab.com/jem-euso/offline.git --branch ${BRANCH} /home/${USER}/src \
&& cd /home/${USER}/src/pkgtools/ \
&& bash setup-conda.sh \
&& bash setup-offline-env.sh -n \
&& cd /home/${USER}/offline/ \
&& mkdir build install  \
&& echo "#!/bin/bash" > /home/${USER}/offline//env.sh \
&& echo "source /home/${USER}/anaconda/bin/activate">> /home/${USER}/offline/env.sh \
&& echo "conda activate offline_env">> /home/${USER}/offline/env.sh \
&& echo "export JEMEUSOOFFLINEROOT="/home/${USER}/offline/install/"">> /home/${USER}/offline/env.sh \
&& chmod 777 /home/${USER}/offline/env.sh \
&& source /home/${USER}/offline/env.sh \
&& cd /home/${USER}/offline/build \
&& cmake /home/${USER}/src/  \
&& make -j4 \
&& make install \
&& echo 'eval `$JEMEUSOOFFLINEROOT/bin/jemeuso-offline-config --env-sh`'>> /home/${USER}/offline/env.sh \
&& rm -r -f /home/${USER}/offline/build \
&& rm -r -f /home/${USER}/src/ \
