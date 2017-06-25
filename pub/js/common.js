// Commonly used RLG functions not general enough to be in a library (yet).

// Application-wide debug settings
var restDebug = true;		// show failed REST error messages
var clientDebug = true;		// show client REST error messages
var serverDebug = true;		// show server REST error messages

var globalBusy = false;

// Show a busy message while performing an ajax operation.
function showBusyBar(flag)
{
    if (flag)
    {
	globalBusy = true;
	xbSetClass($("sstatus"), "show");
	timer = setTimeout("flashBusyBar(false)", 500);
    }
    else
    {
	globalBusy = false;
	xbSetClass($("sstatus"), "hide");
    }
}

// Flash busy bar.
function flashBusyBar(flash)
{
    if (!globalBusy)
	return;

    if (flash)
    {
	xbSetClass($("sstatus"), "show");
	timer = setTimeout("flashBusyBar(false)", 500);
    }
    else
    {
	xbSetClass($("sstatus"), "hide");
	timer = setTimeout("flashBusyBar(true)", 500);
    }
}

// Show an error message in a div/span.
function showErrorBar(msg)
{
    var bar = $("eerror");

    if (msg)
    {
	bar.innerHTML = msg;
	xbSetClass(bar, "show");
    }
    else
    {
	xbSetClass(bar, "hide");
    }
}

var clear = "&nbsp;&nbsp;&nbsp;";

function clearProgress(barId, blockIdBase, blockColor)
{
    var bar = $(barId);

    if (bar.style.visibility == "visible")
    {
	for (var i = 1; i <= 10; i++)
	{
	    var elem = $(blockIdBase + i);
	    elem.innerHTML = clear;
	    elem.style.backgroundColor = blockColor;
	}
    }
    else
    {
	bar.style.visibility = "visible";
    }
}

function setProgress(percent, blockIdBase, blockColor)
{
    var index = Math.round(percent);
    for (var i = 1; i <= index; i++)
    {
	var elem = $(blockIdBase + i);
	elem.innerHTML = clear;
	elem.style.backgroundColor = blockColor;
	var nextCell = i + 1;
	if (nextCell > index && nextCell <= 10)
	{
	    $(blockIdBase + nextCell).innerHTML = Math.round(percent * 10) + "%";
	}
    }
}

// Just an example of exception handling.
function xlocalError()
{
    try
    {
	throw(new Error("Check me"));
    }
    catch (e)
    {
	alert("Exception: " + e.name);
	alert("Message: " + e.msg);
    }
}

// Show an error message, url, and status/text
// from a failed REST call, hopefully during development.
//
// 1.  Application error:
// Unhandled exceptions on the server side of REST calls
// during development produce http error 500 messages
// and end up here.
//
// 2.  Empty response:
// Additionally, if the REST response is null, likely
// because of a content-type mixup, we end up here.
function restError(message, url, status)
{
    showBusyBar(false);

    if (restDebug)
	alert("RLG Error: " + message + "\n" + url + " " + status);
}

// Show the details of a javascript exception thrown in
// the callback after a successful REST call to the server.
function callbackError(e)
{
    showBusyBar(false);

    if (clientDebug)
	alert("RLG REST callback error: " + e.name + ": " + e.message);
}

// Show an error message from a REST request explaining
// a gracefully handled error or condition from the
// server side most likely representing an assert or
// other issue in the code.
function serverError(message, dom)
{
    showBusyBar(false);

    alert("RLG Error: " + message + "\n\n" + getFirstRowError(dom));
    if (serverDebug)
	alert("Details: " + getFirstRowDebug(dom));
}

// Last ditch handler for unhandled errors.
// Replaces window.onerror().
// NB: Callbacks do not use window.onerror(),
// which is why we need callbackError() above.
function globalError(msg, file, line)
{
    showBusyBar(false);

    alert("RLG Error: " + msg + " in " + file + " line " + line);

    // We do not want the browser to show any
    // indication that this has occurred,
    // such as an exclamation point in the status bar.
    return true;
}

function fadeInPopup(step)
{
    var popup = $("divpopup");

    if (step < 10)
    {
	xbSetClass(popup, "show popup opac" + step);
	timer = setTimeout("fadeInPopup(" + (step + 1) + ")", 50);
    }
    else
    {
	xbSetClass(popup, "show popup");
    }
}

function fadeOutPopup(step)
{
    var popup = $("divpopup");

    if (step >= 0)
    {
	xbSetClass(popup, "show popup opac" + step);
	timer = setTimeout("fadeOutPopup(" + (step - 1) + ")", 50);
    }
    else
    {
	xbSetClass(popup, "hide popup");
    }
}

function positionPopup(popup, pwidth, pheight)
{
    var width = document.body.clientWidth;
    var height = document.body.clientHeight;
    var left = width / 2;
    var popupwidth = pwidth;
    var popupleft = popupwidth / 2;
    var top = height / 2;
    var popupheight = pheight;
    var popuptop = popupheight / 2;

    popup.style.left = left - popupleft + "px";
    popup.style.width = popupwidth + "px";
    popup.style.top = top - popuptop + "px";
    popup.style.height = popupheight + "px";
}
