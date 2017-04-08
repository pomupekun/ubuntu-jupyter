FROM ubuntu:zesty
MAINTAINER pomupekun<pomupekun.gmail.com>
ENV PATH=/opt/conda/bin:/usr/local/lib/node_modules/ijavascript/bin:$PATH

# miniconda and jupyter
RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y \
		libzmq3-dev \
		bzip2 \
		wget && \
	wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/install_miniconda.sh && \
	bash /tmp/install_miniconda.sh -b -p /opt/conda && \
	conda update -y --all && \
	conda install -y \
		jupyter && \
	pip install jupyterlab && \
	rm /tmp/install_miniconda.sh

# Julia kernel
#RUN apt-get install -y \
#		julia && \
#	julia -e 'Pkg.add("IJulia")'

# Node.js kernel
RUN apt-get clean && \
	apt-get update -y && \
	apt-get install -y \
		nodejs-legacy \
		apt-utils \
		npm \
		python-dev && \
	npm install -y -g ijavascript && \
	ijavascript.js --ijs-install-kernel

## PHP kernel
#RUN apt-get install -y \
#		curl \
#		php \
#		php-zmq && \
#	wget -q https://litipk.github.io/Jupyter-PHP-Installer/dist/jupyter-php-installer.phar -O /tmp/install_jupyter-php.phar && \
#	curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin && \
#	php /tmp/install_jupyter-php.phar install && \
#	rm /tmp/install_jupyter-php.phar

# python packages
RUN conda install -y \
		-c https://conda.binstar.org/menpo opencv3 \
		matplotlib \
		numpy

# jupyter extensions
RUN conda install -y -c \
		conda-forge \
		jupyter_nbextensions_configurator \
		jupyter_contrib_nbextensions

RUN apt-get clean && \
	apt-get update -y && \
	apt-get install -y \
		curl

#ENV TINI_VERSION v0.14.0
#ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
#RUN chmod +x /tini

ENV PATH=/usr/local/bin:$PATH
RUN curl -L https://github.com/krallin/tini/releases/download/v0.14.0/tini -o /usr/local/bin/tini && \
	chmod +x /usr/local/bin/tini

RUN pip install jupyterthemes && \
	jt -t onedork -vim -fs 10 -nfs 11 -tfs 11

RUN apt-get clean && apt-get update -y && apt-get install -y libgtk2.0-0

#RUN jupyter serverextension enable --py jupyterlab --sys-prefix

ENTRYPOINT ["tini", "--", "jupyter"]
CMD ["--ip=0.0.0.0"]

