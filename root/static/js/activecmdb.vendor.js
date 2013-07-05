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
 * 	JS Function(s) to support vendor management
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
	
	$('#vendorForm').validate({
		rules: {
			supportmail: {
				required: true,
				email: true
			},
			name: {
				required: true,
				minlength: 4
			},
			supportweb: {
				minlength: 4
			}
		},
		messages: {
			supportmail: "Please enter a valid e-mail address",
			name: {
				required: "Please provide a name for the vendor",
				minlength: "Vendorname should contain at least 4 characters"
			}
		},
		submitHandler: function(form) {
			var data = $('#vendorForm').serialize();

			$.post('/vendor/save',
					data,
					function(data) {
						$('#response').html(data).show().delay(5000).hide('slow');
						$('#saveVendor').prop("disabled", true);
					},
					'html'
				);
					
		},
			
		invalidHandler: function(form) {
			$('#response').text('Correct errors first.');
		},
		errorPlacement: function(error, element) {
			error.insertAfter('#deleteVendor');
		}

	});
	
	jQuery("#vendorTable").jqGrid({ 
		url:'/vendor/api?oper=list', 
		datatype: "json",
		colNames:['Name','Support phone', 'E-Mail','Website'],
		colModel: [
		            {
		            	name:'vendor_name',
		            	index:'vendor_name',
		            	width:128
		            },
		            {
		            	name:'vendor_support_phone',
		            	index:'vendor_support_phone',
		            	width:196
		            },
		            {
		           		name:'vendor_support_email',
		           		index:'vendor_support_email',
		           		width: 128
		           	},
		           	{
		           		name:'vendor_support_www',
		           		index:'vendor_support_www',
		           		width:128, 		           		
		           	}
		          ],
		rowNum:10, 
		rowList:[10,20,30], 
		pager: '#vendorPager', 
		sortname: 'vendor_id', 
		hidegrid: false,
		viewrecords: true, 
		sortorder: "asc", 
		editurl: "/vendor/api", 
		caption: "Vendor Maintenance",
		ondblClickRow: function(id) {
			$.colorbox({
				iframe:true,
				width:740,
				height:650,
				initialWidth:640,
				initialHeight:650,
				href:'/vendor/edit?id=' + id,
				onClosed:function(){ 
					$("#vendorTable").trigger("reloadGrid");
				} 
			});
		},
		
	});
	
	jQuery("#vendorTable").jqGrid('navGrid',"#vendorPager",
			{	view:false, 
				edit:false, 
				add:true, 
				save:false, 
				del:false, 
				addfunc: function() { 
					$.colorbox({iframe:true,width:740,height:650,initialWidth:640,initialHeight:650,href:'/vendor/add' });
				},
				editfunc: function() {
					$.colorbox({
						iframe:true,
						width:740,
						height:650,
						initialWidth:640,
						initialHeight:650,
						href:'/vendor/edit',
						onClosed:function(){ 
							$("#vendorTable").trigger("vendor");
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
	
	jQuery("#vendorTable").jqGrid('inlineNav',"#vendorPager", {edit: false, add:false, cancel:false, save:false});
	
});


