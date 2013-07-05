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
		hidegrid: false,
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
					$("#contractTable").trigger("reloadGrid");
				} 
			});
		},
		
	});
	
	jQuery("#contractTable").jqGrid('navGrid',"#contractPager",
			{	view:false, 
				edit:false, 
				add:true, 
				save:false, 
				del:false, 
				addfunc: function() { 
					$.colorbox({iframe:true,width:740,height:650,initialWidth:640,initialHeight:650,href:'/contract/add' });
				},
				editfunc: function() {
					$.colorbox({
						iframe:true,
						width:740,
						height:650,
						initialWidth:640,
						initialHeight:650,
						href:'/endpoint/edit',
						onClosed:function(){ 
							$("#contractTable").trigger("reloadGrid");
							alert('CBOX Closed');
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
	
	jQuery("#contractTable").jqGrid('inlineNav',"#contractPager", {edit: false, add:false, cancel:false, save:false});
	
	$("#start_date").datepicker({ dateFormat: "yy-mm-dd", changeMonth: true, changeYear: true });
	$("#end_date").datepicker({ dateFormat: "yy-mm-dd", changeMonth: true, changeYear: true });
});

