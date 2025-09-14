#FROM alpine
#RUN apk add bash ca-certificates curl grep sed && mkdir /app && (curl -fsSL https://deno.land/install.sh | bash && ln -s /root/.deno/bin/deno /usr/bin/deno )

FROM yyyar/gobetween AS copylb

FROM debian:bookworm AS builder
RUN apt-get update && apt-get -y install --no-install-recommends ca-certificates curl bash unzip && mkdir /app && (curl -fsSL https://deno.land/install.sh | bash && ln -s /root/.deno/bin/deno /usr/bin/deno )
#WORKDIR /app
COPY index.ts /
RUN bash -c "cd /app && deno cache --allow-import index.ts" && deno compile --allow-all --no-check --v8-flags="--expose-gc" --output /usr/bin/subfetch index.ts

FROM debian:bookworm
RUN apt-get update && apt-get -y install --no-install-recommends ca-certificates curl bash unzip && (find /var/cache/apt/archives /var/lib/apt/lists -type f -delete || true ) && mkdir /app
WORKDIR /app
COPY --from=builder /usr/bin/subfetch /usr/bin/
COPY --from=copylb  /gobetween        /usr/bin/

COPY ./assets/gobtw.toml ./assets/run-fetch.sh ./assets/healthcheck-fetch.sh /etc/
RUN chmod +x /etc/healthcheck-fetch.sh 
#ENTRYPOINT ["/bin/bash","-c","test -e  /setup.sh && source /setup.sh ;cd /app ;deno run --allow-all index.ts"]
#ENTRYPOINT ["/bin/bash","-c","test -e  /setup.sh && source /setup.sh ;cd /app ;/usr/bin/subfetch"]
ENTRYPOINT ["/bin/bash","-c","test -e  /setup.sh && source /setup.sh ;cd /app ;bash /etc/run-fetch.sh"]

CMD ["/bin/bash"]
EXPOSE 8000
#COPY index.ts /app/
#RUN bash -c "cd /app && deno cache --allow-import index.ts" && deno compile --allow-all --v8-flags="--expose-gc" --no-check --output /usr/bin/subfetch index.ts
## remove no check after code has been re-written
