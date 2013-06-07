

function showConfigObject(device_id, config_id)
{
	$.colorbox({iframe:true,width:740,height:650,initialWidth:640,initialHeight:650,href:'/devconfig/view?device_id=' + device_id + '&config_id=' + config_id});
}