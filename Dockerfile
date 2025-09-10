#FROM alpine
#RUN apk add bash ca-certificates curl grep sed && mkdir /app && (curl -fsSL https://deno.land/install.sh | bash && ln -s /root/.deno/bin/deno /usr/bin/deno )
FROM debian:bookworm
RUN apt-get update && apt-get -y install --no-install-recommends ca-certificates curl bash unzip && mkdir /app && (curl -fsSL https://deno.land/install.sh | bash && ln -s /root/.deno/bin/deno /usr/bin/deno )
WORKDIR /app
ENTRYPOINT ["/bin/bash","-c","test -e  /setup.sh && source /setup.sh ;cd /app ;deno run --allow-all index.ts"]
CMD ["/bin/bash"]
EXPOSE 8000
COPY index.ts /app/
RUN bash -c "cd /app && deno cache --allow-import index.ts"
