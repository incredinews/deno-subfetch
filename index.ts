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
        try {
            //const json = await req.body.json()
            const json=JSON.parse( await req.text())
            console.log(json);
            //console.log(await githubResponse())
            if(json.urls) {
                let urllist=json.urls
                for (const idx in urllist) {
                   console.log(urllist[idx])
                   //console.log('SHA2-256 of '+urllist[idx], sha256(urllist[idx], "utf8", "hex"))

                }
            }
            return new Response(JSON.stringify(json))
        } catch(e) {
            console.log("err+not+json")
        }

    }
    return new Response("Hello World") 
    }

);
