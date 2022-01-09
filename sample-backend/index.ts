import http from 'http';
import url from "url";
import fs from 'fs';
import { URLSearchParams } from 'url';

let mime : any = {
    html: 'text/html',
    txt: 'text/plain',
    css: 'text/css',
    gif: 'image/gif',
    jpg: 'image/jpeg',
    png: 'image/png',
    svg: 'image/svg+xml',
    js: 'application/javascript'
};

const server = new http.Server((request : http.IncomingMessage, response : http.ServerResponse) => {
    let path = request.url + ""; //convert it into a string lol
    
    path = path.replace("../", "");

    console.log("request gotten for: ", path);

    if (path.startsWith("/hasPackage")) {
        let params = new URL("http://localhost:5978" + path);
        let packageQuery = params.searchParams.get("package");
        
        console.log("Asked if we have \"" + "./packages/" + packageQuery + "\"")
           
        if (packageQuery != null) {
            response.writeHead(200);
            if (fs.existsSync("./packages/" + packageQuery)) {
                response.write("yes");
            } else {
                response.write("no");
            }
            response.end();
        } else {
            response.writeHead(200);
            response.write("no");
            response.end();
        }
    } else if (path.startsWith("/download")) {
        var file = "." + request.url?.replace("/download", "/packages");
        response.statusCode = 200;
        try {
            var type = mime[require('path').extname(file).slice(1)] || 'text/plain';
            var s = fs.createReadStream(file);
            s.on('open', function () {
                response.setHeader('Content-Type', type);
                s.pipe(response);
            });
            s.on('error', function () {
                response.write("fail to send");        
            });
        } catch (error) {
            response.write("not found bruh");
            console.log(error);
            response.end();
        }
    } else {
        response.writeHead(200);
        response.write("not found bruh");
        response.end();
    }
});

console.log("starting server");
server.listen(5978)
