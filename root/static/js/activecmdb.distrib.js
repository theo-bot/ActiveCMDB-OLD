/*
 * 	Script:	activecmdb.distrib.js
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

var ruleopr = {
	source: function( request, response ) {
		$.ajax({
			url: "/distrule/find_by_ruleopr",
			dataType: "json",
			data: {
				featuteClass: "rule",
				style: "full",
				maxRows: 12,
				name_startsWith: request.term
			},
			success: function( data ) {
				response( $.map(data.names, function( item ) {
					return {
						label: item.name,
						value: item.id
					}
				}));
			},
			error: function (xhr, ajaxOptions, thrownError) {
				alert( xhr.status );
				alert( thrownError );
			}
		});
	},
	minLength: 2,
	open: function() {
		$( this ).removeClass("ui-cornet-all").addClass( "ui-corner-top" );
	},
	close: function() {
		$( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
	}
};

var actionopr = {
		source: function( request, response ) {
			$.ajax({
				url: "/distrule/find_by_actionopr",
				dataType: "json",
				data: {
					featuteClass: "action",
					style: "full",
					maxRows: 12,
					name_startsWith: request.term
				},
				success: function( data ) {
					response( $.map(data.names, function( item ) {
						return {
							label: item.name,
							value: item.id
						}
					}));
				},
				error: function (xhr, ajaxOptions, thrownError) {
					alert( xhr.status );
					alert( thrownError );
				}
			});
		},
		minLength: 2,
		open: function() {
			$( this ).removeClass("ui-cornet-all").addClass( "ui-corner-top" );
		},
		close: function() {
			$( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
		}
	};

var subjectopr = {
		source: function( request, response ) {
			$.ajax({
				url: "/endpoint/find_by_subject",
				dataType: "json",
				data: {
					featuteClass: "action",
					style: "full",
					maxRows: 12,
					name_startsWith: request.term
				},
				success: function( data ) {
					response( $.map(data.names, function( item ) {
						return {
							label: item.name,
							value: item.id
						}
					}));
				},
				error: function (xhr, ajaxOptions, thrownError) {
					alert( xhr.status );
					alert( thrownError );
				},
				
			});
		},
		select: function( event, ui) {
			var subject = ui.item.label;
			var mimetype = getMimetype(subject);
			
			$(this)
				.parents('tr')
				.find('#mime')
				.val( mimetype );
		},
		minLength: 2,
		open: function() {
			$( this ).removeClass("ui-cornet-all").addClass( "ui-corner-top" );
		},
		close: function() {
			$( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
		}
	};

$(document).ready(function(){
	
	/*
	 * 
	 * Endpoint management
	 * 
	 */
	jQuery("#epTable").jqGrid({ 
		url:'/endpoint/api?oper=list', 
		datatype: "json",
		colNames:['Name', 'Method', 'Active','Dest in','Dest out'],
		colModel: [
		           	{
		           		name:'ep_name',
		           		index:'ep_name', 
		           		width:128, 
		           		editable:false, 
		           		searchoptions: {sopt:['eq','ne','cn']}, 
		           		required:true, 
		           	}, 
		           	{
		           		name:'ep_method',
		           		index:'ep_method',
		           		width:96, 
		           		editable:false,
		           		
		           	},
		           	{
		           		name:'ep_active',
		           		index:'ep_active', 
		           		width:64, 
		           		editable:false, 
		           		required:false, 
		           		align:"center"
		           		
		           	},
		           	{
		           		name:'ep_dest_in',
		           		index:'ep_dest_in',
		           		width:160,
		           		editable:false,
		           	},
		           	{
		           		name:'ep_dest_out',
		           		index:'ep_dest_out', 
		           		width:160, 
		           		editable:false,
		           		required:true,
		           	}
		          ],
		rowNum:10, 
		rowList:[10,20,30],
		height: 200, 
		pager: '#epPager', 
		sortname: 'ep_name', 
		viewrecords: true,
		hidegrid: false,
		sortorder: "asc", 
		editurl: "/endpoint/api", 
		caption: "Endpoint management",
		ondblClickRow: function(id) {
			$.colorbox({
				iframe:true,
				width:740,
				height:650,
				initialWidth:640,
				initialHeight:650,
				href:'/endpoint/edit?id=' + id,
				onClosed:function(){ 
					$("#epTable").trigger("reloadGrid");
				} 
			});
		}
	});
	
	jQuery("#epTable").jqGrid('navGrid',"#epPager",
			{	view:true, 
				edit:false, 
				add:true, 
				save:false, 
				del:false, 
				addfunc: function() { 
					$.colorbox({iframe:true,width:740,height:650,initialWidth:640,initialHeight:650,href:'/endpoint/add' });
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
							$("#epTable").trigger("reloadGrid");
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
	
	jQuery("#epTable").jqGrid('inlineNav',"#epPager", {edit: false, add:false, cancel:false, save:false});
	
	/*
	 * 
	 * Distribution Rules 
	 * 
	 */
	
	jQuery("#DistRuleTable").jqGrid({ 
		url:'/distrule/api?oper=list', 
		datatype: "json",
		colNames:['Name', 'Active','Priority', 'Rules', 'Actions' ],
		colModel: [
		           	{
		           		name:'rule_name',
		           		index:'rule_name', 
		           		width:128, 
		           		editable:false, 
		           		searchoptions: {sopt:['eq','ne','cn']}, 
		           		required:true, 
		           	}, 
		           	{
		           		name:'rule_active',
		           		index:'rule_active',
		           		width:64, 
		           		editable:false,
		           		align:"center",
		           		
		           	},
		           	{
		           		name:'rule_priority',
		           		index:'rule_priority', 
		           		width:64, 
		           		editable:false, 
		           		required:false, 
		           	},
		           	{
		           		name:'rule_nrules',
		           		index:'rule_nrules',
		           		width:64,
		           		editable:false,
		           		align:"center",
		           	},
		           	{
		           		name:'rule_nactions',
		           		index:'rule_nactions', 
		           		width:64, 
		           		editable:false,
		           		align:"center",
		           	},
		          ],
		rowNum:10, 
		rowList:[10,20,30],
		height: 200,
		pager: '#DistRulePager', 
		sortname: 'ep_name', 
		viewrecords: true,
		hidegrid: false,
		sortorder: "asc", 
		editurl: "/disrule/api", 
		caption: "Distribution rule management",
		ondblClickRow: function(id) {
			$.colorbox({
				iframe:true,
				width:740,
				height:650,
				initialWidth:640,
				initialHeight:650,
				href:'/distrule/edit?id=' + id,
				onClosed:function(){ 
					$("#DistRuleTable").trigger("reloadGrid");
				} 
			});
		}
	});
	
	jQuery("#DistRuleTable").jqGrid('navGrid',"#DistRulePager",
			{	view:true, 
				edit:false, 
				add:true, 
				save:false, 
				del:false, 
				addfunc: function() { 
					$.colorbox({iframe:true,width:740,height:650,initialWidth:640,initialHeight:650,href:'/distrule/add' });
				},
				editfunc: function() {
					$.colorbox({
						iframe:true,
						width:740,
						height:650,
						initialWidth:640,
						initialHeight:650,
						href:'/disrule/edit',
						onClosed:function(){ 
							$("#DistRuleTable").trigger("reloadGrid");
						} 
					});
				}
			},
			{height:350,reloadAfterSubmit:true, jqModal:false, closeOnEscape:true},
			{height:350,reloadAfterSubmit:true,jqModal:false, closeOnEscape:true, closeAfterAdd: true},
			{reloadAfterSubmit:false,jqModal:false, closeOnEscape:true},
			{closeOnEscape:true},
			{height:350,jqModal:false,closeOnEscape:true}
	); 
	
	jQuery("#DistRuleTable").jqGrid('inlineNav',"#DistRulePager", {edit: false, add:false, cancel:false, save:false});
	
	var distvalid = $("#distForm").validate(
			{
				debug: true,
				rules: {
					rule_name: {
						required: true,
						minlength: 4
					},
					rule_priority: {
						required: true,
						range: [0, 99]
					}
				},
				messages: {
					rule_name: "Enter a valid name (min. 4 char)"
				},
				submitHandler: function(form) {
					var data = $('#distForm').serialize();

					$.post('/distrule/save',
							data,
							function(data) {
								$('#response').html(data).show().delay(5000).hide('slow');
								$('#saveRule').prop("disabled", true).delay(5000).prop("disabled", false);
							},
							'html'
						);
							
				},
				invalidHandler: function(form) {
					
					$('#response').text(distvalid.numberOfInvalids() + " field(s) are invalid");
				},
				errorPlacement: function(error, element) {
					error.insertAfter('#deleteVendor');
				}
			}
	);

	/*
	
	JQuery function to add row the endpoint edit screen in template ep_edit.tt
	
	*/
	
	$("#addMessage").click(function(){
		var row1 = '<tr>';
		row1 = row1 + '<td><div class="ui-widget"><input type="text" name="subject" class="cmdbText" /></div></td>';
		row1 = row1 + '<td><input type="button" class="cmdbButton" value="yes" name="msg_active" onclick="toggleDistMsg(this)" /><input type="hidden" name="msgactive" value="yes" /></td>';
		row1 = row1 + '<td><input type="text" name="mimetype" id="mime" class="cmdbText" /></td>';
		row1 = row1 + '<td><img name="edit" src="/static/images/document_edit.png"  /></td>'
		row1 = row1 + '</tr>';
		var row2 = '<tr style="display: none" >';
		row2 = row2 + '<td colspan="4"><textarea cols="64" rows="5" name="ep_message"> </textarea></td>';
		row2 = row2 + '</tr>';
		
		$("#subjectTable tr:last").after(
				row1 + row2
		);
		$("img[name='edit']").unbind("click"); 
		$("img[name='edit']").click(function() {
			
			myrow = $(this).parents('tr').next();
			showHide(myrow);
		});
		$('input[name="subject"]').autocomplete( subjectopr );
		
	});
	
	$("img[name='edit']").click(function() {
		myrow = $(this).parents('tr').next();
		showHide(myrow);
	});
	
	
});

$(function() {
	
	$('input[name="rule_operator"]').autocomplete( ruleopr );
	$('input[name="action_operator"]').autocomplete( actionopr );
	$('input[name="subject"]').autocomplete( subjectopr );
});

function epCrypt(cb)
{
	if ( cb.checked == true ) {
		$("#password").prop('type', 'text');
	} else {
		$("#password").prop('type', 'password');
	}
}


function showHide(object) {
	if ( $( object ).is(":visible") ) {
		$( object ).hide();
	} else {
		$ ( object ).show();
	}
}

function dataBox(cb, linkObject) {
	if ( cb.checked == true ) {
		$( linkObject ).show();
	} else {
		$( linkObject ).hide();
	}
}

function addrow(table, raType)
{
	var newrow  = '<tr>';
	newrow = newrow + '<td><div class="ui-widget"><input type="text" name="' + raType + '_operator" value="" /></div></td>';
	newrow = newrow + '<td>:</td>';
	newrow = newrow + '<td><div class="ui-widget"><input type="text" name="' + raType + '_value" value="" /></div></td>';
	newrow = newrow + '<td><img src="/static/images/delete.png" onclick="delrow(this);" />';
	newrow = newrow + '</td></tr>';
	$( table + ' tr:last').after( newrow );
	$('input[name="rule_operator"]').autocomplete( ruleopr );
	$('input[name="action_operator"]').autocomplete( actionopr );
	
}

function delrow(tablerow) 
{
	$(tablerow).parents('tr').remove();
}

function getMimetype(value)
{
	mime = '';
	$.ajax({
		type: "POST",
		async : false,
		url: "/endpoint/get_mimetype",
		data: {
			subject: value
		},
		dataType: "text",
		success: function( data ) {
			mime = data;
		}
	});
	
	return mime;
}

function toggleDistMsg(button)
{
	if ( button.value == 'yes' )
	{
		button.value = 'no';
		$(button).next(":input").val('no')
	} else {
		button.value = 'yes';
		$(button).next(":input").val('yes');
	}
}
