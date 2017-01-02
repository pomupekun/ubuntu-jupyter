FROM ubuntu:zesty
MAINTAINER pomupekun<pomupekun.gmail.com>
ENV PATH=/opt/conda/bin:/usr/local/lib/node_modules/ijavascript/bin:$PATH

# miniconda and jupyter
RUN apt-get update && apt-get upgrade -y && \
	apt-get install -y \
		apt-utils \
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

# python packages
RUN conda install -y \
		opencv \
		matplotlib

# Julia kernel
RUN apt-get install -y \
		julia && \
	julia -e 'Pkg.add("IJulia")'

# Node.js kernel
RUN apt-get install -y \
		npm \
		nodejs-legacy \
		python-dev && \
	npm install -y ijavascript && \
	ijavascript --ijs-install-kernel

# PHP
RUN apt-get install -y \
		curl \
		php \
		php-zmq && \
	wget -q https://litipk.github.io/Jupyter-PHP-Installer/dist/jupyter-php-installer.phar -O /tmp/install_jupyter-php.phar && \
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin && \
	php /tmp/install_jupyter-php.phar install

CMD ["/jupyter/conf/cmd.sh"]

