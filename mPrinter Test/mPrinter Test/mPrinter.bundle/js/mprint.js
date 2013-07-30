(function( $ ){
	$.fn.mprintFillText = function() {
		$(this).each(function() {
			maxFontSize = 512;
			var text = $(this).text();
			var span = $("<span />").text(text);
			$(this).text("").append(span);
			var maxWidth = $(this).width();
			var fontSize = parseInt($(this).css("font-size"), 10);
			var multiplier = (maxWidth / $(span).width());
			var newSize = Math.floor(fontSize * (multiplier - 0.1));
			$(span).css("font-size", (maxFontSize > 0 && newSize > maxFontSize ? maxFontSize + "px" : newSize + "px"));
		});
	}
})( jQuery );

$(".text-fill").mprintFillText();

$(".text-shadow").each(function() {
	blackOffset = ($(this).attr("data-shadow-offset") != null ? Math.ceil($(this).attr("data-shadow-offset")) : 7);
	whiteOffset = (blackOffset > 2) ? blackOffset - (blackOffset > 4 ? 2 : 1) : 0;
	blackOffset = blackOffset * -1; whiteOffset = whiteOffset * -1;
	$(this).css({ "background": "transparent url('img/pattern/diag_2.png')", "text-shadow": blackOffset + "px " + blackOffset + "px black, " + whiteOffset + "px " + whiteOffset + "px white", "-webkit-text-fill-color": "transparent", "-webkit-background-clip": "text" });
});
