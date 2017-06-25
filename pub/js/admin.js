function admin() {}

admin.gotUsers = function(html)
{
//	alert(html);
	$('#adminpane').html(html);
}

admin.getUsers = function()
{
	$.get("/xuser", admin.gotUsers);
}

admin.init = function()
{
    $("#exit").click(function() { window.location = "/"; });

//    alert('ready');
	admin.getUsers();
}

admin.doadmin = function()
{
	alert('here');
}