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