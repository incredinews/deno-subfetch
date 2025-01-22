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
        try {
            //const json = await req.body.json()
            const json=JSON.parse(inbody)

        } catch(e) {
            console.log("err+not+json")
            console.log(inbody)
        }
        //console.log(json);
        //console.log(await githubResponse())
        if(json.urls) {
            let urllist=json.urls
            let urlhash=sha256(urllist[idx], "utf8", "hex")
            let rawresults=[]
            let workers=[]
            let workercount=5
            for (let i = 0; i < workercount; i++) {
                const worker = new Worker("./worker.ts", {
                  type: "module",
                });
                workers.push(worker);
               worker.onmessage = (evt) => {console.log("Received by parent: ", evt.data);JSON.parse(evt.data)};
              }
            //console.log('SHA2-256 of '+urllist[idx], sha256(urllist[idx], "utf8", "hex"))
            let counter=0
            for (const idx in urllist) {
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
