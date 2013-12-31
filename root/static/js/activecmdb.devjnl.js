/*
 * 	Script:	activecmdb.devjnl.js
 * 	___________________________________________________________
 *
 * 	Copyright (C) 2011-2015 Theo Bot
 *
 * 	http://www.activecmdb.org
 *
 * 	Topic: Purpose
 *
 * 	JS Library to support device journals
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
	var device_id = $( "#device_id" ).val();
	jQuery("#jnlTable").jqGrid({ 
		url:'/journal/api?device_id=' + device_id + '&oper=list',
		datatype: "json",
		colNames:['Date', 'User', 'Data'],
		colModel:[
		          {
		        	  name:'journal_date',
		        	  index:'journal_date', 
		        	  width:132, 
		        	  align:"left",
		        	  editable:false,
		          },
		          {
		        	  name:'user',
		        	  index:'user', 
		        	  width:132, 
		        	  align:"left",
		        	  editable:false,
		          },
		          {
		        	  name:'journal_data',
		        	  index:'journal_data', 
		        	  width:396, 
		        	  align:"left",
		        	  editable:true,
		        	  edittype:'textarea',
		        	  editoptions: {rows:"4",cols:"40"}
		          }
		         ],
		rowNum:10, rowList:[10,20,30],
		hidegrid: false,
		sortname: 'journal_date', 
		viewrecords: true, 
		sortorder: "asc", 
		caption: "Journal",
		pager: '#jnlPager',
		editurl: "/journal/api", 
	});
	
	/*
	 *  Navigator properties
	 */
	jQuery("#jnlTable").jqGrid('navGrid',"#jnlPager",
			{
				view:true, 
				del:false,
			},
			{
				/* Edit parameters */
				height:150, 
				width:350,
				editCaption: "Edit journal",
				
			},
			{
				/* Add parameters */
				height:150, 
				width: 350,
				addCaption: "Add journal",
				onclickSubmit: function(params, postdata)
				{
					postdata.device_id = device_id
				},
			}
	);
	
	jQuery("#jnlTable").jqGrid('inlineNav',"#jnlPager", {edit: false, add:false, cancel:false, save:false});
});