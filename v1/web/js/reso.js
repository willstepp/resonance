var currentApprovedSheets = [1,2,3,4,5,6,8,10]

window.onload = function() {
	creditList = new Array(
		'cold moon by <a href=" http://sixwings.deviantart.com/">jed elkins</a>', 
		'fairie ring by <a href="http://Moonchilde-Stock.deviantart.com/">moonchilde stock</a>', 
		'stock landscape 1 by <a href="http://AzurylipfesStock.deviantart.com/">azurylipfesstock</a>',
		'moon stock xiii by <a href="http://grace-stock.deviantart.com/">grace stock</a>', 
		'night glow stock by <a href="http://SimplyBackgrounds.deviantart.com/">simplybackgrounds</a>', 
		'infinity by <a href="http://ruby-stocknstuff.deviantart.com/">ruby stocknstuff</a>', 
		'smith river magic by <a href="http://riktorsashen.deviantart.com/">riktorsashen</a>', 
		'dark water stock by <a href="http://LeandrasStock.deviantart.com/">leandrasstock</a>', 
		'sky by <a href="http://DianaFernandes-stock.deviantart.com/">dianafernandes_stock</a>', 
		'empty words i by <a href="http://lady-symphonia-stock.deviantart.com/">lady symphonia stock</a>'
	);
	randombit = parseInt( Math.random()*currentApprovedSheets.length );
	sheetidx = currentApprovedSheets[ randombit ]
	loadCSS( 'reso_' + sheetidx + '.css' );
	document.getElementById('artref').innerHTML = creditList[ sheetidx - 1];
	
	//untangle email
	document.getElementById( 'ma' ).href = "mailto:twrigley";
	document.getElementById( 'ma' ).href += "@" + "uci.edu";
}


function loadCSS( file ) {
	var sheetRef=document.createElement( 'link' );
	sheetRef.setAttribute( 'rel', 'stylesheet' );
	sheetRef.setAttribute( 'type', 'text/css' );
	sheetRef.setAttribute( 'href', 'css/' + file );
	document.getElementsByTagName( 'head' )[0].appendChild(sheetRef);
}

function download( kind ) {
	if ( kind=='w' ) window.location = 'downloads/resonance.msi';
	if ( kind=='m' ) window.location = 'downloads/resonance.dmg';
}
