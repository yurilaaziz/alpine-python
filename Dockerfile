FROM frolvlad/alpine-glibc AS builder
MAINTAINER Amine Ben Asker <ben.asker.amine@gmail.com>
ARG python_version=3.5.6
ARG python_configure_options=""
RUN apk add --no-cache wget \
            gcc \
            make \
            openssl-dev \
            musl-dev \
            zlib-dev \
            sqlite-dev \
            linux-headers \
            libffi-dev \
            readline-dev \
            xz-dev

RUN cd /tmp \
 &&  wget https://www.python.org/ftp/python/${python_version}/Python-${python_version}.tgz \
 &&  tar -xf Python-${python_version}.tgz \
 &&  cd Python-${python_version} \
 &&  ./configure ${python_configure_options} \
		--enable-loadable-sqlite-extensions \
		--enable-shared \
		--with-system-ffi \
	&& make -j "$(nproc)" \
	&& make install

RUN  find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +


FROM alpine
MAINTAINER Amine Ben Asker <ben.asker.amine@gmail.com>
COPY --from=builder /usr/local /usr/local

RUN apk add --no-cache libffi

