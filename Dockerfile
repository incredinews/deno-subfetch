#FROM alpine
#RUN apk add bash ca-certificates curl grep sed && mkdir /app && (curl -fsSL https://deno.land/install.sh | bash && ln -s /root/.deno/bin/deno /usr/bin/deno )

FROM yyyar/gobetween AS copylb

FROM debian:bookworm AS builder
RUN apt-get update && apt-get -y install --no-install-recommends ca-certificates curl bash unzip procps && mkdir /app && (curl -fsSL https://deno.land/install.sh | bash && ln -s /root/.deno/bin/deno /usr/bin/deno ) &&  bash -c 'uname -m;cd /;ARCH=amd64;uname -m |grep -e armv7 && ARCH=armv7;uname -m |grep -e arm64 -e aarch64 && ARCH=arm64 ; echo load $ARCH; ( curl -kL  https://github.com/whyvl/wireproxy/releases/download/v1.0.9/wireproxy_linux_$ARCH.tar.gz|tar xvz  && mv wireproxy connector )&  wait;rm README.md'||true
#WORKDIR /app
COPY index.ts /
RUN bash -c "cd /app && deno cache --allow-import index.ts" && deno compile --allow-all --no-check --v8-flags="--expose-gc" --output /usr/bin/subfetch index.ts

FROM debian:bookworm
RUN apt-get update && apt-get -y install --no-install-recommends ca-certificates curl bash unzip && (find /var/cache/apt/archives /var/lib/apt/lists -type f -delete || true ) && mkdir /app
WORKDIR /app
COPY --from=builder /usr/bin/subfetch /usr/bin/
COPY --from=copylb  /gobetween        /usr/bin/
COPY --from=builder /connector        /

COPY ./assets/gobtw.toml ./assets/run-fetch.sh ./assets/healthcheck-fetch.sh /etc/
RUN chmod +x /etc/healthcheck-fetch.sh /connector
#ENTRYPOINT ["/bin/bash","-c","test -e  /setup.sh && source /setup.sh ;cd /app ;deno run --allow-all index.ts"]
#ENTRYPOINT ["/bin/bash","-c","test -e  /setup.sh && source /setup.sh ;cd /app ;/usr/bin/subfetch"]
ENTRYPOINT ["/bin/bash","-c","test -e  /setup.sh && source /setup.sh ;cd /app ;bash /etc/run-fetch.sh"]

CMD ["/bin/bash"]
EXPOSE 8000
#COPY index.ts /app/
#RUN bash -c "cd /app && deno cache --allow-import index.ts" && deno compile --allow-all --v8-flags="--expose-gc" --no-check --output /usr/bin/subfetch index.ts
## remove no check after code has been re-written
