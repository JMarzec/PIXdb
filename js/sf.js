/* Javascript methods for the Tissue Finder 2.0 *
 * Coder: Stefano Pirro'
 * Institution: Barts Cancer Institute
 * Details: all the javascript behaviours of the SF2.0 portal, are included here. */

$(document).ready(function() {
	$('#fullpage').fullpage({
		anchors: ['home', 'select'],
		menu: '#menu',
		afterLoad: function(anchorLink, index){
			// in this case we are in the home page and we don't want to visualise the menu
			if (index == 1) { 
				$('#menu').hide();
				$('div#fullpage').css('z-index', 1);
			// in all the other situations, thats okay
			} else {
				$('#menu').show();
				$('#menu').css('z-index', 9999);
			}
		}
	});
});

