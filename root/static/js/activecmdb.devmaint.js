$(function() {

	$( "#setDeviceMaint" ).click(function() {
		var data = 'id=' + $("#device_id").val() + '&maint=' + $("#devmaint").val();
		$.post('/device/setmaint',
			data,
			function(data) {
				$('#response').html(data).show();
			},
			'html'
		);
		
	});

});