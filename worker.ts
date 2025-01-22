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
self.onmessage = async (e) => {
  const { myurl } = e.data;
  const myres=await fetchResponse(myurl)
  const mystr=JSON.stringify(myres)
  console.log(mystr);
  self.postMessage({ data: mystr });
  self.close();
};
