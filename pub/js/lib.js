// General purpose web app functions.
// Version 2:
// remove unused functions, add a few new ones.

// node operations -------------------------------------------------------------

// Get element.
function $(id)
{
    return document.getElementById(id);
}

// Create element.
function _e(type, id)
{
    var el;

    if (isIE())
	el = document.createElement(type);
    else
	el = document.createElement(type);
    if (id)
	el.id = id;
     return el;
}

// Create text node.
function _t(text)
{
    return document.createTextNode(text);
}

// Remove all children of node.
function _removeChildren(node)
{
    var div = node.firstChild;
    while (div != null)
    {
	var div2 = div.nextSibling;
	node.removeChild(div);
	div = div2;
    }
}

// transforms ----------------------------------------------------------------

// Transform xml source S with xsl node X into destination D.
function _transformNode(s, x, d)
{
    if (!s)
    {
	alert("RLG: null source");
	return;
    }
    if (!x)
    {
	alert("RLG: null xsl");
	return;
    }
    if (!d)
    {
	alert("RLG: null destination");
	return;
    }

    if (isIE())
    {
	d.innerHTML = s.transformNode(x);
    }
    else if (isSafari())
    {
	try
	{
	    var t = new XSLTProcessor();
	    t.importStylesheet(x);
	    var f = t.transformToFragment(s, document);
	    if (f)
	    {
		d.innerHTML = "";
		d.appendChild(f);
	    }
	    else
		alert("RLG: Safari XSLT not supported!");
	}
	catch(e)
	{
	    alert("RLG: Safari XSLT not supported!");
	}
    }
    else
    {
	var t = new XSLTProcessor();
	t.importStylesheet(x);
	var f = t.transformToFragment(s, document);
	d.innerHTML = "";
	d.appendChild(f);
    }
}

// misc ------------------------------------------------------------------------

// Convert simple one-level NODE into OBJ and return.
function getNodeAsObject(node)
{
    var obj = new Object;

    for (var i = 0; i < node.childNodes.length; i++)
    {
	if (node.childNodes[i].nodeType == 1)
	{
	    if (node.childNodes[i].firstChild)
	    {
		obj[node.childNodes[i].nodeName] =
		    node.childNodes[i].firstChild.nodeValue;
	    }
	}
    }
    return obj;
}

// cross-browser ---------------------------------------------------------------

function getUA()
{
//    alert(navigator.userAgent.toLowerCase());
    return navigator.userAgent.toLowerCase();
}

function isIE()
{
//    alert("msie " + (getUA().indexOf("msie") > 0));
    return (getUA().indexOf("msie") > 0);
}

function isFirefox()
{
//    alert("safari " + (getUA().indexOf("safari") > 0));
    return (getUA().indexOf("firefox") > 0);
}

function isSafari()
{
//    alert("safari " + (getUA().indexOf("safari") > 0));
    return (getUA().indexOf("safari") > 0);
}

function isOmniWeb()
{
//    alert("OmniWeb " + (getUA().indexOf("OmniWeb") > 0));
    return (getUA().indexOf("omniweb") > 0);
}

function xbSetStyle(el, styleString)
{
    el.setAttribute("style", styleString);
    el.style.cssText = styleString;
    return el;
}

function xbSetClass(el, className)
{
    el.setAttribute("class", className);
    el.setAttribute("className", className);
    return el;
}

function xbCreateRadio(name)
{
    if (isIE())
    {
	var radioStr = "<input type='radio' name='" + name + "'>";
	var radioButton = _e(radioStr);
    }
    else
    {
	var radioButton = _e("input");
	radioButton.setAttribute("type", "radio");
	radioButton.setAttribute("name", name);
    }
    return radioButton;
}

function xbCreateButton(label)
{
    var button = _e("input");
    button.setAttribute("type", "button");
    button.setAttribute("value", label);
    return button;
}

function xbCreateCheckBox()
{
    var cb = _e("input");
    cb.setAttribute("type", "checkbox");
    return cb;
}

// Get a DomParser or equivalent.
function xbGetDP()
{
    var dp = false;
    if (isIE())
    {
	classNames = [
	    "MSXML2.DOMDocument.5.0",
	    "MSXML2.DOMDocument.4.0",
	    "MSXML2.DOMDocument.3.0",
	    "MSXML2.DOMDocument.2.6"
	    ];

	for (i = 0; i < classNames.length; i++)
	{
	    try
	    {
		dp = new ActiveXObject(classNames[i]);
		break;
	    }
	    catch(e)
	    {
//		alert("RLG: Couldn't get DP " + classNames[i]);
	    }
	}
    }
    else
    {
	dp = new DOMParser();
    }
    if (!dp)
	alert("RLG: Couldn't get DP");

    return dp;
}

function xbXMLToDOM(text)
{
    var dp = xbGetDP();
    if (isIE())
    {
	dp.loadXML(text);
	return dp;
    }
    else
    {
	var xml = dp.parseFromString(text, "text/xml");
	return xml;
    }
}

function xbNodeToText(node)
{
    if (isIE())
    {
	return node.xml;
    }
    else
    {
	var ser = new XMLSerializer();
	try
	{
	    return ser.serializeToString(node);
	}
	catch(e) {}
//	catch(e) { return "No serialization available." }
    }
    return "";
}

function xbGetAttribute(node, name)
{
    if (isSafari())
    {
//	alert("safari got attr: " + node.getAttribute(name));
	return node.getAttribute(name);
    }
    else
    {
	var attrNode = node.attributes.getNamedItem(name);

	if (attrNode)
	{
//	    alert("Other get attr: " + attrNode.firstChild.nodeValue);
	    return attrNode.firstChild.nodeValue;
	}
	else
	{
//	    alert("Other get NO attr!");
	}
    }
    return false;
}

// Factory function for XMLHttpRequest object.
function xbInitRequest()
{
    var r = null;
    if (isIE())
    {
	classNames = [
	    "Msxml2.XMLHTTP.5.0",
	    "Msxml2.XMLHTTP.4.0",
	    "Msxml2.XMLHTTP.3.0",
	    "Msxml2.XMLHTTP.2.6",
	    "Msxml2.XMLHTTP"
	    ];

	for (i = 0; i < classNames.length; i++)
	{
	    try
	    {
		r = new ActiveXObject(classNames[i]);
		break;
	    }
	    catch(e) {}
	}
    }
    else if (window.XMLHttpRequest)
    {
	r = new XMLHttpRequest();
    }
    if (!r)
	alert("RLG: Browser couldn't make a connection object.");

    return r;
}

// Currently only used to fetch xslt files from server.
function getContent(url, xml)
{
    var req = xbInitRequest();
    req.open("GET", url, false); // wait
    req.send(null);
    if (xml)
    {
	if (isIE())
	    return xbXMLToDOM(req.responseText);
	else
	    return req.responseXML;
    }
    else
    {
	return req.responseText;
    }
}

// Ajax ------------------------------------------------------------------------

function Asynchronous()
{
    this._xmlhttp = new xbInitRequest();
}

function Asynchronous_call(url, method)
{
    var instance = this;

    this._xmlhttp.open('GET', url, true); // async
    this._xmlhttp.setRequestHeader("If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT");
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
	instance.complete(instance._xmlhttp.status,
			  instance._xmlhttp.statusText,
			  instance._xmlhttp.responseText,
			  instance._xmlhttp.responseXML);
	break;
	}
    }
    this._xmlhttp.send(null);
}

function Asynchronous_loading() { };
function Asynchronous_loaded() { };
function Asynchronous_interactive() { };
function Asynchronous_complete(status, statusText, responseText, responseHTML) { };

Asynchronous.prototype.loading = Asynchronous_loading;
Asynchronous.prototype.loaded = Asynchronous_loaded;
Asynchronous.prototype.interactive = Asynchronous_interactive;
Asynchronous.prototype.complete = Asynchronous_complete;
Asynchronous.prototype.call = Asynchronous_call;

function getContentAsync(url, callback, xml)
{
    var async = new Asynchronous();
    if (xml)
    {
	async.complete = function(status, statusText, responseText, responseXML) {
	    if (callback)
		callback(responseXML);
	}
    }
    else
    {
	async.complete = function(status, statusText, responseText, responseXML) {
	    if (callback)
		callback(responseText);
	}
    }
    async.call(url);
}

// Get a snippet of javascript from the server and execute it.
function loadSnippet(src)	// URI of javascript snippet
{
    var head = document.getElementsByTagName("head")[0];
    var script = document.createElement("script");
    script.id = "import1";
    script.type = "text/javascript";
    script.src = src;
    head.appendChild(script);
}

function getFirstRowAsText(dom)
{
    var node = dom.getElementsByTagName("row")[0];

    if ((node.hasChildNodes()))
	return node.firstChild.nodeValue;
    else
	return null;
}

function getFirstRowURI(dom)
{
    var node = dom.getElementsByTagName("row")[0];
    return xbGetAttribute(node, "uri");
}

function getFirstRowError(dom)
{
    var node = dom.getElementsByTagName("row")[0];
    return xbGetAttribute(node, "error");
}

function getFirstRowDebug(dom)
{
    var node = dom.getElementsByTagName("row")[0];
    return xbGetAttribute(node, "debug");
}

function getFirstRowAsObject(dom)
{
    var node = dom.getElementsByTagName("row")[0];
    return getNodeAsObject(node);
}

if (!Object.prototype.toJSONString) {
/*
    Array.prototype.toJSONString = function () {
        var a = ['['], b, i, l = this.length, v;

        function p(s) {
            if (b) {
                a.push(',');
            }
            a.push(s);
            b = true;
        }

        for (i = 0; i < l; i += 1) {
            v = this[i];
            switch (typeof v) {
            case 'undefined':
            case 'function':
            case 'unknown':
                break;
            case 'object':
                if (v) {
                    if (typeof v.toJSONString === 'function') {
                        p(v.toJSONString());
                    }
                } else {
                    p("null");
                }
                break;
            default:
                p(v.toJSONString());
            }
        }
        a.push(']');
        return a.join('');
    };

    Boolean.prototype.toJSONString = function () {
        return String(this);
    };

    Date.prototype.toJSONString = function () {

        function f(n) {
            return n < 10 ? '0' + n : n;
        }

        return '"' + this.getFullYear() + '-' +
                f(this.getMonth() + 1) + '-' +
                f(this.getDate()) + 'T' +
                f(this.getHours()) + ':' +
                f(this.getMinutes()) + ':' +
                f(this.getSeconds()) + '"';
    };

    Number.prototype.toJSONString = function () {
        return isFinite(this) ? String(this) : "null";
    };

    Object.prototype.toJSONString = function () {
        var a = ['{'], b, i, v;

        function p(s) {
            if (b) {
                a.push(',');
            }
            a.push(i.toJSONString(), ':', s);
            b = true;
        }

        for (i in this) {
            if (this.hasOwnProperty(i)) {
                v = this[i];
                switch (typeof v) {
                case 'undefined':
                case 'function':
                case 'unknown':
                    break;
                case 'object':
                    if (v) {
                        if (typeof v.toJSONString === 'function') {
                            p(v.toJSONString());
                        }
                    } else {
                        p("null");
                    }
                    break;
                default:
                    p(v.toJSONString());
                }
            }
        }
        a.push('}');
        return a.join('');
    };
*/

    (function (s) {
        var m = {
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        };

        s.parseJSON = function (hook) {
            try {
                if (/^("(\\.|[^"\\\n\r])*?"|[,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t])+?$/.
                        test(this)) {
                    var j = eval('(' + this + ')');
                    if (typeof hook === 'function') {
                        function walk(v) {
                            if (v && typeof v === 'object') {
                                for (var i in v) {
                                    if (v.hasOwnProperty(i)) {
                                        v[i] = walk(v[i]);
                                    }
                                }
                            }
                            return hook(v);
                        }
                        return walk(j);
                    }
                    return j;
                }
            } catch (e) {
            }
            throw new SyntaxError("parseJSON");
        };

        s.toJSONString = function () {
            if (/["\\\x00-\x1f]/.test(this)) {
                return '"' + this.replace(/([\x00-\x1f\\"])/g, function(a, b) {
                    var c = m[b];
                    if (c) {
                        return c;
                    }
                    c = b.charCodeAt();
                    return '\\u00' +
                        Math.floor(c / 16).toString(16) +
                        (c % 16).toString(16);
                }) + '"';
            }
            return '"' + this + '"';
        };
    })(String.prototype);
}

// Check for illegal character entities in text areas.
function searchForIllegalChars(text)
{
    //var re = /\&|\<|\>/;
    var re = /\&/;
    if (re.test(text))
    {
    	alert("Please edit your text to remove illegal characters:\n \
ampersand (&), less-than (<), and greater-than (>)");
	return true;
    }
    else
    {
	return false;
    }
}
