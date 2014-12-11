/*! SOURCE  http://w3lessons.info/2013/06/04/skill-bar-with-jquery-css3/ */
jQuery(document).ready(function(){
	jQuery('.skillbar').each(function(){
		jQuery(this).find('.skillbar-bar').animate({
			width:jQuery(this).attr('data-percent')
		},1000);
	});

	$('[data-toggle="tooltip"]').tooltip({
    'placement': 'top'
	});
});