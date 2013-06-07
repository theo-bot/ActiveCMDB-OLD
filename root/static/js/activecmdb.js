
/*
 *  Pure Javascript functions
 */

function edit_role(role_id)
{
	
	jQuery().colorbox({width:450,height:220,href:'/roles/edit?role_id=' + role_id,onClosed:function(){ location.reload(true); } });
}

function edit_user(user_id)
{
	jQuery().colorbox({width:650,height:450,href:'/users/edit?user_id=' + user_id,onClosed:function(){ location.reload(true); } });
}

function setpass(user_id)
{
	jQuery().colorbox({
		width:450,
		height:250,
		href:'/users/edit?user_id=' + user_id,
		onClosed:function(){ location.reload(true); } 
	});
}


