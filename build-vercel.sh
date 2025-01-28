cp -r netlify/edge-functions api
( echo '#!/usr/bin/env  DENO_DIR=/tmp --location http://example.com/fetch  deno run -A'
echo
cat api/fetch.tsx ) > tmp.tsx
cat tmp.tsx > api/fetch.ts
