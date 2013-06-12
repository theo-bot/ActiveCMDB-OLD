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
 * 	JS Function(s) to support user role management
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
	
	$( '#saveRole' ).click(function() {
		var data = $( '#roleForm' ).serialize();
		
		$.post('/roles/save',
				data,
				function(data) {
					$('#response').html(data).show();
				},
				'html'
		);
		
	});

	$( '#deleteRole' ).click(function() {
		var data = $( '#roleForm' ).serialize();
	
		$.post('/roles/delete',
				data,
				function(data) {
					$('#response').html(data).show();
				},
				'html'
		);
	});
	
});