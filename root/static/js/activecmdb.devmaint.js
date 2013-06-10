/*
 * 	Script:	activecmdb.devmaint.js
 * 	___________________________________________________________
 *
 * 	Copyright (C) 2011-2015 Theo Bot
 *
 * 	http://www.activecmdb.org
 *
 * 	Topic: Purpose
 *
 * 	JS Library to support device maintenance
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

$(function() {

	$( "#setDeviceMaint" ).click(function() {
		var data = 'id=' + $("#device_id").val() + '&maint=' + $("#devmaint").val();
		$.post('/device/setmaint',
			data,
			function(data) {
				$('#response').html(data).show();
			},
			'html'
		);
		
	});

});