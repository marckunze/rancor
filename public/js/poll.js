$(document).ready(function(){
  // sort option list 
  $(function() {
        $( "#sortable_options").sortable({
            opacity: .8,
            cursor: "move", 
            placeholder: "ui-sortable-placeholder"
        });
    });

   $('#results').on('click', function() {
      
      window.location.href = window.location.pathname + '/results'
        
    });

    $('#vote').on('click', function() {
      // Get order of sortable list as array
        var id_order = $("#sortable_options").sortable('toArray');
        // Test the array
        //alert(id_order);
                   
        $.ajax({
        type: "POST",
        data: { vote: id_order},
        success: function(data){
            window.location.href = window.location.pathname + '/results'
        }
      });
    });
 });