// REST client library.
// Version 2:
// 'status' on callbacks is optional second argument.
// POST no longer includes dom in callback.
// -----------------------------------------------------------------------------
// This library builds upon lib2.js to provide basic REST functionality
// to browser-side applications.

// Construct a REST connection object.
function REST()
{
    // XMLHttpRequest factory from lib.js.
    this._xmlhttp = new xbInitRequest();
}

// Initiate a REST call.
function REST_call(url, method, payload, contentType)
{
    var instance = this;
    var xmlHint = false;

    this._xmlhttp.open(method, url, true); // async
    this._xmlhttp.setRequestHeader("If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT");
//    alert(url + " " + contentType);
    if (contentType)
	this._xmlhttp.setRequestHeader("Accept", contentType);
    if (method == 'POST' || method == 'PUT')
 	this._xmlhttp.setRequestHeader("Content-Type",
 				       "application/x-www-form-urlencoded");
    this._xmlhttp.onreadystatechange = function() {
	switch (instance._xmlhttp.readyState)
	{
	case 1:
	instance.loading();
	break;
	case 2:
	instance.loaded();
	break;
	case 3:
	instance.interactive();
	break;
	case 4:
//	alert(instance._xmlhttp.getAllResponseHeaders());
//	alert(url);
//	alert(instance._xmlhttp.getResponseHeader("Content-Type"));
//	alert("? " + instance._xmlhttp.getResponseHeader("Content-Type").search("xml"))
	if (instance._xmlhttp.getResponseHeader("Content-Type").search("xml") >= 0)
	    xmlHint = true;
	instance.complete(instance._xmlhttp.status,
			  instance._xmlhttp.statusText,
			  instance._xmlhttp.responseText,
			  instance._xmlhttp.responseXML,
			  xmlHint);
	break;
	}
    }
    this._xmlhttp.send(payload);
}

// Status change event handlers.
function REST_loading() { };
function REST_loaded() { };
function REST_interactive() { };
function REST_complete(status, statusText, responseText, responseXML, xmlHint) { };

// Attach event handlers to REST class.
REST.prototype.loading = REST_loading;
REST.prototype.loaded = REST_loaded;
REST.prototype.interactive = REST_interactive;
REST.prototype.complete = REST_complete;
REST.prototype.call = REST_call;

// -----------------------------------------------------------------------------
// HTTP status codes:
// 200 OK - result returned
// 201 Created - resource id returned, URL in 'Location' header
// 204 No Content - nothing returned
// -----------------------------------------------------------------------------

// GET a REST resource.
// callback: response, status
function restGet(url, callback, contentType)
{
    var rest = new REST();
    rest.complete = function(status, statusText, responseText, responseXML, xmlHint) {
	checkStatus(status, url);
	if (callback)
	{
//	    alert('xml: ' + responseXML + ' text: ' + responseText);
	    try
	    {
		if (responseXML && xmlHint)
		{
//		    alert('xml ' + responseXML);
		    if ((isIE() && responseXML.parseError != 0) ||
		    	(responseXML.documentElement.tagName == "parsererror"))
		    	restError("RLG malformed xml ", url, statusText);
		    else		
		        callback(responseXML, status);
		}
		else if (responseText && !xmlHint)
		{
//		    alert('text ' + responseText);
		    callback(responseText, status);
		}
		else
		{
/*
		    alert(responseText);
		    alert(responseXML);
		    alert(xmlHint);
		    alert(callback);
*/
		    restError("RLG empty response (" + xmlHint + ")", url, status);
		}
	    }
	    catch (e)
	    {
		callbackError(e);
	    }
	}
    }
    rest.call(url, 'GET', false, contentType);
}

// POST to a REST resource.
// callback: location, status
function restPost(url, callback, data)
{
    var rest = new REST();
    rest.complete = function(status, statusText, responseText, responseXML) {
	checkStatus(status, url);
	if (callback)
	    callback(this._xmlhttp.getResponseHeader("Location"), status);
    }
    rest.call(url, 'POST', data);
}

// PUT to a REST resource.
// callback: status
function restPut(url, callback, data)
{
    var rest = new REST();
    rest.complete = function(status, statusText, responseText, responseXML) {
	checkStatus(status, url);
	if (callback)
	    callback(status);
    }
    rest.call(url, 'PUT', data);
}

// DELETE a REST resource.
// callback: status
function restDelete(url, callback)
{
    var rest = new REST();
    rest.complete = function(status, statusText, responseText, responseXML) {
	checkStatus(status, url);
	if (callback)
	    callback(status);
    }
    rest.call(url, 'DELETE');
}

// Make sure REST/HTTP status codes fall within normal range.
function checkStatus(status, url)
{
    switch (status)
    {
    case 200:			// OK
//	alert("OK");
	break;
    case 201:			// Created
//	alert("Created");
	break;
    case 202:			// Accepted
//	alert("Accepted");
	break;
    case 204:			// No Content
    case 1223:			// IE version
//	alert("No content");
	break;
    case 500:			// Internal server error
	restError("Application error", url, status);
	break;
    default:
	restError("Unknown REST status", url, status);
	break;
    }
}
