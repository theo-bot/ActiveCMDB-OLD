

$(function() {
	
	$( '#updPasswd' ).click(function() {
		var data = $( '#passwdForm' ).serialize();
		
		$.post('/users/passwd',
				data,
				function(data) {
					$('#response').html(data).show().delay(5000).hide('slow');
					$('input[name*="pass"]').val('');
				},
				'html'
		);
	});
	
	$.configureBoxes();
	
	$( '#saveUser' ).click(function() {
		$("#box2View option").attr("selected","selected"); 
		var data = $( '#userForm' ).serialize();
		
		$.post('/users/save',
			data,
			function(data) {
				$('#response').html(data).show().delay(5000).hide('slow');
				$('#saveUser').prop("disabled", true);
				/* $('#saveUser').removeClass('cmdbButtonOff').addClass('cmdbButton'); */
			},
			'html'
		);
	});
	
	$( "#userForm input" ).change(function() {
		$('#saveUser').prop("disabled", false);
		/* $('#saveUser').removeClass('cmdbButtonOff').addClass('cmdbButton'); */
	});
	
	$( "#userForm button" ).click(function() {
		$('#saveUser').prop("disabled", false);
		/* $('#saveUser').removeClass('cmdbButtonOff').addClass('cmdbButton'); */
	});
	
	
	$( '#deleteUser' ).click(function() {
		var data = $('#userForm').serialize();
		
		$.post('/users/delete',
				data,
				function(data) {
					$('#response').html(data).show().delay(5000).hide('slow');
					$('#userForm input').prop("disabled", true);
					$('#userForm button').prop("disabled", true);
					$('#saveUser').prop("disabled", true);
					$('#deleteUser').prop("disabled", true);
				}
		);
	});
	
});