/*
 * 	Script:	activecmdb.admin.js
 * 	___________________________________________________________
 *
 * 	Copyright (C) 2011-2015 Theo Bot
 *
 * 	http://www.activecmdb.org
 *
 * 	Topic: Purpose
 *
 * 	Javascript library
 *
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
 */

$(document).ready(function(){
	
	/*
	 * 
	 * Role management
	 * 
	 */
	jQuery("#rolesTable").jqGrid({ 
		url:'/roles/api?oper=list', 
		datatype: "json",
		colNames:['Role id', 'Role name'],
		colModel: [
		           	{
		           		name:'id',
		           		index:'id', 
		           		width:128, 
		           		editable:false, 
		           		search: false,
		           		required:true, 
		           	}, 
		           	{
		           		name:'role',
		           		index:'role',
		           		width:256, 
		           		searchoptions: {sopt:['eq','ne','cn']}, 
		           		editable:false,
		           		
		           	}
		          ],
		rowNum:10, 
		rowList:[10,20,30], 
		pager: '#rolesPager', 
		sortname: 'role',
		hidegrid: false,
		viewrecords: true, 
		sortorder: "asc", 
		editurl: "/roles/api", 
		caption: "User role management",
		ondblClickRow: function(id) {
			$.colorbox({
				iframe:true,
				width:480,
				height:240,
				initialWidth:480,
				initialHeight:240,
				href:'/roles/edit?id=' + id,
				onClosed:function(){ 
					$("#rolesTable").trigger("reloadGrid");
				} 
			});
		}
	});
	
	jQuery("#rolesTable").jqGrid('navGrid',"#rolesPager",
			{	view:false, 
				edit:false, 
				add:true, 
				save:false, 
				del:false, 
				addfunc: function() { 
					$.colorbox({
						iframe:true,
						width:480,
						height:240,
						initialWidth:480,
						initialHeight:240,
						href:'/roles/add',
						onClosed:function(){
							$("#rolesTable").trigger("reloadGrid");
						}
					});
				},
				editfunc: function() {
					$.colorbox({
						iframe:true,
						width:480,
						height:240,
						initialWidth:480,
						initialHeight:240,
						href:'/roles/edit',
						onClosed:function(){ 
							$("#rolesTable").trigger("reloadGrid");
						} 
					});
				}
			},
			{height:350,reloadAfterSubmit:true, jqModal:false, closeOnEscape:true},
			{height:350,reloadAfterSubmit:true,jqModal:false, closeOnEscape:true,bottominfo:"Fields marked with (*) are required", closeAfterAdd: true},
			{reloadAfterSubmit:false,jqModal:false, closeOnEscape:true},
			{closeOnEscape:true},
			{height:350,jqModal:false,closeOnEscape:true}
	); 
	
	jQuery("#rolesTable").jqGrid('inlineNav',"#rolesPager", {edit: false, add:false, cancel:false, save:false});

	/*
	 * 
	 * Users management
	 * 
	 */
	jQuery("#usersTable").jqGrid({ 
		url:'/users/api?oper=list', 
		datatype: "json",
		colNames:['Username', 'First name', 'Last name', 'Active'],
		colModel: [
		           	{
		           		name:'username',
		           		index:'username', 
		           		width:128, 
		           		editable:false, 
		           		searchoptions: {sopt:['eq','ne','cn']},
		           		required:true, 
		           	}, 
		           	{
		           		name:'first_name',
		           		index:'first_name',
		           		width:256, 
		           		searchoptions: {sopt:['eq','ne','cn']}, 
		           		editable:false,
		           		
		           	},
		           	{
		           		name:'last_name',
		           		index:'last_name',
		           		width:256, 
		           		searchoptions: {sopt:['eq','ne','cn']}, 
		           		editable:false,
		           		
		           	},
		           	{
		           		name:'active',
		           		index:'active',
		           		width:128, 
		           		search: false, 
		           		editable:false,
		           		
		           	},
		          ],
		rowNum:10, 
		rowList:[10,20,30], 
		pager: '#usersPager', 
		sortname: 'username',
		hidegrid: false,
		viewrecords: true, 
		sortorder: "asc", 
		editurl: "/users/api", 
		caption: "User management",
		ondblClickRow: function(id) {
			$.colorbox({
				iframe:true,
				width:640,
				height:480,
				initialWidth:640,
				initialHeight:480,
				href:'/users/edit?id=' + id,
				onClosed:function(){ 
					$("#usersTable").trigger("reloadGrid");
				} 
			});
		}
	});
	
	jQuery("#usersTable").jqGrid('navGrid',"#usersPager",
			{	view:false, 
				edit:false, 
				add:true, 
				save:false, 
				del:false, 
				addfunc: function() { 
					$.colorbox({
						iframe:true,
						width:480,
						height:240,
						initialWidth:480,
						initialHeight:240,
						href:'/users/add',
						onClosed:function(){
							$("#usersTable").trigger("reloadGrid");
						}
					});
				},
				editfunc: function() {
					$.colorbox({
						iframe:true,
						width:480,
						height:240,
						initialWidth:480,
						initialHeight:240,
						href:'/users/edit',
						onClosed:function(){ 
							$("#usersTable").trigger("reloadGrid");
						} 
					});
				}
			},
			{height:350,reloadAfterSubmit:true, jqModal:false, closeOnEscape:true},
			{height:350,reloadAfterSubmit:true,jqModal:false, closeOnEscape:true,bottominfo:"Fields marked with (*) are required", closeAfterAdd: true},
			{reloadAfterSubmit:false,jqModal:false, closeOnEscape:true},
			{closeOnEscape:true},
			{height:350,jqModal:false,closeOnEscape:true}
	); 
	
	jQuery("#usersTable").jqGrid('inlineNav',"#rolesPager", {edit: false, add:false, cancel:false, save:false});

});