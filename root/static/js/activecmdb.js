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
 * 	Generic JS Function(s) 
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
/*
 *  Pure Javascript functions
 */

function edit_role(role_id)
{
	
	jQuery().colorbox({width:450,height:220,href:'/roles/edit?role_id=' + role_id,onClosed:function(){ location.reload(true); } });
}

function edit_user(user_id)
{
	jQuery().colorbox({width:650,height:450,href:'/users/edit?user_id=' + user_id,onClosed:function(){ location.reload(true); } });
}

function setpass(user_id)
{
	jQuery().colorbox({
		width:450,
		height:250,
		href:'/users/edit?user_id=' + user_id,
		onClosed:function(){ location.reload(true); } 
	});
}


