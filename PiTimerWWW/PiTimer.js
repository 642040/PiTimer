//
//	Collector for all JavaScript functions
//	Included in index.html
//
//	Adrian Allan 1/3/2014
//

var myXml;
var Schedule = {};
var DoW = {};
var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
for ( i = 0; i <= 6; i++) {
	Schedule[days[i]] = {};
	DoW[days[i]] = i + 1;
}
//var zones = ["#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e", "#e6ab02", "#a6761d", "#666666"];	// dark24
//var zones = ["#a6cee3", "#1f78b4", "#b2df8a", "#33a023", "#fb9a99", "#e31a1c", "#fbdf6f", "#ff7f00"];	// paired8
var zones = ["#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00", "#ffff33", "#a65628", "#999999"];	// set18
var width;
var height;
var BorderBot;
var oneHour;
var oneDay;
var BorderTop;
var BorderLeft;

function parseXml(xml) {
	myXml = $(xml);
	$('#zonelist').empty();
	$(xml).find("Zone").each(function() {
		//alert('Got Here 2');
		var zonenumber=$(this).attr("ZoneID");
		var color=zones[zonenumber-1];
		$('#zonelist').append('<fieldset data-role="controlgroup"><input name="textinput' + zonenumber + '" id="textinput' + zonenumber + '" style="background:'+color+'" placeholder="" value="' + $(this).text() + '" type="text"></fieldset>').trigger('create');
	});
	$('#programnames').empty();
	$(xml).find("Program").each(function() {
		//alert('Got Here 3');
		$('#programnames').append('<a data-role="button" data-theme="a" onclick="editProgram(&quot;' + $(this).attr("name") + '&quot;);" data-icon="arrow-r"	data-iconpos="left">' + $(this).attr("name") + '</a>').trigger('create');
	});
	MakeSchedule();
};

function MakeSchedule() {

	Schedule["Sun"] = {};
	//Schedule["Sun"][0] = 0;
	var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
	for ( i = 0; i <= 6; i++) {
		Schedule[days[i]] = {};
	}
	var STtemp;

	c = document.getElementById("myCanvas");
	ctx = c.getContext("2d");

	myXml.find("Program").each(function() {
		var program = $(this);
		time = program.find("StartTime").text();
		parts = time.split(':');
		var StartTime = (parts[0] * 60 + parts[1] * 1);
		program.find("Date").each(function() {
			var date = $(this).text();
			var parts = date.split('-');
			var jsDate = new Date(parts[0], (parts[1] - 1), parts[2]);
			var day = days[jsDate.getDay()];
			STtemp = StartTime;
			var today = new Date();
			if (today.toDateString() == jsDate.toDateString()) {
				program.find("Timer").each(function() {
					var zone = $(this).attr("ZoneID");
					var RunTime = $(this).text();
					for (var i = 1; i <= RunTime; i++) {
						while (Schedule[day] != undefined && Schedule[day][STtemp] != undefined) {
							STtemp++;
							if (STtemp > 24 * 60) {
								alert("Date Cannot schedule past midnight");
							}
						}
						Schedule[day][STtemp] = zone;
					}
					ctx.fillStyle = zones[zone-1];
					ctx.fillRect(DoW[day] * oneDay + 1, STtemp / 60 * oneHour+oneHour, oneDay - 1, -RunTime * ((height - BorderBot) / 25) / 60);
				});
			}
		});
		program.find("Day").each(function() {
			var day = $(this).text();
			STtemp = StartTime;
			program.find("Timer").each(function() {
				var zone = $(this).attr("ZoneID");
				var RunTime = $(this).text();
				for (var i = 1; i <= RunTime; i++) {
					while (Schedule[day] != undefined && Schedule[day][STtemp] != undefined) {
						STtemp++;
						if (STtemp > 24 * 60) {
							alert("Day Cannot schedule past midnight");
						}
					}
					Schedule[day][STtemp] = zone;
				};
				ctx.fillStyle = zones[zone-1];
				ctx.fillRect(DoW[day] * oneDay + 1, STtemp / 60 * oneHour+oneHour, oneDay - 1, -RunTime * ((height - BorderBot) / 25) / 60);
			});
		});
	});
}

function DrawChart() {
	var c = document.getElementById("myCanvas");
	c.width = window.innerWidth;
	c.height = window.innerHeight;
	var ctx = c.getContext("2d");

	width = .9 * c.width;
	height = c.height;

	BorderBot = .1 * height;
	oneHour = (height - BorderBot) / 25;
	oneDay = width / 8;
	BorderTop = oneHour * .5;
	BorderLeft = width * .05;

	var myFont = oneHour * 1 + "px Arial";
	ctx.font = myFont;
	ctx.textAlign = "center";
	ctx.textBaseline = 'middle';
	ctx.fillStyle = "#FFFFFF";
	ctx.strokeStyle = "#FFFFFF";
	var weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", ""];
	var dayHours = ["", "", "", "3", "", "", "6", "", "", "9", "", "", "12", "", "", "3", "", "", "6", "", "", "9", "", "", "12", ""];

	// Draw vertical lines and days
	for (var i = 1; i <= 8; i++) {
		ctx.moveTo(i * oneDay, .75 * oneHour);
		ctx.lineTo(i * oneDay, height - BorderBot);
		ctx.stroke();
		ctx.fillText(weekDays[i - 1], (i + .5) * oneDay, .5 * oneHour);
	}
	// Draw horizontal lines and hours
	for (var i = 0; i <= 24; i++) {
		ctx.moveTo(.8 * oneDay, (i+1) * (height - BorderBot) / 25);
		ctx.lineTo(width, (i+1) * (height - BorderBot) / 25);
		ctx.stroke();
		ctx.fillText(dayHours[i], .6 * oneDay, (i+1) * (height - BorderBot) / 25);
	}

};

$(function () {
	//
	//	Function to handle changes to Zone Names and push them to the PiTimer.xml file
	//	*** Validate PiTimer.xml to ensure it meets xsd on server side
	//	*** Change submit to only happen when user clicks Save button
	//	*** Figure out why reload does not always work on webapp
	//
	//	Bind submit operation on ZoneEdit to this function
    $('#zoneEdit').bind('submit', function (z) {
    	//	Override the default jquerymobile functionality
        z.preventDefault();
        //	Pass form data to zone.pl on the server side
        $.post('./zoneEdit.pl', $(this).serialize(), function (response) {
        	//	Reload updated PiTimer.xml file
			$.ajax({
				type : "GET",
				url : "PiTimer.xml",
				dataType : "xml",
				success : parseXml
			});
			//	Stay on zones page for additional changes (may be better to go home?)
            $.mobile.changePage('#zones', {transition: 'pop'});
            //	Alert to provide feedback to user that change was successful
	    	alert('Saved');
        });
    });
    	//
	//	Function to handle changes to Programs and push them to the PiTimer.xml file
	//
	//	Bind submit operation on ZoneEdit to this function
    $('#programEdit').bind('submit', function (p) {
    	//	Override the default jquerymobile functionality
        p.preventDefault();
        //	Pass form data to zone.pl on the server side
        $.post('./programEdit.pl', $(this).serialize(), function (response) {
        	//	Reload updated PiTimer.xml file
			$.ajax({
				type : "GET",
				url : "PiTimer.xml",
				dataType : "xml",
				success : parseXml
			});
			//	Stay on zones page for additional changes (may be better to go home?)
            $.mobile.changePage('#programEdit', {transition: 'pop'});
            //	Alert to provide feedback to user that change was successful
	    	alert('Saved');
        });
    });
});

function addProgram() {
	//
	//	Insert new program in PiTimer.xml
	//
	//	Send null data to programs.pl on server
	//	Adds "New Program" to PiTimer.xml
	//	Reload updated PiTimer.xml file
	$.post('./programAdd.pl', "", function (response) {
		$.ajax({
			type : "GET",
			url : "PiTimer.xml",
			dataType : "xml",
			success : parseXml
		});
		//	Transition to program editor page
		$.mobile.changePage('#programlist', {transition: 'pop'});
	});
};

function editProgram(pname) {
	//
	//	Build dialog for user modification of programs
	//	pname = name of program to edit
	//
	$.mobile.changePage("#program");
	//	Set page name and program name fields
	$('#PePageName').html(pname);
	$('#PeProgName').attr("value", pname);
	//	Find program in PiTimer.xml
	myXpath = 'Program[name="' + pname + '"]';
	//	Fill fields with data from PiTimer.xml
	//  *** Need a way to ensure that ProgName is unique?
	myXml.find(myXpath).each(function() {
		// StartTime as Time field
		//  *** Need to figure out how to handle 12:00 vs 12:00:00
		StartTime = $(this).find("StartTime").text();
		$('#PeStartTime').attr("value", StartTime);
		//	Build day of week radio buttons
		$('#PeWeek input').removeAttr("checked").checkboxradio("refresh");
		$(this).find("Day").each(function() {
			myDay = "#Pe" + $(this).text();
			$(myDay).attr("checked", "true").checkboxradio("refresh");
		});
		//	Build sliders for each zone
		$('#PeZones').empty();
		$(this).find("Timer").each(function() {
			myXpath = 'Zone[id="' + $(this).attr("ZoneID") + '"]';
			zoneName = myXml.find(myXpath).text();
			if (zoneName != "") {
				$('#PeZones').append('<label for="slider-1">' + zoneName + '</label><input type="range" name="slider-1" id="slider-1" value="' + $(this).find("RunTime").text() + '" min="0" max="60" /><br \>').trigger('create');
			}
		});
	});
};
