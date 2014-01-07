/*
 * 	Script:	activecmdb.disco.js
 * 	___________________________________________________________
 *
 * 	Copyright (C) 2011-2015 Theo Bot
 *
 * 	http://www.activecmdb.org
 *
 * 	Topic: Purpose
 *
 * 	JS Function(s) to support discovery schemas
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
 *
 */

$(document).ready(function(){
	
	jQuery("#discoTable").jqGrid({ 
		url:'/disco/api?oper=list', 
		datatype: "json",
		colNames:['Description', 'Active', 'Block 1','Block 2'],
		colModel: [
		           	{
		           		name:'name',
		           		index:'namer', 
		           		width:128, 
		           	}, 
		           	{
		           		name:'Active',
		           		index:'active',
		           		width:128, 		           		
		           	},
		           	{
		           		name:'block1',
		           		index:'block1', 
		           		width:128, 
		           	},
		           	{
		           		name:'block2',
		           		index:'block2', 
		           		width:128,
		           	},
		          ],
		rowNum:10, 
		rowList:[10,20,30],
		height: 200,
		hidegrid: false,
		pager: '#discoPager', 
		sortname: 'scheme_id', 
		viewrecords: true, 
		sortorder: "asc", 
		editurl: "/disco/api", 
		caption: "Discovery schemas",
		ondblClickRow: function(id) {
			$.colorbox({
					iframe:true,
					width:740,
					height:480,
					initialWidth:640,
					initialHeight:480,
					href:'/disco/view?scheme_id=' + id,
					onClosed:function(){ 
						$("#discoTable").trigger("reloadGrid");
					} 
			});
		},
	});
	
	jQuery("#discoTable").jqGrid('navGrid','#discoPager', 
			{
				view:false,
				edit:false,
				save: false,
				del: false,
				addfunc: function() { 
					$.colorbox({
						iframe:true,
						width:740,
						height:480,
						initialWidth:640,
						initialHeight:480,
						href:'/disco/view?type_id=',
						onClosed:function(){
							$("#discoTable").trigger("reloadGrid");
						}
					});
				}
			}
	);
	
	$("#Slider1").slider({
		from: 0,
		to: 1439,
		step: 5,
		dimension: '',
		scale: ['0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00','23:59'],
		limits: false,
		calculate: function( value ){
			var hours = Math.floor( value / 60 );
			var mins = ( value - hours*60 );
			return (hours < 10 ? "0"+hours : hours) + ":" + ( mins == 0 ? "00" : mins );
		}
	});
	
	$("#Slider2").slider({
		from: 0,
		to: 1439,
		step: 5,
		dimension: '',
		scale: ['0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00','23:59'],
		limits: false,
		calculate: function( value ){
			var hours = Math.floor( value / 60 );
			var mins = ( value - hours*60 );
			return (hours < 10 ? "0"+hours : hours) + ":" + ( mins == 0 ? "00" : mins );
		}
	});
	
	$('#discoSave').click(function() {
		var disco = $('#discoForm').serialize();
		var name = $('#name').val();
		if ( name.length > 0 )
		{
			$.ajax({
				url: "/disco/save",
				type: "POST",
				dataType: "json",
				data: disco,
				statusCode: {
					200: function() { parent.$.fn.colorbox.close(); },
					401: function() { alert('Unauthorized'); }, 
					500: function() { alert('Failed to save'); }
				}
			});
		} else {
			alert('Name is required');
		} 
	});
	
	$('#discoDisc').click(function() {
		var question = "Delete maintenance schedule: " + $("#name").val();
		var r = confirm(question);
		if ( r == true )
		{
			var scheme_id = $('#schemeId').val();
			$.ajax({
				url: "/disco/del",
				type: "POST",
				dataType: "json",
				data: { scheme_id: scheme_id },
				statusCode: {
					200: function() { parent.$.fn.colorbox.close(); },
					401: function() { alert('Unauthorized'); },
					500: function() { alert('Failed to delete'); }
				}
			});
		}
	});
});