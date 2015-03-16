$(document).ready(function() {
  $("div#menu").hide();
  $("#header").click(function(){
    $("div#menu").fadeToggle('slow', 'linear');
  });
});
