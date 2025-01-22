import { sha256 } from "https://denopkg.com/chiefbiiko/sha256@v1.0.0/mod.ts";

const fetchResponse = async (): Promise<any> => {
    const response = await fetch(url, {
        method: "GET",
        //headers: {
        //    "Content-Type": "application/json",
        //},
    });
    return response.json(); // For JSON Response
    //   return response.text(); // For HTML or Text Response
}

Deno.serve( async (req: Request) =>  { 
    if (req.method === "POST") {
        //console.log(await req.body)
        const inbody=await req.text()
        let json={}
        try {
            //const json = await req.body.json()
            json=JSON.parse(inbody)

        } catch(e) {
            console.log("err+not+json")
            console.log(inbody)
        }
        //console.log(json);
        //console.log(await githubResponse())
        if(json.urls) {
            let urllist=json.urls
            let rawresults=[]
            let workers=[]
            let workercount=5
            for (let i = 0; i < workercount; i++) {
                // no web workers with deno deploy ...
                ///const worker = new Worker(import.meta.resolve("./worker.ts")", { type: "module"});
                ///
                ///workers.push(worker);
                ///worker.onmessage = (evt) => { 
                ///  console.log("Received by parent: ", evt.data);
                ///  rawresults.push(JSON.parse(evt.data)) };
                ///}
                const chunkSize = 10;
                let urlchunks=[]
                for (let i = 0; i < array.length; i += chunkSize) {
                    const chunk = array.slice(i, i + chunkSize);
                    urlchunks.push(chunk)
                    // do whatever
                }
                for (const batch in urlchunks) {
                    console.log(urlchunks[batch])
                    
                }
            //console.log('SHA2-256 of '+urllist[idx], sha256(urllist[idx], "utf8", "hex"))
            let counter=0
            for (const idx in urllist) {
               let urlhash=sha256(urllist[idx], "utf8", "hex")
               console.log("q -+->"+urllist[idx])
               workers[counter%workercount].postMessage(urllist[idx])
               counter=counter+1
            }
        }
        return new Response(JSON.stringify(json))
    }
    return new Response("Hello World") 
    }

);
