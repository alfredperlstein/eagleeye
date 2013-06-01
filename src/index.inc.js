function handleCheckbox(cb) {
//display("Clicked, new value = " + cb.checked + " name = " + cb.name);
  divName = "#" + cb.name;
  if (cb.checked) {
      $(divName).hide();
  } else {
      $(divName).show();
  }
  //alert("Clicked, new value = " + cb.checked + " name = " + cb.name);
}

for (var i = 0; i < allDivs.length; i++) {
    var cDiv = allDivs[i];
    if (i > allDivs.length / 2 == 0) {
	dest = ".navbarleft";
    } else {
	dest = ".navbarright";
    }
    $(dest).append(
		      '<label><input class=\'filtercheckbox\' type=\'checkbox\' name=\'' +
		      cDiv +
		      '\' onclick=\'handleCheckbox(this);\'>' +
		      //'\' onclick=\'alert(this.name);\'>' +
		      '</label><a href=\'#' + cDiv + '\'>' + cDiv + '</a><br>');
}

$('.smallgraph').mouseover(function() {
    var newImage = this.src
    $('.largeimage').hide()
    // $('.largeimage').replaceWith('<div class="largeimage"><img src="' + this.src + '" height=400 width=800></div>');
    $('.largeimage').replaceWith('<div class="largeimage"><img src="' + this.src + '" width=625></div>');
    $('.largeimage').show()
});

function toggleAllNav() {
    $('.filtercheckbox').each(function(i) {
	$(this).prop('checked', !$(this).prop('checked'));
	handleCheckbox($(this).get(0));
    });
}

<!--	    <script type="text/javascript">
$("hideme").hide();
-->

