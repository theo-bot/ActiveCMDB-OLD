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
 * 	JS Function(s) to support device maintenance
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

$(document).ready(function(){
	
	jQuery("#maintTable").jqGrid({ 
		url:'/maintenance/api?oper=list', 
		datatype: "json",
		colNames:['Description', 'Start date', 'End date','Start time','End time','Repeat','Interval'],
		colModel: [
		           	{name:'descr',index:'descr', width:128, editable:true, searchoptions: {sopt:['eq','ne','cn']}, required:true, formoptions:{ elmsuffix:" (*)"}}, 
		           	{
		           		name:'start_date',
		           		index:'start_date',
		           		width:128, 
		           		editable:true,
		           		
		           	},
		           	{
		           		name:'end_date',
		           		index:'end_date', 
		           		width:128, 
		           		editable:true, 
		           		searchoptions: {sopt:['eq','ne','cn']}, 
		           		required:false, 
		           	},
		           	{
		           		name:'start_time',
		           		index:'start_time', 
		           		width:128, 
		           		editable:true,
		           		edittype: 'text',
		           		required:true,
		           	},
		           	{
		           		name:'end_time',
		           		index:'end_time', 
		           		width:128, 
		           		editable:true, 
		           		required:true,
		           		
		           	},
		           	{
		           		name:'m_repeat',
		           		index:'m_repeat',
		           		width:64,
		           		editable:true,
		           		required:true,
		           		formatter:'integer',
		           		formatOptions:{defaulValue:"0"},
		           	},
		           	{
		           		name:'m_interval',
		           		index:'m_interval',
		           		width:64,
		           		
		           	}
		          ],
		rowNum:10, 
		rowList:[10,20,30],
		height: 200,
		hidegrid: false,
		pager: '#maintPager', 
		sortname: 'maint_id', 
		viewrecords: true, 
		sortorder: "asc", 
		editurl: "/maintenance/api", 
		caption: "Maintenance schedules",
		ondblClickRow: function(id) {
			$.colorbox({
					iframe:true,
					width:740,
					height:480,
					initialWidth:640,
					initialHeight:480,
					href:'/maintenance/view?maint_id=' + id,
					onClosed:function(){ 
						$("#maintTable").trigger("reloadGrid");
					} 
			});
		},
	});
	
	jQuery("#maintTable").jqGrid('navGrid','#maintPager', 
			{
				view:false,
				edit:false,
				save: false,
				del: false
			}, //options 
			{
				height:280,
				reloadAfterSubmit:false,
				onInitializeForm: function() { 
					var dtFormat = $('#dateFormat').val();
					$('#start_date').datepicker({
						changeYear: true,
						dateFormat: dtFormat 
					});
					$('#end_date').datepicker({
						changeYear: true,
						dateFormat: dtFormat
					});
					$('#start_time').timepicker({stepMinute: 5});
					$('#end_time').timepicker({stepMinute: 5});
				},
				onClose: function() { $('.hasDatepicker').datepicker("hide"); }
			}, // edit options 
			{
				height:280,
				reloadAfterSubmit:false,
				onInitializeForm: function() { 
					var dtFormat = $('#dateFormat').val();
					$('#start_date').datepicker({
						changeYear: true,
						dateFormat: dtFormat
					});
					$('#end_date').datepicker({
						changeYear: true,
						dateFormat: dtFormat
					});
					$('#start_time').timepicker({stepMinute: 5});
					$('#end_time').timepicker({stepMinute: 5});
				},
				onClose: function() { $('.hasDatepicker').datepicker("hide"); }
			}, // add options 
			{reloadAfterSubmit:false}, // del options 
			{} // search options 
	);
	
	$('#startDate').datepicker({
		dateFormat: "yy-mm-dd",
				
	});
	
	$('#endDate').datepicker({
		dateFormat: "yy-mm-dd",
		changeMonth: true,
		changeYear: true
	});
	
	/*
	$('#MRepeat').spinner({
		min: 0,
		max: 99
	})
	*/
	
	$("#Slider5").slider({
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
	
	$('#maintSave').click(function() {
		var maint = $('#maintForm').serialize();
		$.ajax({
			url: "/maintenance/save",
			type: "POST",
			dataType: "json",
			data: maint,
			statusCode: {
				200: function() { parent.$.fn.colorbox.close(); },
				401: function() { alert('Unauthorized'); }, 
				500: function() { alert('Failed to save'); }
			}
		});
	});
	
	$('#maintDisc').click(function() {
		var question = "Delete maintenance schedule: " + $("#maintDesc");
		var r = confirm(question);
		if ( r == true )
		{
			var maint_id = $('#maintId').val();
			$.ajax({
				url: "/maintenance/del",
				type: "POST",
				dataType: "json",
				data: { maint_id: maint_id },
				statusCode: {
					200: function() { parent.$.fn.colorbox.close(); },
					401: function() { alert('Unauthorized'); },
					500: function() { alert('Failed to delete'); }
				}
			});
		}
	});
});

