

$(document).ready(function(){
	
	$('#vendorForm').validate({
		rules: {
			supportmail: {
				required: true,
				email: true
			},
			name: {
				required: true,
				minlength: 4
			},
			supportweb: {
				minlength: 4
			}
		},
		messages: {
			supportmail: "Please enter a valid e-mail address",
			name: {
				required: "Please provide a name for the vendor",
				minlength: "Vendorname should contain at least 4 characters"
			}
		},
		submitHandler: function(form) {
			var data = $('#vendorForm').serialize();

			$.post('/vendor/save',
					data,
					function(data) {
						$('#response').html(data).show().delay(5000).hide('slow');
						$('#saveVendor').prop("disabled", true);
					},
					'html'
				);
					
		},
			
		invalidHandler: function(form) {
			$('#response').text('Correct errors first.');
		},
		errorPlacement: function(error, element) {
			error.insertAfter('#deleteVendor');
		}

	});
});


function viewVendor(vendor_id)
{
	alert('Hallo');
	$.colorbox(
			{
				iframe:true,
				width:680,
				height:450,
				initialWidth:640,
				initialHeight:400,
				href:'/vendor/view?vendor=' + vendor_id, 
					onClosed:function(){ location.reload(true); }
			}
	);
	
}