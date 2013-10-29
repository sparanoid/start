$("a[rel=external]").click ->
  window.open $(this).attr "href"
  false

# Animation
$(window).load ->
  $("body").addClass "in"
