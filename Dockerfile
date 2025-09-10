FROM alpine
RUN apk add bash curl deno grep sed && mkdir /app
COPY index.ts /app/
RUN bash -c "cd /app && deno cache --allow-import index.ts"
ENTRYPOINT ["/bin/bash","-c","test -e  /setup.sh && source /setup.sh ;cd app ;deno run --allow-all index.ts"]
CMD ["/bin/bash"]
