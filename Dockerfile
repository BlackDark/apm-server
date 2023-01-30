FROM golang:1.18.5

RUN set -x && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
         netcat python3 python3-pip python3-venv && \
    apt-get clean


ENV PYTHON_ENV=/tmp/python-env

RUN pip3 install --upgrade pip
RUN pip3 install --upgrade setuptools

# Setup work environment
ENV APM_SERVER_PATH /go/src/github.com/elastic/apm-server

RUN mkdir -p $APM_SERVER_PATH
WORKDIR $APM_SERVER_PATH

COPY . $APM_SERVER_PATH

RUN make

CMD ./apm-server -e -d "*"

# Remove root permissions from user
USER root

RUN gpasswd -d apm-server root && \
    chown -R apm-server:apm-server /usr/share/apm-server

USER apm-server

# Add healthcheck for docker/healthcheck metricset to check during testing
HEALTHCHECK CMD exit 0
