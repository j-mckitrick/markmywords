// Mark My Words

function MMY() {}

// Send AJAX login form.
MMY.dologin = function()
{
    var params = { username: $("#user").val(),
				   password: $("#pass").val(),
				   persist: $("#persist").val() };

    $.post("/login", params, function(json) { MMY.donelogin(json) }, "json");
}

// Handle results of login attempt or successful signup.
MMY.donelogin = function(json)
{
    if (json)
    {
        if (json.username)
        {
		    MMY.username = json.username;
		    MMY.admin = json.admin

		    $("#showlogin").text("Logout");
		    $("#showlogin").unbind('click', MMY.togglelogin).click(MMY.dologout);

		    $("#signup").hide();
		    $("#loginform").hide("slow", MMY.doneloginOK);
        }
        else if (json.fail == "bad")
        {
		    $('#login_message').addClass('Red').text('Bad login');
        }
        else if (json.fail == "exists")
        {
		    alert('Username already exists');
        }
    }

	$("#signup").click(MMY.showsignup).show();

	// Non-members can still view content.
	MMY.getallwords();
}

// Update UI for a successful login.
MMY.doneloginOK = function()
{
    $("#username").html('Welcome, ' + MMY.username + '!');
    $("#userdiv").show();
    $("#getprofile").click(MMY.getprofile).show();

    if (MMY.admin == 1)
        $("#admin").click(function() { window.location = "/admin"; }).show();

    MMY.getallwords();
    MMY.getpopular();
    MMY.getpopularN();
	MMY.getcategories();
}

MMY.dologout = function()
{
    window.location = "/logout";
}

// Refresh content table.
MMY.getallwords = function()
{
    $.getJSON("/entry", MMY.gotallwordsjson);
}

MMY.gotallwordsjson = function(json)
{
    $("#contentpane").show();
    $("#wordsform").show();
    $('.Row').remove();

    MMY.gotjsonwords(json);
}

// Get content of drop-down list.
MMY.getcategories = function()
{
    $.getJSON("/categories", function(json) { MMY.gotcategories(json); });
}

// Populate drop-down list.
MMY.gotcategories = function(json)
{
    var t = '- Select One -';
    var v = '';

    $('#categories').empty().append($('<option/>').attr('value', v).text(t));
    $('#q_categories').empty().append($('<option/>').attr('value', v).text(t));
	$.each(json, function(k, v) { MMY.popcategories(k, v); } );
}

// Called via EACH
MMY.popcategories = function(k, v)
{
	$('<option/>').attr('value', v).text(v).appendTo('#categories');
	$('<option/>').attr('value', v).text(v).appendTo('#q_categories');
}

// Add a new item for a logged in user.
MMY.addwords = function()
{
    if (!MMY.username)
    {
		alert('You must be logged in to add words');
    }
    else if (MMY.entry_id)
    {
		var params = { title: $("#title").val(),
					   words: $("#words").val(),
					   category: $("#categories").val() };

		$.put("/entry/" + MMY.entry_id, params, MMY.gotjsonwords, "json");

		$("#title").val('');
		$("#words").val('');
    }
    else
    {
		var params = { title: $("#title").val(),
					   words: $("#words").val(),
					   category: $("#categories").val() };

		$.post("/entry", params, MMY.gotjsonwords, "json");

		$("#title").val('');
		$("#words").val('');
    }
}

MMY.addjsonword = function(k, v)
{
	var trID = 'tr_' + v.idx;
	var tr   = '#' + trID;

	if ($(tr).size() == 1) // Already exists, clear it.
	{
		$(tr).empty();
	}
	else if ($(tr).size() == 0) // Does not exist, create a new one.
	{
		$('<tr/>').attr('id', trID).appendTo('#wordstable tbody');
		$(tr).addClass('Row Hilite' + ($('tr').size() - 1) % 2);
	}
	else
	{
		alert('oops');
	}

	var verified = 'N';
	if (v.verified == '1')
		verified = 'Y';

	// Build the row of data cells.
	$('<td/>').text(v.username).appendTo(tr);
	$('<td/>').text(v.date).appendTo(tr);
	$('<td/>').text(v.category).appendTo(tr);
	$('<td/>').text(v.title).appendTo(tr);
	$('<td/>').text(v.content).appendTo(tr);
	$('<td/>').text(verified).addClass('votes').appendTo(tr);
	$('<td/>').text(v.accuracy).addClass('stats').appendTo(tr);
	$('<td/>').text(v.up).addClass('votes').appendTo(tr);
	$('<td/>').text(v.dn).addClass('votes').appendTo(tr);

	var tdID = 'td_' + v.idx;
	var td   = '#' + tdID;

	$('<td/>').attr('id', tdID).appendTo(tr);

	// Enable edit/delete of our own entries.
	if (MMY.username == v.username ||
		MMY.admin == '1')
	{
		var buttonID = 'button-del_' + v.idx;
		var button = '#' + buttonID;
		var attributes = { id: buttonID,
						   type: "button",
						   value: "Delete" };

		$('<input/>').attr(attributes).appendTo(td);
		$(button).click(MMY.dodelete);
/*
		var buttonID = 'button-ed_' + v.idx;
		var button = '#' + buttonID;
		var attributes = { id: buttonID,
						   type: "button",
						   //disabled: "disabled" 
						   value: "Edit"};

		$('<input/>').attr(attributes).appendTo(td);
		$(button).click(MMY.doedit);
*/
	}

	if (MMY.admin == '1' &&
		v.verified == '0')
	{
		var buttonID = 'button-ver_' + v.idx;
		var button = '#' + buttonID;
		var attributes = { id: buttonID,
						   type: "button",
						   value: "Verify" };

		$('<input/>').attr(attributes).appendTo(td);
		$(button).click(MMY.doverify);
	}
	else if (MMY.admin == '1' &&
			 v.verified == '1')
	{
		var buttonID = 'button-unver_' + v.idx;
		var button = '#' + buttonID;
		var attributes = { id: buttonID,
						   type: "button",
						   value: "Unverify" };

		$('<input/>').attr(attributes).appendTo(td);
		$(button).click(MMY.dounverify);
	}

	// Enable upvote/downvote other user's entries.
	if (MMY.username != null &&
		v.username != MMY.username &&
		v.rankable == '1' &&
		MMY.admin != '1')
	{
		var buttonID = 'button-up_' + v.idx;
		var button = '#' + buttonID;
		var attributes = { id: buttonID,
						   type: "button",
						   value: "Up" };

		$('<input/>').attr(attributes).appendTo(td);
		$(button).click(MMY.doupvote);

		var buttonID = 'button-dn_' + v.idx;
		var button = '#' + buttonID;
		var attributes = { id: buttonID,
						   type: "button",
						   value: "Down" };

		$('<input/>').attr(attributes).appendTo(td);
		$(button).click(MMY.dodnvote);
	}
}

MMY.gotjsonwords = function(json)
{
	MMY.entry_id = null;
	$.each(json, function(k, v) { MMY.addjsonword(k, v); });
}

MMY.doedit = function()
{
    var id = $(this).attr('id').split('_')[1];

    $.getJSON("/entry/" + id, MMY.gotentry);
}

MMY.gotentry = function(json)
{
	$('#categories').val(json.category);
	$('#title').val(json.title);
	$('#words').val(json.content);
	MMY.entry_id = json.idx;

    MMY.showdialog();
}

MMY.dodelete = function()
{
	if (confirm("Are you sure you want to delete this item?"))
	{
		var id = $(this).attr('id').split('_')[1];

		$.delete_("/entry/" + id, MMY.donedelete);
	}
}

MMY.donedelete = function()
{
    MMY.getallwords();
}

MMY.doupvote = function()
{
    var id = $(this).attr('id').split('_')[1];
	var params = { "id" : id };

    $.post("/upvote", params, MMY.donevote, "json");
}

MMY.dodnvote = function()
{
    var id = $(this).attr('id').split('_')[1];
	var params = { "id" : id };

    $.post("/dnvote", params, MMY.donevote, "json");
}

MMY.donevote = function(xml)
{
    MMY.gotjsonwords(xml);
    MMY.getpopular();
    MMY.getpopularN();
}

MMY.doverify = function()
{
    var id = $(this).attr('id').split('_')[1];
	var params = { "verified" : 1 };

    $.put("/entry/" + id, params, MMY.getallwords);
}

MMY.dounverify = function()
{
    var id = $(this).attr('id').split('_')[1];
	var params = { "verified" : 0 };

    $.put("/entry/" + id, params, MMY.getallwords);
}

MMY.getprofile = function()
{
    $.getJSON("/profile", MMY.gotprofile);
}

MMY.gotprofile = function(json)
{
    // Hide all content.
    $("#contentpane").hide();
    $("#wordsform").hide();

    // Show/populate form.
    $("#profileform").show("slow");
    $("#profileidx").val(json.idx);
    $("#profileusername").val(json.username);
    $("#profilepassword").val(json.password);

    $("#saveuser").click(MMY.saveprofile);
    $("#canceluser").click(MMY.doneprofile);
}

MMY.showsignup = function ()
{
    // Hide all content.
    $("#contentpane").hide();
    $("#wordsform").hide();

    $("#profileform").show();

    $("#saveuser").click(MMY.signup);
    $("#canceluser").click(MMY.doneprofile);
}

// Signup a NEW user.
MMY.signup = function()
{
    var params = { username: $("#profileusername").val(),
				   password: $("#profilepassword").val() };

    $.post("/profile", params, MMY.donelogin, "json");
}

MMY.donesignup = function (json)
{
    window.location = "/";
}

// Update an EXISTING user.
MMY.saveprofile = function()
{
    var idx = $("#profileidx").val();
    var params = { "idx": idx,
				   "username": $("#profileusername").val(),
				   "password": $("#profilepassword").val() };

    $.put("/profile/" + idx, params, MMY.doneprofile);
}

MMY.doneprofile = function()
{
    $("#profileform").hide("slow");

    $("#contentpane").show("slow");
    $("#wordsform").show("slow");

    MMY.getallwords();
}

MMY.hidelogin = function()
{
    $("#loginform").hide("slow");
    $('#login_message').hide();
}

MMY.getpopular = function()
{
    var params = { pop: "t" };

    $.getJSON("/entry", params, MMY.gotpopular);
}

MMY.gotpopular = function(v)
{
    $('#topranked').html('<br/>Top ranked item:')
    $('#topranked').append($('<ul/>').attr('id', 'ranklist'));

	var liID = 'li_' + v.idx;
	var li   = '#' + liID;

	$('<li/>').text(v.content).attr('id', liID).appendTo('#ranklist');
	if (v.username == MMY.username)
	{
		$(li).append($('<span/>').text(' Mine!').addClass('Red'));
	}
}

MMY.getpopularN = function()
{
    var params = { pop: "t", n: 5 };

    $.getJSON("/entry", params, MMY.gotpopularN);
}

MMY.gotpopularN = function(json)
{
    $('#popularn').html('Top ranked items: ');
    $('#popularn').append($('<ul/>').attr('id', 'poplist'));

    $.each(json, function(k, v) {
			var liID = 'lin_' + v.idx;
			var li   = '#' + liID;
			var content = v.content;

			$('<li/>').attr('id', liID).text(content).appendTo('#poplist');
			if (v.usernamename == MMY.username)
			{
				$(li).addClass('Red');
			}
		});
}

MMY.searchwords = function()
{
    var params = { title: $("#q_title").val(),
				   words: $("#q_words").val(),
				   category: $("#q_categories").val() };

    $.getJSON("/entry", params, MMY.gotallwordsjson);
}

MMY.showdialog = function()
{
    $('#wordsform').dialog('open');
}

MMY.init = function()
{
    $("#showlogin").click(function() { $("#loginform").toggle("slow") });
    $("#cancelbutton").click(MMY.hidelogin);
	$('#addentry').click(function() { MMY.showdialog(); });

    $("#loginbutton").click(MMY.dologin);
    $("#getwords").click(MMY.getallwords);
    $("#addbutton").click(MMY.addwords);
    $("#cancelbutton").click(MMY.cancelwords);
    $("#q_button").click(MMY.searchwords);
    $("#searchwords").click(function() {
        $("#wordsform").toggle("slow");
        $("#queryform").toggle("slow");
    });
    $("#q_cancel").click(function() {
        $("#wordsform").toggle("slow");
        $("#queryform").toggle("slow");
    });

	MMY.username = null;
    $.getJSON("/user", MMY.donelogin);
}
