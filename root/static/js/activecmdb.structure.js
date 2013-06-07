function xEntityDetails(device_id,index)
{
	$.ajax({
		url: '/device/fetch_entity',
		data: 'device_id=' + device_id + '&index=' + index,
		datatype: 'json',
		success: function(data) {
			$( "#entityName" ).text(data.entphysicalname);
			$( "#entityDesc" ).text(data.entphysicaldescr);
			$( "#entityClass" ).text(data.entphysicalclass);
			$( "#entityHwRev" ).text(data.entphysicalhardwarerev);
			$( "#entityFwRev").text(data.entphysicalfirmwarerev);
			$( "#entitySwRev" ).text(data.entphysicalsoftwarerev);
			$( "#entitySerial").text(data.entphysicalserialnum);
			$( "#logicalUnit" ).text(data.logicalUnit);
			document.getElementById('entityDetail').style.visibility = 'visible';
		}
	});
}