function xInterfaceDetails(device_id,ifindex)
{
	$.ajax({
		url: '/device/fetch_interface',
		data: 'device_id=' + device_id + '&ifindex=' + ifindex,
		datatype: 'json',
		success: function(data) {
			$( "#ifDescr" ).text(data.ifdescr);
			$( "#ifName" ).text(data.ifname);
			$( "#ifAlias" ).text(data.ifalias);
			$( "#ifIndex" ).text(data.ifindex);
			$( "#ifSpeed").text(data.ifspeed);
			$( "#ifType" ).text(data.iftype);
			$( "#ifPhysAddress").text(data.ifphysaddress);
			document.getElementById('ifDetail').style.visibility = 'visible';
		}
	});
}