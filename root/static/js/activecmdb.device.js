/*
 * 
 * JQuery functions
 * 
 */

$(document).ready(function(){
	
	$( "#searchWin" ).dialog({
		autoOpen: false,
		height: 300,
		width: 600,
		modal: true,
		buttons: {
			Close: function() {
				$( this ).dialog( "close" );
			}
		}
	});
});

$(function() {

	$("#hostname").autocomplete({
		source: function( request, response ) {
			$.ajax({
				url: "/device/find_by_name",
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
							label: item.name,
							value: item.id
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
	
	$( "#fetcher" )
    .button()
    .click(function() {
        alert( "Running the last action" );
    })
    .next()
        .button({
            text: false,
            icons: {
                primary: "ui-icon-triangle-1-s"
            }
        })
        .click(function() {
            var menu = $( this ).parent().next().show().position({
                my: "left top",
                at: "left bottom",
                of: this
            });
            $( document ).one( "click", function() {
                menu.hide();
            });
            return false;
        })
        .parent()
            .buttonset()
            .next()
                .hide()
                .menu();
	
	
	
	$( "#searchDev" ).click(function() {
		$( "#searchWin").dialog( "open" );
		return false;
	});
	
	$( "#tabs" ).tabs({
		ajaxOptions: {
			cache: false,
			data: 'id=' + $("#device_id").val() 
		},
		beforeLoad: function( event, ui ) {
            ui.jqXHR.error(function() {
                ui.panel.html(
                    "Couldn't load this tab. We'll try to fix this as soon as possible. " +
                    "If this wouldn't be a demo." );
            });
        }
	});
	
	
});



