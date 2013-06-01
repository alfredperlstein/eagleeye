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
    $('#test').append(
		      '<label><input type=\'checkbox\' name=\'' +
		      cDiv +
		      '\' onclick=\'handleCheckbox(this);\'>' +
		      //'\' onclick=\'alert(this.name);\'>' +
		      cDiv + '</label> | ');
}

<!--	    <script type="text/javascript">
$("hideme").hide();
-->

