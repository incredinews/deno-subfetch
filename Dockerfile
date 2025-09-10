FROM alpine
RUN apk add bash curl deno grep sed && mkdir /app
COPY index.ts /app/
RUN bash -c "cd /app && deno cache --allow-all index.ts"
