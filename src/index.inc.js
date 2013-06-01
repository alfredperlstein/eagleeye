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
    if (i % 2 == 0) {
	dest = ".navbarleft";
    } else {
	dest = ".navbarright";
    }
    $(dest).append(
		      '<label><input type=\'checkbox\' name=\'' +
		      cDiv +
		      '\' onclick=\'handleCheckbox(this);\'>' +
		      //'\' onclick=\'alert(this.name);\'>' +
		      cDiv + '</label><br>');
}

<!--	    <script type="text/javascript">
$("hideme").hide();
-->

