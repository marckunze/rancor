$(document).ready(function(){
  // sort option list 

  $(function() {
        $( "#sortable_options").sortable({
            opacity: .8,
            cursor: "move", 
            placeholder: "ui-sortable-placeholder"
        });
    });

    $('body').on('click', '.btn', function() {
      // Get order of sortable list as array
        var id_order = $("#sortable_options").sortable('toArray');
        // Test the array
        //alert(id_order);
                   
        $.ajax({
        type: "POST",
        url: "/new_poll",
        data: { vote: id_order},
        success: function(data){
            window.location.href = '/confirmation'
        }
      });
  	});
 });