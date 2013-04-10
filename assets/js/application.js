$('a[rel=external]').click(function() {
  window.open( $(this).attr('href') );
  return false;
});

// Animation
$(window).load(function() {
  $("body").addClass("in");
  $("#spinner").removeClass("in");
});

// Enable :active for iOS, easy method
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