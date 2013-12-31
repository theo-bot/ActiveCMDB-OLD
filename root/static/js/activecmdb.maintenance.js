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
		           		editoptions: {
		           			size: 10,
		           			maxlength: 10
		           		}
		           	},
		           	{
		           		name:'end_time',
		           		index:'end_time', 
		           		width:128, 
		           		editable:true, 
		           		required:true,
		           		editoptions: {
		           			size: 10,
		           			maxlength: 10
		           		}
		           	},
		           	{
		           		name:'m_repeat',
		           		index:'m_repeat',
		           		width:64,
		           		editable:true,
		           		required:true,
		           		formatter:'integer',
		           		formatOptions:{defaulValue:"0"},
		           		editrules:{integer:true, minValue:0, maxValue:99}
		           	},
		           	{
		           		name:'m_interval',
		           		index:'m_interval',
		           		width:64,
		           		editable:true,
		           		edittype:'select',
		           		editoptions: {
			        		  dataUrl: "/maintenance/api?oper=intervals"
			        	}
		           		
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
		
	});
	
	jQuery("#maintTable").jqGrid('navGrid','#maintPager', 
			{ view:true }, //options 
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
});

