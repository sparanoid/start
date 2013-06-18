$("a[rel=external]").click(function() {
  window.open( $(this).attr("href") );
  return false;
});

// Animation
$(window).load(function() {
  $("body").addClass("in");
});