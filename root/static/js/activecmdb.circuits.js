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

function xCircuitDetails(type, device_id,circuit, ifindex)
{
	$.ajax({
		url: '/device/fetch_circuit',
		data: 'device_id=' + device_id + '&circuit=' + circuit + '&type=' + type + '&ifindex=' + ifindex,
		datatype: 'json',
		success: function(data) {
			showCircuitDetails(type, data);
		}
	});
}

function showCircuitDetails(type, data)
{
	switch(type)
	{
		case 0: 
			$( "#dName").text("Name");
			$( "#dMinSpeed" ).text("Min. speed");
			$( "#dMaxSpeed" ).text("Max. speed");
			$( "#circuitName" ).text(data.circuitName);
			$( "#circuitDesc" ).text(data.circuitDesc);
			$( "#cicuitUnits" ).text(data.cicuitUnits);
			$( "#circuitLow" ).text(data.circuitLow);
			$( "#circuitHigh").text(data.circuitHigh);
			break;
		case 1:
			$( "#dName").text("Name");
			$( "#dMinSpeed" ).text("Min. speed");
			$( "#dMaxSpeed" ).text("Max. speed");
			$( "#circuitName" ).text(data.circuitName);
			$( "#circuitDesc" ).text(data.circuitDesc);
			$( "#cicuitUnits" ).text(data.cicuitUnits);
			$( "#circuitLow" ).text(data.circuitLow);
			$( "#circuitHigh").text(data.circuitHigh);
			break;
		case 2:
			$( "#dName").text("DLCI");
			$( "#dMinSpeed" ).text("CIR");
			$( "#dMaxSpeed" ).text("Burst rate");
			$( "#circuitName" ).text(data.circuitName);
			$( "#circuitDesc" ).text(data.circuitDesc);
			$( "#cicuitUnits" ).text(data.cicuitUnits);
			$( "#circuitLow" ).text(data.circuitLow);
			$( "#circuitHigh").text(data.circuitHigh);
			break;
		default:
			alert("Unknown type exception");
	}
	document.getElementById('circuitDetail').style.visibility = 'visible';
}