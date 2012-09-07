// animation
$(window).load(function() {
  // hide the pins
  $("body").addClass("in");
  $("#spinner").removeClass("in");
});

// enable :active, easy method
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

// https://gist.github.com/1190492
function hideAddressBar() {
  if(!window.location.hash) {
    if(document.height < window.outerHeight) {
      document.body.style.height = (window.outerHeight + 50) + 'px';
    }
    setTimeout( function(){ window.scrollTo(0, 1); }, 50 );
  }
}
window.addEventListener("load", function(){ if(!window.pageYOffset){ hideAddressBar(); } } );
window.addEventListener("orientationchange", hideAddressBar );