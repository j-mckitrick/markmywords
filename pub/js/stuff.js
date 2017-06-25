var isVisible = false;

function showLogin()
{
    var el = $("loginform");

    if (isVisible)
    {
	el.style.display = 'none';
	isVisible = false;
    }
    else
    {
	el.style.display = '';
	isVisible = true;
    }
}

var myobj = function ()
{

    var config = {
    colors: [ 'red', 'green', 'blue']
    }

    var foo = function ()
    {
	alert('here is foo');
    }

    return {
    myconfig: config,
    myfoo: foo
    };
}();

//myobj.myfoo();

var myobj2 = {
mybar: function()
{
    alert('here is bar');
}
};

//myobj2.mybar();

/*
MMY.addwordrowOLD = function(user, date, idx, contents)
{
    var tr = document.createElement('tr');
    tr.className = 'non';

    var td = document.createElement('td');
    var tx = document.createTextNode(user);

    td.appendChild(tx);
    tr.appendChild(td);

    var td = document.createElement('td');
    var tx = document.createTextNode(date);

    td.appendChild(tx);
    tr.appendChild(td);

    var td = document.createElement('td');
    var tx = document.createTextNode(contents);

    td.appendChild(tx);
    tr.appendChild(td);

    $('#words tbody').append(tr);
}
*/
MMY.gotwordsOLD = function(xml)
{
    $("#contentpane-2").show();
    $('.non').remove();

    $('word', xml).each(function(i) {
	    var u = $(this).attr('user');
	    var d = $(this).attr('date');
	    var i = $(this).attr('idx');
	    var c = $(this).text();
	    MMY.addwordrow(u, d, i, c);
	});
}

MMY.addwordrow = function(user, date, idx, contents)
{
    var id = 'word_' + idx;

    $('<tr/>').addClass('non').attr('id', id).appendTo('#words tbody');

    $('<td/>').text(user).appendTo('#' + id);
    $('<td/>').text(date).appendTo('#' + id);
    $('<td/>').text(contents).appendTo('#' + id);
}
//      $(document).ready(function() { MMY.init(); });


    var cname = 'Row Hilite' + ($('tr').size() - 1) % 2;
    var trID = 'tr_' + $("word", xml).attr('idx');
    var tr = '#' + trID;

    $('<tr/>').addClass(cname).attr('id', trID).appendTo('#wordstable tbody');
    $('<td/>').text($("word", xml).attr('user')).appendTo(tr);
    $('<td/>').text($("word", xml).attr('date')).appendTo(tr);
    $('<td/>').text($("word", xml).attr('title')).appendTo(tr);
    $('<td/>').text($("word", xml).text()).appendTo(tr);

    var buttonID  = 'button_' + $("word", xml).attr('idx');
    var button = '#' + buttonID;
    var attributes = { id: buttonID, type: "button", value: "Delete" };
    $('<td/>').append($('<input/>').attr(attributes)).appendTo(tr);

    $(button).click(MMY.dodelete);

//    $("#profileform").empty().append($(html)).show();
