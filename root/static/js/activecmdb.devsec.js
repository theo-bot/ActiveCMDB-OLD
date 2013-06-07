$(function() {
	
	$("#updateSecurity").click(function(){
		var data = $("#deviceSec").serialize();
		$.post(
			'/device/update_security',
			data,
			function(data) {
				$('#response').html(data).show().delay(5000).hide('slow');
				$('#saveSite').prop("disabled", true);
			},
			'html'
		);
	});
	
});

function snmpSelect()
{
	var version = $( 'input[name="snmpv"]:checked','#deviceSec' ).val();
	/* alert("Version :" + version ); */
	if ( version < 3 ) {
		$( "#snmpv1" ).show();
		$( "#snmpv3" ).hide();
	} else {
		$( "#snmpv1" ).hide();
		$( "#snmpv3" ).show();
	}
}