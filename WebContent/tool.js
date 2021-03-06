function valid_zipCode(ZipCode) {
	var s = "" + ZipCode;
	length = s.length;
	if (length != 5) {
		return false;
	}
	for (var i = 0; i < length; i++) {
		var ch = s.charAt(i);
		if ((ch < '0') || (ch >'9')) {
			return false;
		}
	}
	return true;
}

function valid_mileRadius(MileRadius) {
	var s = "" + MileRadius;
	length = s.length;
	for (var i = 0; i < length; i++) {
		var ch = s.charAt(i);
		if ((ch < '0') || (ch >'9')) {
			return false;
		}
	}
	return true;
}

function valid_sharePrice(Price) {
	var s = "" + Price;
	length = s.length;
	if (length < 2) {
		return false;
	}
	else if (s.charAt(0) != '$') {
		return false;
	}
	var dot_count = 0;
	for (var i = 1; i < length; i++) {
		var ch = s.charAt(i);
		if (ch == '.') {
			dot_count++;
			if (dot_count > 1) return false;
		}
		else if ((ch < '0') || (ch >'9')) {
			return false;
		}
	}
	return true;
}

function marker_htmlMaker(store) {
	var htmlString = "";
	htmlString = htmlString + "<div align='left' class='info'>";
	htmlString = htmlString + "<img src='" + store.showImage + "' width='64' height='64' /><br />";
	htmlString = htmlString + "<a class='normal_font'>Store Name</a><br />";
	htmlString = htmlString + "<a class='result_title_font'>" + unescape(store.name) + "</a><br />";
	htmlString = htmlString + "<a class='normal_font' href='#' onClick=\"window.open(\'" + store.URL + "\')\">Sale Title & Link</a><br />";
	htmlString = htmlString + "<a class='result_title_font'>" + unescape(store.dealTitle) + "</a><br />";
	htmlString = htmlString + "<a class='normal_font'>Expire Date</a><br />";
	htmlString = htmlString + "<a class='result_title_font'>" + unescape(store.expirationDate) + "</a><br />";
	htmlString = htmlString + "<a class='normal_font'>Address</a><br />";
	htmlString = htmlString + "<a class='result_title_font'>" + unescape(store.address) + "</a><br />";
	htmlString = htmlString + "<a class='normal_font'>Phone</a><br />";
	htmlString = htmlString + "<a class='result_title_font'>" + unescape(store.phone) + "</a><br />";
	htmlString = htmlString + "</div>";
	return htmlString;
}

function sharemarker_htmlMaker(share) {
	var htmlString = "";
	htmlString = htmlString + "<div align='left' class='info'>";
	htmlString = htmlString + "<img src='" + share.picture + "' height='64' /><br />";
	htmlString = htmlString + "<a class='normal_font'>Item</a><br />";
	htmlString = htmlString + "<a class='result_title_font'>" + unescape(share.item) + "</a><br />";
	htmlString = htmlString + "<a class='normal_font'>Price</a><br />";
	htmlString = htmlString + "<a class='result_title_font'>" + unescape(share.price) + "</a><br />";
	htmlString = htmlString + "<a class='normal_font'>Address</a><br />";
	htmlString = htmlString + "<a class='result_title_font'>" + unescape(share.address) + "</a><br />";
	htmlString = htmlString + "<a class='normal_font'>Commet</a><br />";
	htmlString = htmlString + "<a class='result_title_font'>" + unescape(share.comment) + "</a><br />";
	htmlString = htmlString + "<a class='normal_font'>Date</a><br />";
	htmlString = htmlString + "<a class='result_title_font'>" + unescape(share.date) + "</a><br />";
	htmlString = htmlString + "</div>";
	return htmlString;
}