// Development debug messages.

function shownode(node)
{
    alert("RLG showing: " + xbNodeToText(node));
}

function showObject(obj)
{
    alert("RLG showing obj...");
    for (slot in obj)
	alert(slot + " (" + typeof obj[slot] + "): " + obj[slot]);
}

