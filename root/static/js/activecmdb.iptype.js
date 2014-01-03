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
 * 	JS Function(s) to support ip device type management
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
	
	jQuery("#typeTable").jqGrid({ 
		
		url:'/iptype/api?oper=list', 
		datatype: "json", 
		colNames:['Description', 'sysObjectID', 'Active','Vendor','Discovery','Image'], 
		colModel:[
		          {name:'descr',index:'descr', width:132, editable:true, searchoptions: {sopt:['eq','ne','cn']}, required:true, formoptions:{ elmsuffix:" (*)"}}, 
		          {name:'sysobjectid',index:'sysobjectid', width:132,editable:true, search:false, required:false}, 
		          {name:'active',index:'active', width:50, align:"center",editable:true,edittype:"checkbox", editoptions: { value:"1:0"}, formatter:"checkbox", search:false}, 
		          {
		        	  name:'vendor_id',
		        	  index:'vendor_name', 
		        	  width:132, 
		        	  align:"left",
		        	  editable:true,
		        	  edittype:"select",
		        	  editoptions: {
		        		  dataUrl: "/iptype/api?oper=vendors"
		        	  }
		          }, 
		          {	
		        	  name:'disco_scheme',
		        	  index:'disco_scheme', 
		        	  width:80,
		        	  hidden:false,
		        	  align:"left",
		        	  editable:true,
		        	  edittype:"select",
		        	  editoptions: {
		        		  dataUrl: "/iptype/api?oper=disco"
		        	  }
		        	},
		        	{
		        		name:'image',
		        		index:'image',
		        		width:50,
		        		hidden: false,
		        		editable: false,
		        		formatter: function() {
		        			return "<span class='ui-icon ui-icon-image'></span>"
		        		},
		        		cellattr: function (rowId,tv,rawObject,rdata) {
		        			return 'onClick="device_image(' + rowId + ');"'
		        		}
		        	}
		          ], 
		rowNum:10, rowList:[10,20,30], 
		pager: '#typePager', 
		sortname: 'vendor_id', 
		viewrecords: true,
		hidegrid: false,
		sortorder: "asc", 
		editurl: "/iptype/api", 
		caption: "Device types",
		ondblClickRow: function(id) {
			$.colorbox({
					iframe:true,
					width:740,
					height:650,
					initialWidth:640,
					initialHeight:650,
					href:'/iptype/view?type_id=' + id,
					onClosed:function(){ 
						$("#typeTable").trigger("reloadGrid");
					} 
				});
			},
	}); 

	jQuery("#typeTable").jqGrid('navGrid',"#typePager",
			{
				view:false,
				edit:false,
				save:false, 
				del:false, 
				addfunc: function() { 
					$.colorbox({
						iframe:true,
						width:740,
						height:650,
						initialWidth:640,
						initialHeight:650,
						href:'/iptype/view?type_id=',
						onClosed:function(){
							$("#typeTable").trigger("reloadGrid");
						}
					});
				}
			}
	); 
	jQuery("#typeTable").jqGrid('inlineNav',"#typePager", {edit: false, add:false, cancel:false, save:false});
	
	$("#typeSave").click(function() {
		var typeData = $("#typeForm").serialize();
		$.ajax({
			url: "/iptype/save",
			type: "POST",
			dataType: "json",
			data: typeData,
			statusCode: {
				200: function() { parent.$.fn.colorbox.close(); },
				401: function() { alert('Unauthorized'); },
				500: function() { alert('Failed to save'); }
			}
		});
	});
	
	$('#typeDisc').click(function() {
		var question = "Delete device type: " + $("#typeDesc").val() + ' (' + $('#typeOid').val() + ')';
		var r = confirm(question);
		if ( r == true )
		{
			var type_id = $('#typeID').val();
			$.ajax({
				url: "/iptype/del",
				type: "POST",
				dataType: "json",
				data: { type_id: type_id },
				statusCode: {
					200: function() { parent.$.fn.colorbox.close(); },
					401: function() { alert('Unauthorized'); },
					500: function() { alert('Failed to delete'); }
				}
			});
		}
	});
	
});


function device_image(id) {
	$.colorbox({iframe:true,width:512,height:381,initialWidth:480,initialHeight:220,href:'/iptype/image?id=' + id});
}