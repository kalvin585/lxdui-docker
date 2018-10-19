# docker run -it -p 15152:15152 -v /var/lib/lxd/unix.socket:/var/lib/lxd/unix.socket lxdui

FROM ubuntu AS BUILDER

RUN mkdir /install

WORKDIR /install

RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/zzz-no-recommends \
 && apt-get update \
 && apt-get install -y build-essential git python3-dev python3-pip python3-setuptools

RUN apt-get install -y libffi-dev libssl-dev

RUN git clone https://github.com/AdaptiveScale/lxdui.git /app

RUN pip3 install --install-option="--prefix=/install" -r /app/requirements.txt \
 && ln -s site-packages $(dirname $(find /install/ -name site-packages))/dist-packages

COPY lxdui *.patch /app/

RUN cd /app \
 && cat *.patch | patch -p1 \
 && mkdir -p /install/lxdui \
 && cp -r -t /install/lxdui/ /app/run.py /app/app /app/conf /app/logs \
 && install -m 755 -t /install/bin/ /app/lxdui

FROM ubuntu

RUN apt-get update \
 && apt-get install -y lxd-client python3 python3-pkg-resources \
 && apt-get clean -y \
 && rm -rf /tmp/* /var/lib/apt/lists/*

COPY --from=BUILDER /install /usr/local/

WORKDIR /usr/local/lxdui

EXPOSE 15151/tcp 15152/tcp

ENTRYPOINT ["lxdui"]
