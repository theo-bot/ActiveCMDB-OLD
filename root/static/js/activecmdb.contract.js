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
 * 	JS Function(s) to support contract maintenance
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
	
	jQuery("#contractTable").jqGrid({ 
		url:'/contract/api?oper=list', 
		datatype: "json",
		colNames:['Number','Description', 'Vendor','Start date', 'End date'],
		colModel: [
		            {
		            	name:'contract_number',
		            	index:'contract_number',
		            	width:128
		            },
		            {
		            	name:'contract_descr',
		            	index:'contract_descr',
		            	width:196
		            },
		            {
		           		name:'vendor_name',
		           		index:'vendor_name',
		           		width: 128
		           	},
		           	{
		           		name:'start_date',
		           		index:'start_date',
		           		width:128, 		           		
		           	},
		           	{
		           		name:'end_date',
		           		index:'end_date', 
		           		width:128, 
		           		searchoptions: {sopt:['eq','ne','cn']}, 
		           		required:false, 
		           	}
		          ],
		rowNum:10, 
		rowList:[10,20,30], 
		pager: '#contractPager', 
		sortname: 'contract_id', 
		viewrecords: true, 
		sortorder: "asc", 
		editurl: "/contract/api", 
		caption: "Contract Maintenance",
		ondblClickRow: function(id) {
			$.colorbox({
				iframe:true,
				width:740,
				height:650,
				initialWidth:640,
				initialHeight:650,
				href:'/contract/edit?id=' + id,
				onClosed:function(){ 
					$("#epTable").trigger("reloadGrid");
				} 
			});
		},
		
	});
	
	jQuery("#contractTable").jqGrid('navGrid','#contractPager', 
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
				},
				onClose: function() { $('.hasDatepicker').datepicker("hide"); }
			}, // add options 
			{reloadAfterSubmit:false}, // del options 
			{} // search options 
	);
});

