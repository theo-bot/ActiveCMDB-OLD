/*
 * 	Script:	activecmdb.import.js
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
	jQuery("#importTable").jqGrid({ 
		url:'/import/api?oper=list', 
		datatype: "json",
		colNames:['Filename', 'Username','Object type', 'Uploaded', 'Entries'],
		colModel: [
		           	{
		           		name:'filename',
		           		index:'filename', 
		           		width:196, 
		           		editable:false, 
		           		search: false,
		           		required:true, 
		           	}, 
		           	{
		           		name:'username',
		           		index:'username',
		           		width:128, 
		           		searchoptions: {sopt:['eq','ne','cn']}, 
		           		editable:false,
		           	},
		           	{
		           		name:'object_type',
		           		index:'object_type',
		           		width:128
		           	},
		           	{
		           		name: 'upload_time',
		           		index: 'upload_time',
		           		width: 128
		           	},
		           	{
		           		name: 'tally',
		           		index: 'tally',
		           		width: 64
		           	}
		          ],
		rowNum:10, 
		rowList:[10,20,30], 
		pager: '#importPager', 
		sortname: 'role',
		hidegrid: false,
		viewrecords: true, 
		sortorder: "asc", 
		editurl: "/import/api", 
		caption: "Import",
		ondblClickRow: function(id) {
			$.colorbox({
				iframe:true,
				width:480,
				height:480,
				initialWidth:480,
				initialHeight:480,
				href:'/import/edit?id=' + id,
				onClosed:function(){ 
					$("#importTable").trigger("reloadGrid");
				} 
			});
		}
	});
	
	jQuery("#importTable").jqGrid('navGrid',"#importPager",
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
						href:'/import/add',
						onClosed:function(){
							$("#importTable").trigger("reloadGrid");
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
						href:'/import/edit',
						onClosed:function(){ 
							$("#importTable").trigger("reloadGrid");
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
	
	jQuery("#importTable").jqGrid('inlineNav',"#importPager", {edit: false, add:false, cancel:false, save:false});

	$("#impUpdate").click(function() {
		var data = $("#importEditForm").serialize();
		$.post(
				'/import/update',
				data,
				function(data) {
					$('#response').html(data).show().delay(5000).hide('slow');
					
				},
				'html'
		);
	});
	
	
	/*
	 * 
	 * Action for pressing the discard button
	 * 
	 */
	
	$("#impDisc").click(function() {
		var data = $("#importEditForm").serialize();
		$.post(
				'/import/discard',
				data,
				function(data) {
					$('#response').html(data).show().delay(5000).hide('slow');
				},
				'html'
		);
	});
	
	/*
	 * 
	 * Action for pressing the import button
	 * 
	 */
	
	$("#impStart").click(function(){
		var data = $("#importEditForm").serialize();
		var importid = $("#importID").val();
		$.post(
			'/import/import_start',
			data,
			function(data) {
				$('#importProgress').show();
				$('#importProgress').progressbar({
						value: 0	
				});
				var val = 0;
				var interval = setInterval(function(){
									$.get( "/import/import_progress?id=" + importid,
												function(val) {
													$("#importProgress").progressbar({ value: val });
									});
									if ( val == 100 ) {	
										clearInterval(interval);
									}
							   }, 1000);
			}
		);
	});
});