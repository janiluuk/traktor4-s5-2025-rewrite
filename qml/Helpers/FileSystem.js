// INFO: We can't use require or imports because we are not running JS in a NodeJS or a browser environment
// https://doc.qt.io/qt-6/qtqml-javascript-hostenvironment.html

// We would need to create a C++ function, and attach to it, but it doesn't seem possible...
// So... in order to write files, we are limitted to XHR requests, which is not ideal, but it works
// ! We can't write files to non-existing folders, we need to create them first, but we can't do that with XHR requests
// https://stackoverflow.com/questions/17882518/reading-and-writing-files-in-qml-qt

/*
// import fs from 'fs'
// import * as path from 'path'
function open(filename) {
    // const fs = require('fs');
    // const path = require('path');

    // const tsi = fs.readFileSync(path.join(directory, filename), 'utf8');
    // console.log(tsi);
    // const tsiLines = tsi.split(/\r?\n/);
}
*/

function normalizedPath(path) {
    // INFO: Normalize path to a format that can be used on both macOS and Windows systems.

    // Windows
    if (/^[a-z]:[\\/](?:[a-z0-9]+[\\/])*/i.test(path)) {
        // Replace backslashes with forward slashes and add trailing slash if needed
        return `${path.replace(/\\/g, '/')}${path.endsWith('/') ? '' : '/'}`;
    }

    // macOS
    else {
        // Replace colons with slashes and add leading and trailing slashes if needed
        path = path.replace(/:/g, '/');
        // if (!path.startsWith("/")) path = `Volumes/${path}`
        return `${path}${path.endsWith('/') ? '' : '/'}`;
    }
}

function filePath(rootPath, filename) {
    // INFO: Normalize file path to a format that can be used on both macOS and Windows systems.
    let filePath = rootPath;

    // Windows
    if (/^[a-z]:[\\/](?:[a-z0-9]+[\\/])*/i.test(filePath)) {
        // Replace backslashes with forward slashes, add "file:///" prefix, and encode filename
        filePath = `file:///${filePath.replace(/\\/g, '/')}${
            filePath.endsWith('/') ? '' : '/'
        }${encodeURIComponent(filename)}`;
    }

    // macOS
    else {
        // Replace colons with slashes, add "file:///" prefix if needed, and encode filename
        filePath = filePath.replace(/:/g, '/');
        if (!filePath.startsWith('/')) filePath = `file:///Volumes/${filePath}`;
        filePath = `${filePath}${
            filePath.endsWith('/') ? '' : '/'
        }${encodeURIComponent(filename)}`;
    }

    return filePath;
}

/*
function exists(path) {
    const request = new XMLHttpRequest();
    request.open("HEAD", path, false);
    request.timeout = 10000; // 10 seconds
    request.ontimeout = function() {
        throw new Error("The file we are trying to open is taking too long to load...");
    }
    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            // console.log("File exists:", request.status === 200)
            return request.status === 200;
        }
    }
    request.onerror = function() {
        throw new Error("An error occured while loading the file...");
    }
    request.send();
    return request.status === 200;
}
*/

function exists(path) {
    return new Promise((resolve, reject) => {
        const request = new XMLHttpRequest();
        request.open('HEAD', path);
        request.onreadystatechange = function () {
            if (request.readyState === XMLHttpRequest.DONE) {
                // console.log("Status:", request.status)
                if (request.status === 200) {
                    resolve(true);
                } else {
                    resolve(false);
                }
            }
        };
        request.onerror = function () {
            reject(new Error('An error occurred while loading the file...'));
        };
        request.timeout = 10000; // 10 seconds
        request.ontimeout = function () {
            reject(
                new Error(
                    'The file we are trying to open is taking too long to load...'
                )
            );
        };
        request.send();
    });
}

function open(path, overrideCheck = false) {
    if (!overrideCheck) {
        return exists(path).then((exists) => {
            if (!exists)
                throw new Error(
                    "The file we are trying to open doesn't exist..."
                );
            return readFileRequest(path);
        });
    } else return readFileRequest(path);
}

function fileSize(bytes) {
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    if (bytes == 0) return '0 Bytes';
    const i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
    return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
}

function writeFile(path, fileName, content, { overwrite = false }) {
    const file = filePath(path, fileName);

    // TODO: Check if folder exists, and create it otherwise
    if (!overwrite)
        return exists(file)
            .then((exists) => {
                if (exists)
                    throw new Error(
                        'The file we are trying to write already exists...'
                    );
                else {
                    console.log(
                        "File doesn't exist, a new file will be created..."
                    );
                    return writeFileRequest(path, fileName, content, overwrite);
                }
            })
            .catch((error) => {
                throw new Error(error);
            });
    return writeFileRequest(path, fileName, content, overwrite);

    /*
    // Write the content to a file
    var file = new Qt.file();
    file.open(path, overwrite ? Qt.file.WriteOnly : Qt.file.Append);
    file.write(content);
    file.close();

    console.log("File write: true")
    console.log("File created! Path:", path);
    return true;
    */
}

function readFileRequest(path) {
    console.log('### Read file request ###');

    return new Promise((resolve, reject) => {
        const request = new XMLHttpRequest();
        request.open('GET', path, false);
        request.onreadystatechange = function () {
            // https://developer.mozilla.org/es/docs/Web/API/XMLHttpRequest
            // https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/readyState
            // https://code.qt.io/cgit/qt/qtdeclarative.git/tree/examples/qml/xmlhttprequest/methods.js?h=6.3
            switch (request.readyState) {
                case XMLHttpRequest.UNSENT: //UNINITIALIZED
                    // console.log("Awaiting for the XML HTTP send request...")
                    return;
                case XMLHttpRequest.OPENED: //LOADING
                    // console.log("Loading file...")
                    return;
                case XMLHttpRequest.HEADERS_RECEIVED: //LOADED
                    // console.log("File has been loaded!")
                    console.log('# File Info #');
                    // console.log("Headers:", request.getAllResponseHeaders());
                    const filename = path.split(/.*[\/|\\]/).slice(-1)[0]; // INFO: Get file name from path variable, no matter if it's a macOS path or a Windows path
                    // INFO: Get container folder from path variable, no matter if it's a macOS path or a Windows path, and remove the file prefix (and Volumes prefix on macOS) from the start of the path
                    const location = path
                        .replace(/\/[^\/]*$/, '')
                        .replace('file:///', '')
                        .replace(/^Volumes\//, '');
                    console.log('Location: ' + location);
                    console.log('File name: ' + filename.replace(/%20/g, ' '));
                    // console.log("File name: " + request.getResponseHeader ("Content-Disposition"));
                    console.log(
                        'File size: ' +
                            fileSize(
                                request.getResponseHeader('Content-Length')
                            )
                    );
                    console.log(
                        'Last mod.: ' +
                            request.getResponseHeader('Last-Modified')
                    );
                    return;
                case XMLHttpRequest.LOADING: //INTERACTIVE
                    // console.log("Processing file content...")
                    return;
                case XMLHttpRequest.DONE: //COMPLETED
                    // console.log("File content has been processed!")
                    console.log('# File Content #');
                    console.log('Content length', request.responseText.length);
                    // console.log("Content:\n", request.responseText)
                    /*
                    switch(request.responseType) {
                        case "":
                            console.log("Response Type: Empty")
                            break;
                        case "arraybuffer":
                            console.log("Response Type: ArrayBuffer")
                            break;
                        case "blob":
                            console.log("Response Type: Blob")
                            break;
                        case "document":
                            console.log("Response Type: Document")
                            console.log("XML Document:", JSON.stringify(request.responseXML))
                            break;
                        case "json":
                            console.log("Response Type: JSON")
                            console.log("JSON:", request.response)
                            break;
                        case "text":
                            console.log("Response Type: Text")
                            console.log("Text:", request.responseText)
                            break;
                        default:
                            console.log("Response Type: Unknown")
                            break;
                    }
                    */
                    return resolve(request.responseText);
                default:
                    return reject(
                        new Error('An error occured while loading the file...')
                    );
            }
        };
        request.onerror = function () {
            reject(new Error('An error occured...'));
        };
        request.onabort = function () {
            reject(new Error('Request aborted...'));
        };
        request.timeout = 10000; // 10 seconds
        request.ontimeout = function () {
            reject(new Error('Request timed out...'));
        };
        request.send();
    });
}

function writeFileRequest(path, fileName, content, overwrite = false) {
    console.log('### Write file request ###');
    console.log('Overwrite:', overwrite);
    // const method = overwrite ? "PUT" : "POST";
    const method = 'PUT'; // ? Only the PUT method seems to work
    console.log('Request Method:', method);

    const file = filePath(path, fileName);
    const folderPath = normalizedPath(path).replace(/\/[^\/]*$/, '');
    console.log('# File Info #');
    console.log('Location:', folderPath);
    console.log('File name:', fileName);
    // console.log("Content:", JSON.stringify(content))

    return new Promise((resolve, reject) => {
        const request = new XMLHttpRequest();
        request.open(method, file, true); // ! The request must be asynchronous, otherwise it won't write the file content to the generated file
        request.onreadystatechange = function () {
            // Return the request ready state in a readable format
            switch (request.readyState) {
                case XMLHttpRequest.UNSENT: //UNINITIALIZED
                    // console.log("[ReadyState - Unsent]")
                    // console.log("Awaiting for the XML HTTP send request...")
                    reject(
                        new Error('An error occured while creating the file...')
                    );
                    return;
                case XMLHttpRequest.OPENED: //LOADING
                    // console.log("[ReadyState - Opened]")
                    // console.log("Creating file...")
                    return;
                case XMLHttpRequest.HEADERS_RECEIVED: //LOADED
                    // console.log("[ReadyState - Headers Received]")
                    // console.log("File info has been created!")
                    // console.log("### File Info ###")
                    // const filename = path.split(/.*[\/|\\]/).slice(-1)[0]; // INFO: Get file name from path variable, no matter if it's a macOS path or a Windows path
                    // const location = path.replace(/\/[^\/]*$/, "").replace("file:///", "").replace(/^Volumes\//, "")
                    // console.log("Location: " + location);
                    // console.log("Name: " + filename); // request.getResponseHeader ("Content-Disposition");
                    // console.log("File size: " + fileSize(request.getResponseHeader ("Content-Length")));
                    // console.log("Last mod.: " + request.getResponseHeader ("Last-Modified"));
                    // console.log("[ReadyState - Headers Received] Response", JSON.stringify(request))
                    // console.log("[ReadyState - Headers Received] Response ready state:", request.readyState)
                    // console.log("[ReadyState - Headers Received] Response status code:", request.status)
                    // console.log("[ReadyState - Headers Received] Response status text:", request.statusText)
                    // console.log("[ReadyState - Headers Received] Response Text:", request.responseText)
                    // console.log("[ReadyState - Headers Received] Response Type:", request.responseType)
                    // console.log("[ReadyState - Headers Received] Response URL:", request.responseURL)
                    // console.log("[ReadyState - Headers Received] Response XML:", request.responseXML)
                    // console.log("[ReadyState - Headers Received] Upload:", JSON.stringify(request.upload))
                    // console.log("[ReadyState - Headers Received] Headers:", request.getAllResponseHeaders())
                    return;
                case XMLHttpRequest.LOADING: //INTERACTIVE
                    // console.log("[ReadyState - Loading]")
                    // console.log("Processing file content...")
                    return;
                case XMLHttpRequest.DONE: //COMPLETED
                    // console.log("[ReadyState - Done]")
                    // console.log("File content has been processed!")
                    const created =
                        request.status === 0 ||
                        request.status === 200 ||
                        request.status === 201;
                    // console.log("File written succesfully:", created)
                    // console.log("[ReadyState - Done] Response", JSON.stringify(request))
                    // console.log("[ReadyState - Done] Response ready state:", request.readyState)
                    // console.log("[ReadyState - Done] Response status code:", request.status)
                    // console.log("[ReadyState - Done] Response status text:", request.statusText)
                    // console.log("[ReadyState - Done] Response Text:", request.responseText)
                    // console.log("[ReadyState - Done] Response Type:", request.responseType)
                    // console.log("[ReadyState - Done] Response URL:", request.responseURL)
                    // console.log("[ReadyState - Done] Response XML:", request.responseXML)
                    // console.log("[ReadyState - Done] Upload:", JSON.stringify(request.upload))
                    // console.log("[ReadyState - Done] Headers:", request.getAllResponseHeaders())
                    return resolve(created);
                default:
                    return reject(
                        new Error('An error occured while creating the file...')
                    );
            }
        };
        request.onload = function () {
            // const created = request.status === 0 || request.status === 200 || request.status === 201;
            // console.log("[OnLoad] File written:", created)
            // console.log("[OnLoad] Response", JSON.stringify(request))
            // console.log("[OnLoad] Response ready state:", request.readyState)
            // console.log("[OnLoad] Response status code:", request.status)
            // console.log("[OnLoad] Response status text:", request.statusText)
            // console.log("[OnLoad] Response Text:", request.responseText)
            // console.log("[OnLoad] Response Type:", request.responseType)
            // console.log("[OnLoad] Response URL:", request.responseURL)
            // console.log("[OnLoad] Response XM:L", request.responseXML)
            // console.log("[OnLoad] Upload:", JSON.stringify(request.upload))
            // console.log("[OnLoad] Headers:", request.getAllResponseHeaders())
        };
        request.onloadstart = function () {
            // console.log("[OnLoadStart] Response", JSON.stringify(request))
            // console.log("[OnLoadStart] Response ready state:", request.readyState)
            // console.log("[OnLoadStart] Response status code:", request.status)
            // console.log("[OnLoadStart] Response status text:", request.statusText)
            // console.log("[OnLoadStart] Response Text:", request.responseText)
            // console.log("[OnLoadStart] Response Type:", request.responseType)
            // console.log("[OnLoadStart] Response URL:", request.responseURL)
            // console.log("[OnLoadStart] Response XM:L", request.responseXML)
            // console.log("[OnLoadStart] Upload:", JSON.stringify(request.upload))
            // console.log("[OnLoadStart] Headers:", request.getAllResponseHeaders())
        };
        request.onloadend = function () {
            // console.log("[OnLoadEnd] Response", JSON.stringify(request))
            // console.log("[OnLoadEnd] Response ready state:", request.readyState)
            // console.log("[OnLoadEnd] Response status code:", request.status)
            // console.log("[OnLoadEnd] Response status text:", request.statusText)
            // console.log("[OnLoadEnd] Response Text:", request.responseText)
            // console.log("[OnLoadEnd] Response Type:", request.responseType)
            // console.log("[OnLoadEnd] Response URL:", request.responseURL)
            // console.log("[OnLoadEnd] Response XML", request.responseXML)
            // console.log("[OnLoadEnd] Upload:", JSON.stringify(request.upload))
            // console.log("[OnLoadEnd] Headers:", request.getAllResponseHeaders())
            /*
            switch(request.responseType) {
                case "":
                    console.log("[OnLoadEnd] Response Type: Empty")
                    break;
                case "arraybuffer":
                    console.log("[OnLoadEnd] Response Type: ArrayBuffer")
                    break;
                case "blob":
                    console.log("[OnLoadEnd] Response Type: Blob")
                    break;
                case "document":
                    console.log("[OnLoadEnd] Response Type: Document")
                    console.log("XML Document:", request.responseXML)
                    break;
                case "json":
                    console.log("[OnLoadEnd] Response Type: JSON")
                    console.log("JSON:", request.response)
                    break;
                case "text":
                    console.log("[OnLoadEnd] Response Type: Text")
                    console.log("Text:", request.responseText)
                    break;
                default:
                    console.log("[OnLoadEnd] Response Type: Unknown")
                    break;
            }
            */
        };
        request.onerror = function () {
            reject(new Error('An error occured...'));
        };
        request.onabort = function () {
            reject(new Error('Request aborted...'));
        };
        request.timeout = 10000; // 10 seconds
        request.ontimeout = function () {
            reject(new Error('Request timed out...'));
        };

        switch (typeof content) {
            case 'string':
            case 'number':
            case 'boolean':
                // request.setRequestHeader("Content-Type", "text/plain");
                request.send(content);
                break;
            case 'object':
                // request.setRequestHeader("Content-Type", "application/json");
                request.send(JSON.stringify(content, null, 4));
                break;
            case 'undefined':
                request.send();
                break;
            default:
                break;
        }
    });
}

function updateContent(path, content) {
    // Check if the file exists
    if (!exists(path)) {
        console.log("File exists response: Doesn't exist!");
        console.log('Searched path:', path);
        throw new Error("The file we are trying to open doesn't exist...");
    }

    // Write the file's content
    console.log('Update Content:', content);
    writeFile(path, content, { overwrite: true });
}
