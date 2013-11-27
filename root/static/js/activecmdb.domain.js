/*
 * 	Script:	activecmdb.domain.js
 * 	___________________________________________________________
 *
 * 	Copyright (C) 2011-2015 Theo Bot
 *
 * 	http://www.activecmdb.org
 *
 * 	Topic: Purpose
 *
 * 	JS Library for ip domain management
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
 *  $Id: main.css 45 2011-05-01 12:54:25Z theob $
 *
 */
$(document).ready(function(){
	var domain_id= $("#id").val();
	jQuery("#netTable").jqGrid({ 
		
		url:'/ipdomain/network?oper=list&domain_id=' + domain_id, 
		datatype: "json", 
		colNames:['Network', 'Mask', 'Mask length','Active','Read Comm','Write Comm','User','Password','AuthUser','AuthKey','AuthProto','PrivKey', 'PrivProto'], 
		colModel:[
		         
		          {name:'ip_network',index:'ip_network', width:132, editable:true, searchoptions: {sopt:['eq','ne','cn']}, required:true, formoptions:{ elmsuffix:" (*)"}}, 
		          {name:'ip_mask',index:'ip_mask', width:80,editable:true, search:false, required:false}, 
		          {name:'ip_masklen',index:'ip_masklen', width:70, align:"right",editable:true, search:false}, 
		          {name:'active',index:'active', width:50, align:"right",editable:true,edittype:"checkbox", value:"1", offval:"0", formatter:"checkbox", search:false}, 
		          {name:'snmp_ro',index:'snmp_ro', width:80,hidden:true,align:"right",editable:true,editrules: { edithidden: true }}, 
		          {name:'snmp_rw',index:'snmp_rw', width:80,hidden:true, sortable:false,editable:true,editrules: { edithidden: true }},
		          {name:'telnet_user',index:'telnet_user',width:80, sortable:false,editable:true, search:false},
		          {name:'telnet_pwd',index:'telnet_pwd',width:80,hidden:true, sortable:false, editable:true, search:false,editrules: { edithidden: true }},
		          {name:'snmpv3_user', index:'snmpv3_user',width:80,hidden:false, sortable:false,editable:true,editrules: { edithidden: true }},
		          {name:'snmpv3_pass1',index:'snmpv3_pass1',width:80,hidden:true,sortable:false,editable:true,editrules: { edithidden: true }},
		          {name:'snmpv3_proto1',index:'snmpv3_proto1',width:60,hidden:true,edittype:"select",editoptions:{value:"sha:SHA;md5:MD5"},editable:true,editrules: { edithidden: true }},
		          {name:'snmpv3_pass2',index:'snmpv3_pass2',width:80,hidden:true,sortable:false,editable:true,editrules: { edithidden: true }},
		          {name:'snmpv3_proto2',index:'snmpv3_proto2',width:60,hidden:true,edittype:"select",editoptions:{value:"des:DES;aes:AES"},editable:true,editrules: { edithidden: true }}
		          ], 
		          rowNum:10, rowList:[10,20,30], 
		          pager: '#netPager', 
		          sortname: 'domain_id', 
		          hidegrid: false,
		          viewrecords: true, 
		          sortorder: "desc", 
		          editurl: "/ipdomain/network?domain_id=" + domain_id, 
		          caption: "Networks",
		          ondblClickRow: function(rowid){
		        	  jQuery('#netTable').jqGrid('editGridRow', rowid);
		          }
	}); 

	jQuery("#netTable").jqGrid('navGrid',"#netPager",
			{
				view:true, 
				edit:false
			},
			{
				height:430,
				reloadAfterSubmit:true, 
				jqModal:false, 
				closeOnEscape:true, 
				bottominfo:"Fields marked with (*) are required"
			},
			{
				height:430,
				reloadAfterSubmit:true,
				jqModal:false, 
				closeOnEscape:true,
				bottominfo:"Fields marked with (*) are required", 
				closeAfterAdd: true
			},
			{
				reloadAfterSubmit:false,
				jqModal:false, 
				closeOnEscape:true
			},
			{
				closeOnEscape:true
			},
			{
				height:350,
				jqModal:false,
				closeOnEscape:true
			}
	); 
	jQuery("#netTable").jqGrid('inlineNav',"#netPager", {edit: false, add:false, cancel:false, save:true});
	
	
		
	jQuery("#domainTable").jqGrid({ 
		url:'/ipdomain/api?oper=list_domains', 
		datatype: "json",
		colNames:['Domain name','Networks'],
		colModel: [
		            {
		            	name:'domain_name',
		            	index:'domain_name',
		            	width:256
		            },
			        {
			           	name:'tally',
			           	index:'tally',
			           	width:196
			        }     
			          ],
			rowNum:10, 
			rowList:[10,20,30], 
			pager: '#domainPager', 
			sortname: 'contract_id', 
			hidegrid: false,
			viewrecords: true, 
			sortorder: "asc", 
			editurl: "/ipdomain/api", 
			caption: "IP Domain Administration",
			ondblClickRow: function(id) {
				$.colorbox({
					iframe:true,
					width:740,
					height:650,
					initialWidth:640,
					initialHeight:650,
					href:'/ipdomain/view?domain_id=' + id,
					onClosed:function(){ 
						$("#domainTable").trigger("reloadGrid");
					} 
				});
			},
			
		});
		
		jQuery("#domainTable").jqGrid('navGrid',"#domainPager",
				{	view:false, 
					edit:false, 
					add:true, 
					save:false, 
					del:false
				},
				{height:350,reloadAfterSubmit:true, jqModal:false, closeOnEscape:true},
				{height:350,reloadAfterSubmit:true,jqModal:false, closeOnEscape:true,bottominfo:"Fields marked with (*) are required", closeAfterAdd: true},
				{reloadAfterSubmit:false,jqModal:false, closeOnEscape:true},
				{closeOnEscape:true},
				{height:350,jqModal:false,closeOnEscape:true}
		); 
		
		jQuery("#domainTable").jqGrid('inlineNav',"#domainPager", {edit: false, add:false, cancel:false, save:false});
	
		
		$('#domainForm').on('change', 'input', function(e) {
			var newvalue = this.value;
			var domain_id = $("#id").val();
			if ( this.type == 'checkbox' && this.checked == true ) { newvalue = 1; }
			if ( this.type == 'checkbox' && this.checked == false ) { newvalue = 0; }
			newdata = { field: this.name, value: newvalue, oper: "update_domain", domain_id: domain_id };
			$.ajax({
				dataType: "json",
				url: "/ipdomain/api",
				data: newdata
				
			});
		});
		
});