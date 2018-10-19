# docker run -it -p 15151:15151 -v /var/snap/lxd/common/lxd/unix.socket:/var/snap/lxd/common/lxd/unix.socket lxdui

FROM python:stretch AS BUILDER

RUN mkdir /install

WORKDIR /install

RUN git clone https://github.com/AdaptiveScale/lxdui.git /app

RUN pip install --install-option="--prefix=/install" -r /app/requirements.txt

COPY lxdui *.patch /app/

RUN cd /app \
 && cat *.patch | patch -p1 \
 && mkdir -p /install/lxdui \
 && cp -r -t /install/lxdui/ /app/run.py /app/app /app/conf /app/logs \
 && install -m 755 -t /install/bin/ /app/lxdui

FROM python:slim-stretch

COPY --from=BUILDER /install /usr/local/

WORKDIR /usr/local/lxdui

EXPOSE 15151/tcp 15152/tcp

ENTRYPOINT ["lxdui"]
