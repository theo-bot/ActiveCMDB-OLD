

$(function() {
	
	$( '#saveRole' ).click(function() {
		var data = $( '#roleForm' ).serialize();
		
		$.post('/roles/save',
				data,
				function(data) {
					$('#response').html(data).show();
				},
				'html'
		);
		
	});

	$( '#deleteRole' ).click(function() {
		var data = $( '#roleForm' ).serialize();
	
		$.post('/roles/delete',
				data,
				function(data) {
					$('#response').html(data).show();
				},
				'html'
		);
	});
	
});