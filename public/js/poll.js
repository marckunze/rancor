$(document).ready(function(){
	// sort option list 

	$(function() {
        $( "#sortable_options").sortable({
            opacity: .8,
            cursor: "move", 
            placeholder: "ui-sortable-placeholder"
        });
    });
 });