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
 * 	JS Function(s) to support user management
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
	
	$( '#updPasswd' ).click(function() {
		var data = $( '#passwdForm' ).serialize();
		
		$.post('/users/passwd',
				data,
				function(data) {
					$('#response').html(data).show().delay(5000).hide('slow');
					$('input[name*="pass"]').val('');
				},
				'html'
		);
	});
	
	$.configureBoxes();
	
	$( '#saveUser' ).click(function() {
		$("#box2View option").attr("selected","selected"); 
		var data = $( '#userForm' ).serialize();
		
		$.post('/users/save',
			data,
			function(data) {
				$('#response').html(data).show().delay(5000).hide('slow');
				$('#saveUser').prop("disabled", true);
				/* $('#saveUser').removeClass('cmdbButtonOff').addClass('cmdbButton'); */
			},
			'html'
		);
	});
	
	$( "#userForm input" ).change(function() {
		$('#saveUser').prop("disabled", false);
		/* $('#saveUser').removeClass('cmdbButtonOff').addClass('cmdbButton'); */
	});
	
	$( "#userForm button" ).click(function() {
		$('#saveUser').prop("disabled", false);
		/* $('#saveUser').removeClass('cmdbButtonOff').addClass('cmdbButton'); */
	});
	
	
	$( '#deleteUser' ).click(function() {
		var data = $('#userForm').serialize();
		
		$.post('/users/delete',
				data,
				function(data) {
					$('#response').html(data).show().delay(5000).hide('slow');
					$('#userForm input').prop("disabled", true);
					$('#userForm button').prop("disabled", true);
					$('#saveUser').prop("disabled", true);
					$('#deleteUser').prop("disabled", true);
				}
		);
	});
	
});