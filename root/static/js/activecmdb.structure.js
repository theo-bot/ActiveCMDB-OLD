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
 * 	JS Function(s) to support dynamic (ajax) device entities
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

function xEntityDetails(device_id,index)
{
	$.ajax({
		url: '/device/fetch_entity',
		data: 'device_id=' + device_id + '&index=' + index,
		datatype: 'json',
		success: function(data) {
			$( "#entityName" ).text(data.entphysicalname);
			$( "#entityDesc" ).text(data.entphysicaldescr);
			$( "#entityClass" ).text(data.entphysicalclass);
			$( "#entityHwRev" ).text(data.entphysicalhardwarerev);
			$( "#entityFwRev").text(data.entphysicalfirmwarerev);
			$( "#entitySwRev" ).text(data.entphysicalsoftwarerev);
			$( "#entitySerial").text(data.entphysicalserialnum);
			$( "#logicalUnit" ).text(data.logicalUnit);
			document.getElementById('entityDetail').style.visibility = 'visible';
		}
	});
}