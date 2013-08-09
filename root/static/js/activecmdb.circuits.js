/*
 * 	Script:	activecmdb.circuits.js
 * 	___________________________________________________________
 *
 * 	Copyright (C) 2011-2015 Theo Bot
 *
 * 	http://www.activecmdb.org
 *
 * 	Topic: Purpose
 *
 * 	JS Function(s) to support dynamic (ajax) device circuits
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

function xCircuitDetails(device_id,circuit, type)
{
	$.ajax({
		url: '/device/fetch_circuit',
		data: 'device_id=' + device_id + '&circuit=' + circuit + '&type=' + type,
		datatype: 'json',
		success: function(data) {
			$( "#circuitName" ).text(data.circuitName);
			$( "#circuitDesc" ).text(data.circuitDesc);
			$( "#cicuitUnits" ).text(data.cicuitUnits);
			$( "#circuitLow" ).text(data.circuitLow);
			$( "#circuitHigh").text(data.circuitHigh);
			
			document.getElementById('circuitDetail').style.visibility = 'visible';
		}
	});
}