FROM ubuntu:zesty
MAINTAINER pomupekun<pomupekun.gmail.com>
# ENV PATH=/opt/conda/bin:/usr/local/lib/node_modules/ijavascript/bin:$PATH
# ENV PATH=/opt/conda/bin:/usr/local/src/cling/bin:$PATH
ENV PATH=/usr/local/bin:/opt/conda/bin:/usr/local/src/cling/bin:$PATH

# PATH=/usr/local/src/cling/bin:$PATH

# common packages for build kernels
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
		wget \
		curl \
		bzip2 \
		git \
		unzip \
		libzmq3-dev \
		python-dev \
		software-properties-common \
		libgtk2.0-0

# miniconda
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/install_miniconda.sh \
 &&	bash /tmp/install_miniconda.sh -b -p /opt/conda \
 &&	conda update -y --all \
 && rm /tmp/install_miniconda.sh \
 && mkdir -p /opt/conda/var/lib/dbus/

# jupyter
RUN conda install -y \
		jupyter \
 && conda upgrade notebook -y \
 &&	pip install jupyterlab


# Julia kernel
#RUN apt-get install -y \
#		julia && \
#	julia -e 'Pkg.add("IJulia")'

## ijavascript kernel
#RUN apt-get clean && \
#	apt-get update -y && \
#	apt-get install -y \
#		nodejs-legacy \
#		apt-utils \
#		npm \
#		python-dev && \
#	npm install -y -g ijavascript && \
#	ijavascript.js --ijs-install-kernel
#

# Node.js kernel
RUN apt-get install -y \
		nodejs-legacy \
		npm \
 && git clone https://github.com/notablemind/jupyter-nodejs.git /usr/local/src/jupyter-nodejs \
 && cd /usr/local/src/jupyter-nodejs \
 && npm install \
 && node install.js \
 && npm run build \
 && npm run build-ext

# Octave kernel
RUN apt-get install -y \
		octave \
 && conda install -y -c conda-forge\
		octave_kernel
ENV OCTAVE_EXECUTABLE=/usr/bin/octave

# C++ kernel
RUN wget https://root.cern.ch/download/cling/cling_2017-04-06_ubuntu16.tar.bz2 -O /tmp/cling.tar.bz2
RUN tar vxf /tmp/cling.tar.bz2 -C /tmp/ \
 && rm /tmp/cling.tar.bz2 \
 && mv /tmp/cling_2017-04-06_ubuntu16 /usr/local/src/cling \
 && cd /usr/local/src/cling/share/cling/Jupyter/kernel/ \
 && python setup.py install \
 && pip install -e . \
 && jupyter-kernelspec install cling-cpp17

# Bash kernel
RUN pip install bash_kernel \
 && python -m bash_kernel.install

# PHP



## PHP kernel
#RUN apt-get install -y \
#		curl \
#		php \
#		php-zmq && \
#	wget -q https://litipk.github.io/Jupyter-PHP-Installer/dist/jupyter-php-installer.phar -O /tmp/install_jupyter-php.phar && \
#	curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin && \
#	php /tmp/install_jupyter-php.phar install && \
#	rm /tmp/install_jupyter-php.phar

# tini
RUN curl -L https://github.com/krallin/tini/releases/download/v0.14.0/tini -o /usr/local/bin/tini \
 && chmod +x /usr/local/bin/tini

# python packages
RUN conda install -c https://conda.binstar.org/menpo -y \
		opencv3 \
		matplotlib \
		numpy

# jupyter extensions
RUN conda install -y -c conda-forge \
		jupyter_nbextensions_configurator \
		jupyter_contrib_nbextensions \
		ipyparallel \
 &&	pip install jupyterthemes

#RUN jupyter serverextension enable --py jupyterlab --sys-prefix

# jupyter setting
RUN jt -t onedork -vim -fs 10 -nfs 11 -tfs 11 \
 && ipcluster nbextension enable \
 &&	jupyter nbextension enable --py --sys-prefix widgetsnbextension \
 && jupyter nbextensions_configurator enable



ENTRYPOINT ["tini", "--", "jupyter"]
CMD ["--allow-root", "--ip=0.0.0.0"]

