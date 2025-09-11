#!/usr/bin/env  DENO_DIR=/tmp --version 2.1.7 --location http://example.com/fetch  deno run -A

import * as fflate   from 'https://cdn.skypack.dev/fflate@0.8.2?min';
import { format }    from "https://deno.land/std@0.91.0/datetime/mod.ts";
import { sha256 }    from "https://denopkg.com/chiefbiiko/sha256@v1.0.0/mod.ts";
//import { parseFeed } from "https://deno.land/x/rss/mod.ts";
//import { parseFeed } from "jsr:@mikaelporttila/rss@*";
//import { parseFeed } from "https://jsr.io/@mikaelporttila/rss/1.1.1/mod.ts";
import { parseFeed } from "../netlify/edge-functions/deno_rss_1.1.1/mod.ts";



const fetchResponse = async (myurl: string,dsturl: string,onlysave: boolean,parse_feed: boolean): Promise<any> => {
    //console.log("thread for " + myurl)
    const response = await fetch(myurl, {
        method: "GET",
        //headers: {
        //    "Content-Type": "application/json",
        //},
    });
    //let myres=response.json()
    let returnres={
        "url": myurl,
        "status":    response.status,
        "statusText": response.statusText,
        "redirected": response.redirected,
        "headers": {}
    }
    let usehdr=["cache-control","conten-type","date","x-robots-tag","x-generated-by","x-content-type-options"]
    response.headers.forEach((value, key) => {
        //console.log(`${key} ==> ${value}`);
        if(usehdr.includes(key)) {
        returnres["headers"][key]=value } 
      });
    //console.log(returnres)
    returnres["content"]=await response.text()
    returnres["time_fetched"]=format(new Date(),"yyyy-MM-dd_HH.mm",{ utc: true })
    if(dsturl!="dontsave") {
        let savename=sha256(myurl, "utf8", "hex")+"_"+returnres["time_fetched"]+".json.gz"
        //console.log("saving "+myurl+" AS "+savename)
       if (Deno.env.get("DEBUG") == "true") {
                console.log("saving to: "+savename)
        }
        try {
           //const buf = fflate.strToU8(JSON.stringify(returnres));
           //// The default compression method is gzip
           //// Increasing mem may increase performance at the cost of memory
           //// The mem ranges from 0 to 12, where 4 is the default
           //const compressed = fflate.compressSync(buf, { level: 6, mem: 8 });
           const compressed = fflate.compressSync(fflate.strToU8(JSON.stringify(returnres)), { level: 6, mem: 8 });
           if (Deno.env.get("DEBUG") == "true") {
               await console.log("saving "+myurl+" to "+savename)
           }
           let sendtourl=dsturl+savename
           const uploadres=await fetch(sendtourl, {
            method: 'PUT',
            body: compressed
          })
          const okay_status=[200,201]
          if(okay_status.includes(uploadres.status)) {
            returnres.stored=true
            returnres.storepath=sendtourl.split("@")[1]
          } else {
            console.log("ERROR: uploaded "+savename+" status:"+uploadres.status)
          }
        } catch(e) {
            returnres.stored=false
            await console.log("ERROR SAVING "+ myurl + " TO ... POST  : " + e )
        }
    }
    if(parse_feed) {
        try {
            returnres.feed = await parseFeed(returnres.content);

        } catch (error) {
            
        }

    }
    if(onlysave) { delete returnres.content }
    return returnres;
    //return response.json(); // For JSON Response
    //   return response.text(); // For HTML or Text Response
}
const port = parseInt(Deno.env.get('PORT') ?? '8000')
Deno.serve({ hostname: '0.0.0.0', port: port }, async (req: Request) =>  { 
    if (req.method === "POST") {
        let mytoken= Deno.env.get("API_KEY")
        let returnobj={}
        if(!mytoken||mytoken=="NOT_SET") {
            returnobj.status="ERR"
            returnobj.msg="NO_API_KEY"
            returnobj.msg_detail="set API_KEY environment variable to proceed"
            return new Response(JSON.stringify(returnobj))
        }
        if(req.headers.get("API-KEY")!=mytoken) {
            returnobj.status="ERR"
            returnobj.msg="UNAUTHORIZED"
            returnobj.msg_detail="send the HTTP-header API-KEY matching your API_KEY environment variable to proceed"

            return new Response(JSON.stringify(returnobj))  
        }
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
        // do we return only status or full content
        let save_only=false
        let saveurl="dontsave"
        if(json.save_only) { save_only=true }
        let parse_feed=false
        if(json.parse_feed) { parse_feed=true }
        if(json.saveurl)   { 
            saveurl=json.saveurl
            if(!saveurl.endsWith("/")) {saveurl=saveurl+"/"}
            let targetpath="feedarchive/"+format(new Date(), "yyyy-MM-dd_HH",{ utc: true })+"/"

            const accepted_status=[201,401,409,405]
            const accepted_propfn=[200,207]
            //verify folder existence
            let logstr=targetpath+" | "
            const foldcheckres = await fetch(saveurl+targetpath, {
                method: "PROPFIND",
                headers: { "Depth": 1 }
              });
            if(accepted_propfn.includes(foldcheckres.status)) {
                if (Deno.env.get("DEBUG") == "true") {
                    console.log("save_enabled_foldcheck_status:"+logstr+" "+foldcheckres.status)
                } else {
                    logstr=logstr+foldcheckres.status
                }
                saveurl=saveurl+targetpath
            } else {
                console.log("MAKE FOLDER "+targetpath + " (foldcheck_status:"+foldcheckres.status+") ")
                const foldresponse = await fetch(saveurl+targetpath, {
                    method: "MKCOL",
                  });
                
                if(accepted_status.includes(foldresponse.status)) {
                    if (Deno.env.get("DEBUG") == "true") {
                       console.log("save_enabled_foldcreate_status:"+foldresponse.status)
                    }
                    saveurl=saveurl+targetpath
                } else {
                    if (Deno.env.get("DEBUG") == "true") {
                        console.log("save_disabled_foldcreate_status:"+foldresponse.status)
                    }
                    saveurl="dontsave"
                    if(save_only) {
                        return new Response("ERROR_from_fetch POST : MKCOL_FAILED_"+foldresponse.status, {
                            headers: { "content-type": "text/html" },
                          });
                    }
                }
            }
        }
        if(json.urls) {
            let urllist=json.urls
            let rawresults=[]
            let workers=[]
            let workercount=5
            let all_sent=0
            let all_success=0
            let all_rejected=0
            //for (let i = 0; i < workercount; i++) {
                // no web workers with deno deploy ...
                ///const worker = new Worker(import.meta.resolve("./worker.ts")", { type: "module"});
                ///
                ///workers.push(worker);
                ///worker.onmessage = (evt) => { 
                ///  console.log("Received by parent: ", evt.data);
                ///  rawresults.push(JSON.parse(evt.data)) };
                ///}
                const chunkSize = workercount;
                let urlchunks=[]
                for (let i = 0; i < urllist.length; i += chunkSize) {
                    const chunk = urllist.slice(i, i + chunkSize);
                    urlchunks.push(chunk)
                }
                for (const batch in urlchunks) {
                    let mybatch=urlchunks[batch]
                    console.log("sendbatch: "+mybatch.length )
                    //console.log(mybatch)
                    let requests: Promise<any>[] = [];
                    let fulfilled: number = 0;
                    let rejected: number = 0;
                    for (const sendx in mybatch) {
                        requests.push(fetchResponse(mybatch[sendx],saveurl,save_only,parse_feed));
                    }
                    await Promise.allSettled(requests).then((results) => {
                        results.forEach((result) => {
//                            console.log("haveres")
//                            console.log(result)
                          if(result.status == 'fulfilled') fulfilled++;
                          if(result.status == 'fulfilled') all_success++;
                          if(result.status == 'rejected') {
                            rejected++;
                            all_rejected++;
                            console.log(result)
                          } 
                          if(result.status == 'fulfilled' && result.value ) {
                            rawresults.push(result.value)
                          }
                        });
                        console.log('++++ Requests:  Fulfilled:', fulfilled ,' / ', results.length + ' |  Rejected: ', rejected, ' ++++');                      
                    })

            }
            //console.log('SHA2-256 of '+urllist[idx], sha256(urllist[idx], "utf8", "hex"))
            ///let counter=0
            ///for (const idx in urllist) {
            ///   let urlhash=sha256(urllist[idx], "utf8", "hex")
            ///   console.log("q -+->"+urllist[idx])
            ///   workers[counter%workercount].postMessage(urllist[idx])
            ///   counter=counter+1
            ///}
        //}
        returnobj.status="OK"
        returnobj.msg="DONE"
        returnobj.results=rawresults
        return new Response(JSON.stringify(returnobj))
    }
    return new Response("Hello_from_fetch POST", {
        headers: { "content-type": "text/html" },
      });
    }
return new Response("Hello_from_fetch GET", {
    headers: { "content-type": "text/html" },
  });
});
