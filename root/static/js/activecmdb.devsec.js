/*
 * 	Script:	activecmdb.devsec.js
 * 	___________________________________________________________
 *
 * 	Copyright (C) 2011-2015 Theo Bot
 *
 * 	http://www.activecmdb.org
 *
 * 	Topic: Purpose
 *
 * 	JS Library for device security functions
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

$(function() {
	
	$("#updateSecurity").click(function(){
		var data = $("#deviceSec").serialize();
		$.post(
			'/device/update_security',
			data,
			function(data) {
				$('#response').html(data).show().delay(5000).hide('slow');
				$('#saveSite').prop("disabled", true);
			},
			'html'
		);
	});
	
});

function snmpSelect()
{
	var version = $( 'input[name="snmpv"]:checked','#deviceSec' ).val();
	/* alert("Version :" + version ); */
	if ( version < 3 ) {
		$( "#snmpv1" ).show();
		$( "#snmpv3" ).hide();
	} else {
		$( "#snmpv1" ).hide();
		$( "#snmpv3" ).show();
	}
}