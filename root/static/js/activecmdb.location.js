/*
 * 	Script:	activecmdb.location.js
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

var siteFields = new Array('location_id','type','parent_id','lattitude','longitude','adres1','adres2','place','zipcode','primary_contact','primary_phone','backup_contact','backup_phone','details','parentString');
var xmlhttp;

function getparents(type, id)
{
	$.getJSON("/location/get_parents?type=" + type + '&location_id=' + id, function(result) {
		var parents = result.parents;
		var siteParent = result.parent_id;
		var options = '';
		var select = '';
		for (var i = 0; i < parents.length; i++)
		{
			if ( parents[i].optionValue == siteParent ) {
				select = ' selected ';
			} else {
				select = '';
			}
			options += '<option value="' + parents[i].optionValue + '"' + select +'>' + parents[i].optionDisplay + '</option>';
		}
		$('#parent_id').html(options);
	});
}

function locResetDetails()
{
	for (var Index in Fields)
	{
		try {
			document.getElementById(siteFields[Index]).value = '';
		} catch(e) {
			
		}
	}
	document.getElementById("name").value = '';
	document.getElementById('type').selectedIndex = 0;
	locTypeSelect();
}

function locDetails()
{
	window.status = 'CMDB: Fetching location details';
	var name = document.getElementById('name').value;
	xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange=function()
	{
		if ( xmlhttp.readyState==4 && xmlhttp.status==200 )
		{
			var xmlDoc = xmlhttp.responseXML.documentElement;
			for (var Index in siteFields)
			{
				if ( siteFields[Index] != 'parentString' )
				{
					var newvalue = xmlDoc.getElementsByTagName(siteFields[Index])[0].childNodes[0].nodeValue;
					var formObj  = document.getElementById(siteFields[Index]);
					if ( siteFields[Index] != 'parent_id' )
					{
						formObj.value = newvalue;
					}
				}
			}

			var newvalue = xmlDoc.getElementsByTagName('parent_id')[0].childNodes[0].nodeValue;
			var formObj  = document.getElementById('parent_id');
			var psize = formObj.length;
			for (var i=0; i < psize; i++)
			{
				if ( formObj.options[i].value == newvalue ) {
					formObj.selectedIndex = i;
				}
			}
			locTypeSelect();
			window.status = 'CMDB: Ready';
		}
	}
	xmlhttp.open('get', '/ajax/location.xml.php?name=' + name, true);
	xmlhttp.send();
}

$(document).ready(function(){
	
	$('#siteForm').validate({
		rules: {
			name: {
				required: true,
				minlength: 3
			},
		},
		messages: {
			name: "Please enter a valid name"
		},
		submitHandler: function(form) {
			var data = $("#siteForm").serialize();
			$.post('/location/save',
					data,
					function(data) {
						$('#response').html(data).show().delay(5000).hide('slow');
						$('#saveSite').prop("disabled", true);
					},
					'html'
					);
		},
		invalidHandler: function(form) {
			$('#response').text('Correct errors first.');
		},
		errorPlacement: function(error, element) {
			error.insertAfter('#resetButton');
		}
	});
	
	$("#siteType").change(function(){
		alert("change");
		var typeValue = $("#siteType").val();
		var location_id = $("#location_id").val();
		
		
	});
});

$(function() {

	$("#name").autocomplete({
		source: function( request, response ) {
			$.ajax({
				url: "/location/find_by_name",
				type: "post",
				dataType: "json",
				data: {
					featuteClass: "P",
					style: "full",
					maxRows: 12,
					name_startsWith: request.term
				},
				success: function( data ) {
					response( $.map(data.names, function( item ) {
						return {
							label: item.label,
							value: item.label
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
	});
	
	$("#fetchSite").click(function(){
		var siteName = $("#name").val();
		var ltype = 0;
		var id = 0;
		$.ajax({
			url: "/location/fetch_by_name",
			type: "post",
			dataType: "json",
			data: {
				name: siteName
			},
			success: function( data ){
				var l = data.site;
				$('#zipcode').val(l.zipcode);
				$('#primary_phone').val(l.primary_phone);
				$('#longitude').val(l.longitude);
				$('#lattitude').val(l.lattitude);
				$('#name').val(l.name);
				$('#adres2').val(l.adres2);
				$('#backup_phone').val(l.backup_phone);
				$('#location_id').val(l.location_id);
				$('#details').val(l.details);
				$('#adres1').val(l.adres1);
				$('#classification').val(l.classification);
				$('#backup_contact').val(l.backup_contact);
				$('#primary_contact').val(l.primary_contact);
				$('#place').val(l.place);
				$('#type').val(l.type);
				
				getparents(l.type, l.location_id);
			}
		});
		
		
	});
	
	$( "#locDevDetails").click(function(){
		var site_id = $("#location_id").val();
		var ltype = 0;
		var id = 0;
		$.ajax({
			url: "/location/fetch_by_id",
			type: "post",
			dataType: "json",
			data: {
				id: site_id
			},
			success: function( data ){
				var l = data;
				var oldtype = $("#siteType").val();
				$('#zipcode').html(l.zipcode);
				$('#primary_phone').html(l.primary_phone);
				$('#longitude').html(l.longitude);
				$('#lattitude').html(l.lattitude);
				$('#name').html(l.name);
				$('#adres2').html(l.adres2);
				$('#backup_phone').html(l.backup_phone);
				$('#location_id').val(l.location_id);
				$('#details').html(l.details);
				$('#adres1').html(l.adres1);
				$('#classification').html(l.classification);
				$('#backup_contact').html(l.backup_contact);
				$('#primary_contact').html(l.primary_contact);
				$('#place').html(l.place);
				$('#ltype').html(l.ltype);
				$('#siteType').val(l.ltype);
				$("#parentString").html(l.parentStr);
				if ( l.ltype != oldtype ) {
					updateSiteForm(l.ltype);
				}
				getparents(l.type, l.location_id);
			},
			error: function(jqXHR, textStatus, errorThrown) {
				alert(textStatus);
			}
		});
	});
	
	$("#type").change(function(){
		
		var typeValue = $("#type").val();
		var location_id = $("#location_id").val();
		
		updateSiteForm(typeValue);
		
		getparents(typeValue, typeValue );
		
	});
	
	

	$(":input").change(function(){
		$('#saveSite').prop("disabled", false);
	});
	
	
	$("#response").change(function() {
		$("#response").delay(5000).hide();
	});
	
	$("#setDeviceSite").click(function() {
		var site_id = $("#location_id").val();
		var device_id = $("#device_id").val();
		alert("Updating " + device_id + " with site " + site_id);
		$.ajax({
			url: "/device/set_location",
			type: "post",
			dataType: "json",
			data: {
				site_id: site_id,
				device_id: device_id
			},
			success: function( data ){
				$('#response').html(data).show().delay(5000).hide('slow');
			}
		});
	});
});

function updateSiteForm(siteType)
{
	if ( siteType == 0 )
	{
		$("#parent").hide();
	} else {
		$("#parent").show();
	}
	if ( siteType == 3 )
	{
		$("#building").show();
	} else {
		$("#building").hide();
	}
	if (siteType < 3 )
	{
		$("#building-room").hide();
	} else {
		$("#building-room").show();
	}
}