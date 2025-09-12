#FROM alpine
#RUN apk add bash ca-certificates curl grep sed && mkdir /app && (curl -fsSL https://deno.land/install.sh | bash && ln -s /root/.deno/bin/deno /usr/bin/deno )


FROM debian:bookworm AS builder
RUN apt-get update && apt-get -y install --no-install-recommends ca-certificates curl bash unzip && mkdir /app && (curl -fsSL https://deno.land/install.sh | bash && ln -s /root/.deno/bin/deno /usr/bin/deno )
RUN bash -c "cd /app && deno cache --allow-import index.ts" && deno compile --allow-all --no-check --output /usr/bin/subfetch index.ts

FROM debian:bookworm
RUN apt-get update && apt-get -y install --no-install-recommends ca-certificates curl bash unzip
WORKDIR /app
COPY --from=builder /usr/bin/subfetch /usr/bin
#ENTRYPOINT ["/bin/bash","-c","test -e  /setup.sh && source /setup.sh ;cd /app ;deno run --allow-all index.ts"]
ENTRYPOINT ["/bin/bash","-c","test -e  /setup.sh && source /setup.sh ;cd /app ;/usr/bin/subfetch"]

CMD ["/bin/bash"]
EXPOSE 8000
COPY index.ts /app/
#RUN bash -c "cd /app && deno cache --allow-import index.ts" && deno compile --allow-all --no-check --output /usr/bin/subfetch index.ts
## remove no check after code has been re-written