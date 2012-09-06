$(window).load(function() {
  // hide the pins
  $("body").addClass("in");
  $("#spinner").removeClass("in");
});

// enable :active
document.addEventListener("touchstart", function(){}, true);

// .js spinner
Spinner({
  // radius: 10,
  // length: 40
  trail: 50,
  color: '#aaa',
  // shadow: true,
  hwaccel: false
}).spin(document.getElementById('spinner'));