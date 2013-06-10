/*
 * 	Script:	activecmdb.interface.js
 * 	___________________________________________________________
 *
 * 	Copyright (C) 2011-2015 Theo Bot
 *
 * 	http://www.activecmdb.org
 *
 * 	Topic: Purpose
 *
 * 	Javascript lirabry for ip device interface handling
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
 *  $Id: main.css 45 2011-05-01 12:54:25Z theob $
 *
 */

function xInterfaceDetails(device_id,ifindex)
{
	$.ajax({
		url: '/device/fetch_interface',
		data: 'device_id=' + device_id + '&ifindex=' + ifindex,
		datatype: 'json',
		success: function(data) {
			$( "#ifDescr" ).text(data.ifdescr);
			$( "#ifName" ).text(data.ifname);
			$( "#ifAlias" ).text(data.ifalias);
			$( "#ifIndex" ).text(data.ifindex);
			$( "#ifSpeed").text(data.ifspeed);
			$( "#ifType" ).text(data.iftype);
			$( "#ifPhysAddress").text(data.ifphysaddress);
			document.getElementById('ifDetail').style.visibility = 'visible';
		}
	});
}