# deno-subfetch


### Netlify

* deploy via git..
* set `API_KEY`

### Deno Deploy
* deploy via git..
* set `API_KEY`

### Cloudflare
* create a .denoflare from the example and set `API_KEY` in there
* then use denoflare ( note: your woker will be named main unless you change that )
 ```
 deno install --global --allow-import=denopkg.com:443,jsr.io:443,cdn.skypack.dev:443,raw.githubusercontent.com:443,deno.land:443  --allow-write --unstable-worker-options --allow-read --allow-net --allow-env --allow-run   --name denoflare --force https://raw.githubusercontent.com/skymethod/denoflare/3a875145982d0b288dd864cb2ef1e00552b59cae/cli/cli.ts
 
 echo ##testing
 denoflare serve main --bundle 'backend=module'

 echo #deploy
 denoflare push main --bundle 'backend=module'
 
 ```

## deno serve ( untested )
```
deno run --port $RANDOM -A index.ts
```

## deno serve ( untested )
```
deno serve --port $RANDOM -A index_as_module.ts
```

example with logging fallback for debian openbsd etc. where otlp does not properly work , use the attached script and set it up like e.g. in the following part
```
#/bin/bash 
echo 'export OTEL_EXPORTER_OTLP_ENDPOINT=https://your-logger/ ;export OTEL_EXPORTER_OTLP_METRICS_ENDPOINT=https://your-logger/;export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=https://your-logger/;export OTEL_DENO=true;export OTEL_DENO_CONSOLE=replace;export OTEL_SERVICE_NAME=fetch;export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Basic acbdef1234567890";export API_KEY=youtAPIKey111;' >  ~/domains/your-domain.lan/exports.tmp
( screen -ls |grep    ftch |grep Dead -q && screen -wipe &>/dev/null ) 
screen -ls |grep -q ftch               || screen -dmS ftch bash -c 'cd ~/domains/your-domain.lan/ ;test -e exports.tmp && echo exports found && source exports.tmp && rm exports.tmp & export API_KEY=yourAPIKey;export PORT=$(/usr/local/hoster-tool/bin/hoster-tool port list|grep -e deno -e dno |cut -d" " -f1|head -n1);deno run --allow-import --allow-net   --allow-env index.ts 2>&1 | bash otl_snd.sh'

```