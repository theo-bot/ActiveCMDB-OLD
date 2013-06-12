/*
 * 	Script:	activecmdb.config.js
 * 	___________________________________________________________
 *
 * 	Copyright (C) 2011-2015 Theo Bot
 *
 * 	http://www.activecmdb.org
 *
 * 	Topic: Purpose
 *
 * 	JS Function(s) for the device toolbar
 *
 * 	About: License
 *
 * 	This program is free software; you can redistribute it and/or
 * 	modify it under the terms of the GNU General Public License
 * 	as published by the Free Software Foundation; either version 2
 * 	of the License, or (at your option) any later version.
 *
 * 	This program is distributed in the hope that it will be useful,
 * 	but WITHOUT ANY WARRANTY; without even the implied warranty of
 * 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * 	GNU General Public License for more details.
 *
 *  Topic: Version Control
 *
 *
 */

var distopts = [
                	[ "distDef",'obj', 'default', '' ],
                	[ "distEp", 'obj', 'endpoint', '']
               ];

var toolbar = new dhtmlXToolbarObject("toolbarObj", "dhx_web");
toolbar.setIconsPath("/static/images/toolbar/");
toolbar.setIconSize(16);
toolbar.addButton("newDevice",1,"","new.gif","new_dis.gif");
toolbar.addButton("fetchDevice",2,"","computer_go.png","")
toolbar.addButton("searchDevice",3,"","magnifier.png","");
toolbar.addButton("saveDevice", 4,"", "save.gif", "save_dis.gif");
toolbar.addSeparator("sepOne",5);
toolbar.addButton("discoDevice",7,"","disco.png","disco_dis.png");
toolbar.addButton("confDevice",8,"","config.png","config_dis.png");
toolbar.addSeparator("sepOne",9);
toolbar.addButtonSelect('dist',10,"Distribution",distopts,"","");
toolbar.addSeparator("sepOne",10);
toolbar.addButton("delDevice",11,"","cross.png","");
toolbar.attachEvent("onClick",function(id){
	switch( id )
	{
		case "fetchDevice":
			fetch_device( $("#hostname").val() );
			break;
		case "searchDevice":
			$( "#searchWin").dialog( "open" );
			break;
		case "discoDevice":
			discover_device( $("#hostname").val() );
			break;
		case "confDevice":
			fetchconfig_device( $("#hostname").val() );
			break;
		case "saveDevice":
			save_device();
			break;
		default:
			alert("Unknown action :" + id);
	}
	
});

function discover_device(hostname)
{
	$.ajax({
		url: '/device/discover_device',
		data: 'hostname=' + hostname,
		datatype: 'json'
	});
}

function fetchconfig_device(hostname)
{
	$.ajax({
		url: '/device/fetchconfig_device',
		data: 'hostname=' + hostname,
		datatype: 'json'
	});
}

function fetch_device(hostname)
{
	$.ajax({
		url: '/device/fetch_device',
		data: 'hostname=' + hostname,
		datatype:'json',
		success: function(data) {
			$("#device_id").val(data.device_id);
			$("#mgtaddress").val(data.mgtaddress);
			$("#devtype").text(data.descr);
			$("#vendor").text(data.vendor);
			$("#disco").text(data.disco);
			$("#added").text(data.added);
			$("#sysdescr").text(data.descr_tr);
			$("#sysdescr").attr("title", data.sysdescr);
			if ( data.critical == 1 ) {
				$("#isCritical").attr('checked', true);
			} else {
				$("#isCritical").attr('checked', false);
			}
			var taburl = {
					'devint': 'interface',
					'devent': 'structure',
					'devcon': 'connections',
					'devloc': 'site',
					'devctr': 'contract',
					'devsec': 'security',
					'devmnt': 'maintenance',
					'devjnl': 'journal',
					'devcfg': 'devconfig'
			};
			for (tab in taburl)
			{
				/* alert(tab + ' => ' + taburl[tab]); */
				var t = '#' + tab;
				var u = '/device/' + taburl[tab] + '?id=' + data.device_id;
				$( t ).attr('href', u);
			}
			$("#tabs").tabs({active: 0});
		}
	});
}

function save_device()
{
	var check = $
	
	var data = $("#deviceForm").serialize();
	
	
	
}