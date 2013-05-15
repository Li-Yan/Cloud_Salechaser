<%@ page import="salechaser.SearchServlet" %>
<%@ page import="salechaser.SaleStore" %>
<%@ page import="salechaser.AccessToken" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" import="java.sql.*" errorPage="" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Salechaser</title>
<script src="./plugin/jquery-1.9.1.min.js"></script>
<link rel="Stylesheet" type="text/css" href="./plugin/wTooltip.css" />
<script type="text/javascript" src="./plugin/wTooltip.js"></script>
<script type="text/javascript" src="./plugin/json2.js"></script>
<script type="text/javascript" src="./tool.js"></script>

<!-- 
storeJSON is a JSON Array, use storeJSON.length to get its length
each storeJSON[i] has the following attributes:
	name;address;phone;showImage;expirationDate;dealTitle;URL;latitude;longitude
-->
<% if (request.getParameter("share_result") != null) {
	String shareString = request.getParameter("share_result");
%>
	<script type="text/javascript">
		alert("<%=shareString %>");
		window.location = "index.jsp";
	</script>
<%
}
%>
<% if (request.getParameter("choose") != null) {
	String map_choose = request.getParameter("choose");
	String map_search = request.getParameter("search");
%>
	<script type="text/javascript">
		var map_choose = "<%=map_choose%>";
		var map_search = "<%=map_search%>";
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET","chosenstoreservlet?choose=" + map_choose + "&search=" + map_search, false);
		xmlhttp.send();
		var storesJson = JSON.parse(xmlhttp.responseText);
	</script>
<%}
%>

<!-- Google Maps API v3 -->
<script type="text/javascript"
src="http://maps.googleapis.com/maps/api/js?key=AIzaSyD-8-qkY0t5gIYFUS3N0OIJHbXMRDT3jNw&sensor=false">
</script>
<script type="text/javascript">
	var location_default = new google.maps.LatLng(40.75818,-73.957043);
	var map;
	var markers = [];
	var user_marker = null;
	var user_location;
	var user_marker_locker = false;
	var infowindow = new google.maps.InfoWindow({maxWidth: 800});
	
	//For route
	var routeJson;
	var directionsDisplay;
	var directionsService = new google.maps.DirectionsService();

	
	function map_initialize() {
		directionsDisplay = new google.maps.DirectionsRenderer();
		var mapOptions = {
			center : location_default,
			zoom : 12,
			mapTypeId : google.maps.MapTypeId.ROADMAP
		};
		map = new google.maps.Map(document.getElementById("map_canvas"),
				mapOptions);
		
		google.maps.event.addListener(map, 'click', function(event) {
			
			if (!user_marker_locker) {
				user_location = event.latLng;
				
				if (user_marker != null) user_marker.setMap(null);
				user_marker = new google.maps.Marker({
					position: user_location,
					map: map,
					icon : 'images/me.png',
					draggable: false,
					animation: google.maps.Animation.DROP
				});
				google.maps.event.addListener(user_marker, 'dblclick', function() {
					if (!user_marker_locker) {
						this.setIcon('images/me_lock.png');
						user_marker_locker = true;
					}
					else {
						this.setIcon('images/me.png');
						user_marker_locker = false;	
					}
				});

				//Display the shortest route
				if (storesJson.length > 0) {
					var xmlhttp = new XMLHttpRequest();
					xmlhttp.open("GET", "routesearchservlet?location=" + user_location + "&choose=" + map_choose
							+ "&search=" + map_search, false);
					xmlhttp.send();
					routeJson = JSON.parse(xmlhttp.responseText);
				}
				if (routeJson.status == "OK") {
					routeJson = routeJson.route;
					var waypts = [];
					for (var i = 0; i < routeJson.length - 1; i++) {
						var toIndex = routeJson[i].to;
						waypts.push({
					          location: new google.maps.LatLng(storesJson[toIndex - 1].latitude, 
					        		  storesJson[toIndex - 1].longitude),
					          stopover: true
					      });
					}
					var request = {
						origin : user_location,
						destination : user_location,
						waypoints: waypts,
					    optimizeWaypoints: true,
						travelMode : google.maps.DirectionsTravelMode.DRIVING
					};
					directionsService.route(request, function(response, status) {
						if (status == google.maps.DirectionsStatus.OK) {
							directionsDisplay.setDirections(response);
						}
					});
				}
				else {
					alert(routeJson.status);
				}
			}
		});

		for ( var i = 0; i < storesJson.length; i++) {
			addMarker(storesJson[i]);
		}
		
		directionsDisplay.setMap(map);
	}

	function addMarker(store) {
		//draw marker
		var location = new google.maps.LatLng(store.latitude, store.longitude);
		marker = new google.maps.Marker({
			position : location,
			map : map,
			icon : 'images/marker.png',
			html : marker_htmlMaker(store),
			draggable : false,
			animation : google.maps.Animation.DROP
		});
		markers.push(marker);

		//set animation
		google.maps.event.addListener(marker, 'click', function() {
			for (var i = 0; i < markers.length; i++) {
				markers[i].setAnimation(null);
			}
			this.setAnimation(google.maps.Animation.BOUNCE);
		});
		google.maps.event.addListener(marker, 'dblclick', function() {
			this.setAnimation(null);
		});

		//infowindow
		google.maps.event.addListener(marker, 'click', function() {
			var index = 0;
			for (index = 0; index < markers.length; index++) {
				if (markers[index] == this)
					break;
			}
			infowindow.setContent(this.html);
			infowindow.open(map, this);
		});
	}

	google.maps.event.addDomListener(window, 'load', map_initialize);
</script>
<!-- End: Google Maps API v3 -->

<style type="text/css">
body {
	background-image: url(images/main_back.jpg);
	background-repeat: repeat;
}
</style>
<style>
.hoverBox {
	display: inline-block;
	margin: 10px;
	padding: 10px 30px;
	border: solid #CACACA 1px;
	cursor: pointer;
}
.info {
}   
.non_display_subpage {
	display: none;
	opacity: 0.88;
	background-image: url(images/subpage_back.jpg);
	background-repeat: no-repeat;
	background-position: center;
}
.logo {
	position: absolute;
	top: 0px;
	right: auto;
}
.page_button {
	position: absolute;
	top: 20px;
	left: 300px;
}
.map {
	position: absolute;
	height: 500px;
	width: 97%;
	right: 1.5%;
	z-index: -1;
	top: 105px;
}
.title_label {
	font-family: "Palatino Linotype", "Book Antiqua", Palatino, serif;
	font-size: 24px;
	font-style: normal;
	font-weight: bold;
	color: #666;
}
.normal_font {
	font-family: "Goudy Old Style";
	font-size: 16px;
	font-weight: bold;
}
.input_font {
	font-family: "Goudy Old Style";
	font-size: 16px;
	font-weight: normal;
	border-top-width: thin;
	border-right-width: thin;
	border-bottom-width: thin;
	border-left-width: thin;
	border-top-style: inset;
	border-right-style: inset;
	border-bottom-style: inset;
	border-left-style: inset;
	color: #777;
}
.normal_button {
	font-family: "Palatino Linotype", "Book Antiqua", Palatino, serif;
	font-size: 16px;
	color: #444;
	background-color: #CCC;
	border: thin outset #CCC;
}
.result_checkbox {
	position: absolute;
	left: 20%;
}
.result_title_font {
	font-family: "Goudy Old Style";
	font-size: 11px;
	color: #555;
}
</style>
</head>

<body>

<!-- Facebook -->
<div id="fb-root"></div>
<script>
	var uid = "";
	var accessToken = "";
	var name = "";
	var userJson;
	window.fbAsyncInit = function() {
		// init the FB JS SDK
	    FB.init({
	      appId		: '574480679251880',
	      status	: true,
	      xfbml		: true,
	      oauth		: true
	    });
	    
	    FB.getLoginStatus(function (response) {
	  	    if (response.status === 'connected') {
	  	        uid = response.authResponse.userID;
	  	        accessToken = response.authResponse.accessToken;
	  	      	var xmlhttp = new XMLHttpRequest();
	  			xmlhttp.open("GET","checkuserservlet?id=" + uid, false);
	  			xmlhttp.send();
	  			userJson = JSON.parse(xmlhttp.responseText);
	  			name = userJson.name;
	  	    } else if (response.status === 'not_authorized') {
	  	    	FB.login();
	  	    } else {
	  	    }
	  	});
	    
	    FB.Event.subscribe('auth.authResponseChange', function(response) { 
	        if (response.status === 'connected') {
	        	uid = response.authResponse.userID;
	  	        accessToken = response.authResponse.accessToken;
	  	      	var xmlhttp = new XMLHttpRequest();
	  			xmlhttp.open("GET","checkuserservlet?id=" + uid, false);
	  			xmlhttp.send();
	  			userJson = JSON.parse(xmlhttp.responseText);
	  			name = userJson.name;
	        } else if (response.status === 'not_authorized') {
	  	    	FB.login();
	  	    } else {
	  	    }
	    });
	};

	// Load the SDK asynchronously
	(function(d){
		var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
		if (d.getElementById(id)) {return;}
		js = d.createElement('script');
		js.id = id;
		js.async = true;
		js.src = "//connect.facebook.net/en_US/all.js";
		ref.parentNode.insertBefore(js, ref);
	}(document));

	(function(d, s, id) {
		var js, fjs = d.getElementsByTagName(s)[0];
		if (d.getElementById(id)) {
			return;
		}
		js = d.createElement(s);
		js.id = id;
		js.src = "//connect.facebook.net/en_US/all.js";
		fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));
</script>
<!-- End Facebook -->

<img src="images/logo.png" alt="logo" width="278" height="100" class="logo" /> 
<div align="right">
<div class="fb-login-button" data-show-faces="true" data-width="250" data-max-rows="5" size="medium"></div>
</div>
<!-- Buttons for multiple jobs -->
<div class="page_button">
<!-- <img id="login_image" src="images/login.png" width="30" height="30" alt="login icon" /> -->
<!-- <img src="images/transparent.png" width="15" height="10" alt="transparent" /> -->
<img id="search_image" src="images/search.png" width="30" height="30" alt="search icon" />
<img src="images/transparent.png" width="15" height="10" alt="transparent" />
<img id="result_image" src="images/result.png" width="30" height="30" alt="result icon" />
<img src="images/transparent.png" width="15" height="10" alt="transparent" />
<img id="share_image" src="images/share.png" width="30" height="30" alt="share icon" />
<img src="images/transparent.png" width="15" height="10" alt="transparent" />
<img id="watch_image" src="images/watch.png" width="30" height="30" alt="share icon" />
<img src="images/transparent.png" width="15" height="10" alt="transparent" />
<img id="follow_image" src="images/follow.png" width="30" height="30" alt="share icon" />
</div>
<!-- End: Buttons for multiple jobs -->
<br />

<script language="javascript">
var login_active = 0;
var search_active = 0;
var result_active = 0;
var share_active = 0;
var watch_active = 0;
var follow_active = 0;
var addressJson;
</script>
<!-- subpage for login -->
<div id="subpage_login" align="center" class="non_display_subpage">
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
<label class="title_label">Login</label> <br />

<form id="login_form">
<img src="images/user.png" width="15" height="15" alt="user" />&nbsp;&nbsp;
<font class="normal_font">User:</font>
<img src="images/transparent.png" width="34" height="10" alt="transperant" />
<input name="user_textField" class="input_font" type="text" size="19" onclick="this.select();"/><br />
<img src="images/transparent.png" width="5" height="3" alt="transperant" /><br />

<img src="images/password.png" width="15" height="15" alt="password" />&nbsp;&nbsp;
<font class="normal_font">Password:</font>
<img src="images/transparent.png" width="5" height="10" alt="transperant" />
<input name="password_textField" class="input_font" type="password" size="19" onclick="this.select();"/><br />
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />

<button id="login_button" class="normal_button" >Login</button>
<img src="images/transparent.png" width="15" height="3" alt="transperant" />
<button id="register_button" class="normal_button" >Register</button><br />
</form>
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
</div>
<!-- End: subpage for login -->

<!-- subpage for search -->
<div id="subpage_search" align="center" class="non_display_subpage">
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
<label class="title_label">Search</label><br />
<img src="images/8coupons_logo.png" width="51" height="12" alt="8coupon logo" /><br />
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />

<form id="search_form">
<img src="images/zipcode.png" width="15" height="15" alt="zipcode" />&nbsp;&nbsp;
<font class="normal_font">Zip Code:</font>
<img src="images/transparent.png" width="34" height="10" alt="transperant" />
<input id="zipcode_textField" name="zipcode_textField" class="input_font" type="text" size="19" value="Empty is valid" onclick="this.select();"/><br />
<img src="images/transparent.png" width="5" height="3" alt="transperant" /><br />

<img src="images/mileradius.png" width="15" height="15" alt="mileradius" />&nbsp;&nbsp;
<font class="normal_font">Mile Radius:</font>
<img src="images/transparent.png" width="15" height="10" alt="transperant" />
<input id="mileradius_textField" name="mileradius_textField" class="input_font" type="text" size="19" value="Empty is valid" onclick="this.select();"/><br />
<img src="images/transparent.png" width="5" height="3" alt="transperant" /><br />

<img src="images/category.png" width="15" height="15" alt="category" />&nbsp;&nbsp;
<font class="normal_font">Category:</font>
<img src="images/transparent.png" width="34" height="10" alt="transperant" />
<select id="category_select" name="category_select" class="input_font" >
<option value="any">- Any -&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</option>
<option value="Restaurants">Restaurants</option>
<option value="Entertainment">Entertainment</option>
<option value="Beauty & Spa">Beauty & Spa</option>
<option value="Services">Services</option>
<option value="Shopping">Shopping</option>
<option value="Travel">Travel</option>
</select><br />
<img src="images/transparent.png" width="5" height="3" alt="transperant" /><br />

<img src="images/keyword.png" width="15" height="15" alt="keyword" />&nbsp;&nbsp;
<font class="normal_font">Keyword:</font>
<img src="images/transparent.png" width="34" height="10" alt="transperant" />
<input id="keyword_textField" name="keyword_textField" class="input_font" type="text" size="19" value="Empty is valid" onclick="this.select();"/><br />
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />
<input id="search_parameter" name="search_parameter" type="hidden" /> 

<button id="search_button" class="normal_button" >Search</button><br />
</form>

<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
</div>
<!-- End: subpage for search -->

<!-- subpage for result -->
<div id="subpage_result" align="center" class="non_display_subpage">
<% if (request.getParameter("show") != null) {
%>
	<script language="javascript">
		$("#subpage_result").slideToggle(700);
		document.getElementById("result_image").src = "images/result_active.png";
		result_active = 1;
	</script>
<%	
}
%>
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
<label class="title_label">Result</label><br />
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />

<font class="normal_font">Select Stores</font><br />
<img src="images/transparent.png" width="5" height="3" alt="transperant" /><br />

<form id="result_form">
<input id="choose_parameter" name="choose_parameter" type="hidden" />
<script language="javascript">
var result_number = 0;
</script>
<% String search = "";
if (request.getParameter("search") != null) {
	search = request.getParameter("search");
	ArrayList<SaleStore> stores = SaleStore.getStores(request.getParameter("search"));
	if (stores.size() > 0) {
		int m = 0;
		for (SaleStore saleStore : stores) {
%>
			<script language="javascript">
				document.write("<div class='result_checkbox'>");
				document.write("<div class='fb-like' data-href='" + "<%=saleStore.URL %>" + "' data-layout='button_count' data-show-faces='false'></div>");
				document.write("<input id='result_checkbox" + "<%=m %>" + "' type='checkbox' name='" + "<%=m %>" + "' onclick='setLike(this.name)'>");
				document.write("<img src='" + "<%=saleStore.showImage %>" + "' width='27' height='27' />");
				document.write("<font class='normal_font'>&nbsp;" + unescape("<%=saleStore.name %>") + ": </font>");
				document.write("<a class='result_title_font' href='#' onClick=\"window.open(\'" + "<%=saleStore.URL %>" + "\')\">" + unescape("<%=saleStore.dealTitle %>") + "</a>");
				document.write("</input>");
				document.write("</div><br />");
				document.write("<img src='images/transparent.png' width='5' height='10' alt='transperant' /><br />");
				result_number++;
			</script>
<%	
			m++;
		}
	}
}
%>
<br />

<button id="choose_button" class="normal_button" >Choose</button>
</form>

<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
</div>
<!-- End: subpage for result -->

<!-- subpage for share -->
<div id="subpage_share" align="center" class="non_display_subpage">
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
<label class="title_label">Share</label> <br />

<!-- Share with tweet -->
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />
<div id="tweet-div">
<a id="tweet_button" href="https://twitter.com/share" class="twitter-share-button" 
	data-text="salechaser" data-lang="en" data-count="none" >Tweet</a>
<script>
	!function(d,s,id) {
		var js,fjs=d.getElementsByTagName(s)[0];
		if(!d.getElementById(id)) {
			js=d.createElement(s);
			js.id=id;js.src="https://platform.twitter.com/widgets.js";
			fjs.parentNode.insertBefore(js,fjs);
		}
	}(document,"script","twitter-wjs");
</script>
<br />
</div>
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />

<form id="share_form" enctype="multipart/form-data">

<img src="images/user.png" width="15" height="15" alt="user" />&nbsp;&nbsp;
<font class="normal_font">User:</font>
<img src="images/transparent.png" width="40" height="10" alt="transperant" />
<input id="share_user_textField" name="share_user_textField" class="input_font" type="text" size="33" disabled /><br />
<img src="images/transparent.png" width="5" height="3" alt="transperant" /><br />

<img src="images/item.png" width="15" height="15" alt="user" />&nbsp;&nbsp;
<font class="normal_font">Item:</font>
<img src="images/transparent.png" width="40" height="10" alt="transperant" />
<input id="share_item_textField" name="share_item_textField" class="input_font" type="text" size="33" value="" onchange="change_tweet();"/><br />
<img src="images/transparent.png" width="5" height="3" alt="transperant" /><br />

<img src="images/price.png" width="15" height="15" alt="user" />&nbsp;&nbsp;
<font class="normal_font">Price:</font>
<img src="images/transparent.png" width="36" height="10" alt="transperant" />
<input id="share_price_textField" name="share_price_textField" class="input_font" type="text" size="33" value="" onchange="change_tweet();"/><br />
<img src="images/transparent.png" width="5" height="3" alt="transperant" /><br />

<img src="images/location.png" width="15" height="15" alt="user" />&nbsp;&nbsp;
<font class="normal_font">Address:</font>
<img src="images/transparent.png" width="20" height="10" alt="transperant" />
<input id="share_address_textField" name="share_address_textField" class="input_font" type="text" size="29" value="" onchange="change_tweet();"/>&nbsp;&nbsp;
<img id="share_refresh_image" src="images/refresh.png" width="15" height="15" alt="user" /><br />
<img src="images/transparent.png" width="5" height="3" alt="transperant" /><br />

<img src="images/comment.png" width="15" height="15" alt="user" />&nbsp;&nbsp;
<font class="normal_font">Comment:</font>
<img src="images/transparent.png" width="5" height="10" alt="transperant" />
<textarea id="share_comment_textArea" name="share_comment_textArea" class="input_font" rows="4" cols="31" style="vertical-align:top" onchange="change_tweet();"></textarea><br />
<img src="images/transparent.png" width="5" height="3" alt="transperant" /><br />

<img src="images/picture.png" width="15" height="15" alt="user" />&nbsp;&nbsp;
<font class="normal_font">Picture:</font>
<img src="images/transparent.png" width="19" height="10" alt="transperant" />
<input id="share_picture_file" name="share_picture_file" type="file" class="input_font" size="11" accept="image/*" /><br />
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />

<input id="share_parameter" name="share_parameter" type="hidden" />

<script type="text/javascript">
function change_tweet() {
	var tweet_string = "I want to share:\n";
	var tweet_temp_string = document.getElementById("share_item_textField").value;
	if (tweet_temp_string != "") {
		tweet_string = tweet_string + " - Item: " + tweet_temp_string + "\n";
	}
	tweet_temp_string = document.getElementById("share_price_textField").value;
	if (tweet_temp_string != "") {
		tweet_string = tweet_string + " - Price: " + tweet_temp_string + "\n";
	}
	tweet_temp_string = document.getElementById("share_address_textField").value;
	if (tweet_temp_string != "") {
		tweet_string = tweet_string + " - Address: " + tweet_temp_string + "\n";
	}
	tweet_temp_string = document.getElementById("share_comment_textArea").value;
	if (tweet_temp_string != "") {
		tweet_string = tweet_string + " - Comment: " + tweet_temp_string + "\n";
	}
	
	//Renew the twitter button
	$(".twitter-share-button").remove();
	var tweet = $('<a>')
	.attr('href', "https://twitter.com/share")
	.attr('id', "tweet_button")
	.attr('class', "twitter-share-button")
	.attr('data-lang', "en")
	.attr('data-count', "none")
	.text('Share as Tweet');
	 
	$("#tweet-div").prepend(tweet);
	tweet.attr('data-text', tweet_string);
	tweet.attr('data-url', document.URL);
	twttr.widgets.load();
}
</script>

<button id="share_button" class="normal_button" >Share</button><br />
</form>

<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
</div>
<!-- End: subpage for share -->

<!-- subpage for watch -->
<div id="subpage_watch" align="center" class="non_display_subpage">
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
<label class="title_label">Watch</label> <br />

<img src="images/users.png" width="15" height="15" alt="user" />&nbsp;&nbsp;
<font class="normal_font">Followed Users:</font>
<img src="images/transparent.png" width="5" height="10" alt="transperant" />
<select id="watch_user_select" name="watch_user_select" class="input_font" style="width:270px"></select><br />
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />

<font class="normal_font">Share List</font><br />
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />
<select id="share_select" name="share_select" size="7" multiple="multiple" class="input_font" style="width:570px"></select><br />

<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
</div>
<!-- End: subpage for watch -->

<!-- subpage for follow -->
<div id="subpage_follow" align="center" class="non_display_subpage">
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
<label class="title_label">Follow</label><br />
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />

<font class="normal_font">Search User:</font>
<img src="images/transparent.png" width="5" height="10" alt="transperant" />
<input id="follow_search_textField" name="follow_search_textField" class="input_font" type="text" size="33" value="" onclick="this.select();"/>&nbsp;&nbsp;
<img id="user_search_image" src="images/user_search.png" width="15" height="15" alt="user" /><br />
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />

<font class="normal_font">Follow List</font><br />
<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />

<select id="follow_select" name="follow_select" size="7" multiple="multiple" class="input_font" style="width:370px"></select><br />
<img src="images/transparent.png" width="19" height="10" alt="transperant" /><br />

<button id="follow_list_button" class="normal_button" style="width:80px">List</button>
<img src="images/transparent.png" width="10" height="10" alt="transperant" />

<button id="follow_button" class="normal_button" style="width:80px">Follow</button>
<img src="images/transparent.png" width="10" height="10" alt="transperant" />

<button id="unfollow_button" class="normal_button" style="width:80px">Unfollow</button><br />
<img src="images/transparent.png" width="5" height="10" alt="transperant" /><br />

<img src="images/transparent.png" width="5" height="5" alt="transperant" /><br />
<img src="images/separator.png" width="800" height="10" alt="separator" /><br />
</div>
<!-- End: subpage for follow -->

<!-- map operation -->
<div id="map_canvas" class="map" align="center" />
<!-- End: map operation -->

<!-- Mouse over notification -->
<script type="text/javascript">
$('.mooTest').wTooltip();
console.log($('.mooTest').wTooltip('opacity'));
$('.mooTest :first').wTooltip('opacity', 0.2);
console.log($('.mooTest').wTooltip('opacity'));

$("#login_image").wTooltip({
	title: "Login/Logout",
	theme: "black"
});
$("#search_image").wTooltip({
	title: "Search",
	theme: "black"
});
$("#result_image").wTooltip({
	title: "Result",
	theme: "black"
});
$("#share_image").wTooltip({
	title: "Share",
	theme: "black"
});
$("#follow_image").wTooltip({
	title: "Follow",
	theme: "black"
});
$("#share_refresh_image").wTooltip({
	title: "Refresh address",
	theme: "yellow"
});
$("#user_search_image").wTooltip({
	title: "Search user",
	theme: "yellow"
});
$("#follow_list_button").wTooltip({
	title: "List my follows",
	theme: "yellow"
});
$("#follow_button").wTooltip({
	title: "Follow this user",
	theme: "yellow"
});
$("#unfollow_button").wTooltip({
	title: "Unfollow this user",
	theme: "yellow"
});
</script>
<!-- End: Mouse over notification -->

<!-- jQuery -->
<script type="text/javascript">
$(document).ready(function(){
	//login_image
	$("#login_image").click(function() {
		$("#subpage_login").fadeToggle("slow");
		$("#subpage_search").hide();
		$("#subpage_result").hide();
		$("#subpage_share").hide();
		$("#subpage_watch").hide();
		$("#subpage_follow").hide();
	});
	$("#login_image").mousedown(function() {
		document.getElementById("login_image").src = "images/login_down.png";
	});
	$("#login_image").mouseup(function() {
		if (login_active) {
			//document.getElementById("login_image").src = "images/login.png";
			document.getElementById("search_image").src = "images/search.png";
			document.getElementById("result_image").src = "images/result.png";
			document.getElementById("share_image").src = "images/share.png";
			document.getElementById("watch_image").src = "images/watch.png";
			document.getElementById("follow_image").src = "images/follow.png";
			login_active = 0;
			search_active = 0;
			result_active = 0;
			share_active = 0;
			watch_active = 0;
			follow_active = 0;
		}
		else {
			//document.getElementById("login_image").src = "images/login_active.png";
			document.getElementById("search_image").src = "images/search.png";
			document.getElementById("result_image").src = "images/result.png";
			document.getElementById("share_image").src = "images/share.png";
			document.getElementById("watch_image").src = "images/watch.png";
			document.getElementById("follow_image").src = "images/follow.png";
			login_active = 1;
			search_active = 0;
			result_active = 0;
			share_active = 0;
			watch_active = 0;
			follow_active = 0;
		}
	});
	//search_image
	$("#search_image").click(function() {
		$("#subpage_login").hide();
		$("#subpage_search").fadeToggle("slow");
		$("#subpage_result").hide();
		$("#subpage_share").hide();
		$("#subpage_watch").hide();
		$("#subpage_follow").hide();
	});
	$("#search_image").mousedown(function() {
		document.getElementById("search_image").src = "images/search_down.png";
	});
	$("#search_image").mouseup(function() {
		if (search_active) {
			//document.getElementById("login_image").src = "images/login.png";
			document.getElementById("search_image").src = "images/search.png";
			document.getElementById("result_image").src = "images/result.png";
			document.getElementById("share_image").src = "images/share.png";
			document.getElementById("watch_image").src = "images/watch.png";
			document.getElementById("follow_image").src = "images/follow.png";
			login_active = 0;
			search_active = 0;
			result_active = 0;
			share_active = 0;
			watch_active = 0;
			follow_active = 0;
		}
		else {
			//document.getElementById("login_image").src = "images/login.png";
			document.getElementById("search_image").src = "images/search_active.png";
			document.getElementById("result_image").src = "images/result.png";
			document.getElementById("share_image").src = "images/share.png";
			document.getElementById("watch_image").src = "images/watch.png";
			document.getElementById("follow_image").src = "images/follow.png";
			login_active = 0;
			search_active = 1;
			result_active = 0;
			share_active = 0;
			watch_active = 0;
			follow_active = 0;
		}
	});
	//result_image
	$("#result_image").click(function() {
		$("#subpage_login").hide();
		$("#subpage_search").hide();
		$("#subpage_result").fadeToggle("slow");
		$("#subpage_share").hide();
		$("#subpage_watch").hide();
		$("#subpage_follow").hide();
	});
	$("#result_image").mousedown(function() {
		document.getElementById("result_image").src = "images/result_down.png";
	});
	$("#result_image").mouseup(function() {
		if (result_active) {
			//document.getElementById("login_image").src = "images/login.png";
			document.getElementById("search_image").src = "images/search.png";
			document.getElementById("result_image").src = "images/result.png";
			document.getElementById("share_image").src = "images/share.png";
			document.getElementById("watch_image").src = "images/watch.png";
			document.getElementById("follow_image").src = "images/follow.png";
			login_active = 0;
			search_active = 0;
			result_active = 0;
			share_active = 0;
			watch_active = 0;
			follow_active = 0;
		}
		else {
			//document.getElementById("login_image").src = "images/login.png";
			document.getElementById("search_image").src = "images/search.png";
			document.getElementById("result_image").src = "images/result_active.png";
			document.getElementById("share_image").src = "images/share.png";
			document.getElementById("watch_image").src = "images/watch.png";
			document.getElementById("follow_image").src = "images/follow.png";
			login_active = 0;
			search_active = 0;
			result_active = 1;
			share_active = 0;
			watch_active = 0;
			follow_active = 0;
		}
	});
	//share_image
	$("#share_image").click(function() {
		$("#subpage_login").hide();
		$("#subpage_search").hide();
		$("#subpage_result").hide();
		$("#subpage_share").fadeToggle("slow");
		$("#subpage_watch").hide();
		$("#subpage_follow").hide();
	});
	$("#share_image").mousedown(function() {
		document.getElementById("share_image").src = "images/share_down.png";
	});
	$("#share_image").mouseup(function() {
		if (share_active) {
			//document.getElementById("login_image").src = "images/login.png";
			document.getElementById("search_image").src = "images/search.png";
			document.getElementById("result_image").src = "images/result.png";
			document.getElementById("share_image").src = "images/share.png";
			document.getElementById("watch_image").src = "images/watch.png";
			document.getElementById("follow_image").src = "images/follow.png";
			login_active = 0;
			search_active = 0;
			result_active = 0;
			share_active = 0;
			watch_active = 0;
			follow_active = 0;
		}
		else {
			//document.getElementById("login_image").src = "images/login.png";
			document.getElementById("search_image").src = "images/search.png";
			document.getElementById("result_image").src = "images/result.png";
			document.getElementById("share_image").src = "images/share_active.png";
			document.getElementById("watch_image").src = "images/watch.png";
			document.getElementById("follow_image").src = "images/follow.png";
			document.getElementById("share_user_textField").value = name;
			login_active = 0;
			search_active = 0;
			result_active = 0;
			share_active = 1;
			watch_active = 0;
			follow_active = 0;
		}
	});
	//watch_image
	$("#watch_image").click(function() {
		$("#subpage_login").hide();
		$("#subpage_search").hide();
		$("#subpage_result").hide();
		$("#subpage_share").hide();
		$("#subpage_watch").fadeToggle("slow");
		$("#subpage_follow").hide();
	});
	$("#watch_image").mousedown(function() {
		document.getElementById("watch_image").src = "images/watch_down.png";
	});
	$("#watch_image").mouseup(function() {
		if (watch_active) {
			//document.getElementById("login_image").src = "images/login.png";
			document.getElementById("search_image").src = "images/search.png";
			document.getElementById("result_image").src = "images/result.png";
			document.getElementById("share_image").src = "images/share.png";
			document.getElementById("watch_image").src = "images/watch.png";
			document.getElementById("follow_image").src = "images/follow.png";
			login_active = 0;
			search_active = 0;
			result_active = 0;
			share_active = 0;
			watch_active = 0;
			follow_active = 0;
		}
		else {
			//document.getElementById("login_image").src = "images/login.png";
			document.getElementById("search_image").src = "images/search.png";
			document.getElementById("result_image").src = "images/result.png";
			document.getElementById("share_image").src = "images/share.png";
			document.getElementById("watch_image").src = "images/watch_active.png";
			document.getElementById("follow_image").src = "images/follow.png";
			//Update the select for followed user whenever this subpage is checked
			var watch_user_select = document.getElementById("watch_user_select");
			watch_user_select.options.length=0;
			watch_user_select.options.add(new Option("- Please select a user -", "0"));
			watch_user_select.options.add(new Option(name + " (self)", uid));
			var xmlhttp = new XMLHttpRequest();
			xmlhttp.open("GET","searchfollowservlet?id=" + uid + "&add_follow_string=false", false);
			xmlhttp.send();
			var watch_followJson = JSON.parse(xmlhttp.responseText);
			for (var i = 0; i < watch_followJson.length; i++) {
				watch_user_select.options.add(new Option(watch_followJson[i].name, watch_followJson[i].id)); 
			}
			login_active = 0;
			search_active = 0;
			result_active = 0;
			share_active = 0;
			watch_active = 1;
			follow_active = 0;
		}
	});
	//follow_image
	$("#follow_image").click(function() {
		$("#subpage_login").hide();
		$("#subpage_search").hide();
		$("#subpage_result").hide();
		$("#subpage_share").hide();
		$("#subpage_watch").hide();
		$("#subpage_follow").fadeToggle("slow");
	});
	$("#follow_image").mousedown(function() {
		document.getElementById("follow_image").src = "images/follow_down.png";
	});
	$("#follow_image").mouseup(function() {
		if (follow_active) {
			//document.getElementById("login_image").src = "images/login.png";
			document.getElementById("search_image").src = "images/search.png";
			document.getElementById("result_image").src = "images/result.png";
			document.getElementById("share_image").src = "images/share.png";
			document.getElementById("watch_image").src = "images/watch.png";
			document.getElementById("follow_image").src = "images/follow.png";
			login_active = 0;
			search_active = 0;
			result_active = 0;
			share_active = 0;
			watch_active = 0;
			follow_active = 0;
		}
		else {
			//document.getElementById("login_image").src = "images/login.png";
			document.getElementById("search_image").src = "images/search.png";
			document.getElementById("result_image").src = "images/result.png";
			document.getElementById("share_image").src = "images/share.png";
			document.getElementById("watch_image").src = "images/watch.png";
			document.getElementById("follow_image").src = "images/follow_active.png";
			document.getElementById("share_user_textField").value = name;
			login_active = 0;
			search_active = 0;
			result_active = 0;
			share_active = 0;
			watch_active = 0;
			follow_active = 1;
		}
	});
	
	
	//Image click
	$("#share_refresh_image").click(function() {
		var address_text = document.getElementById("share_address_textField").value;
		if ((address_text == null) || (address_text == "")) {
			alert("Error: Please input the address");
		}
		else {
			var xmlhttp = new XMLHttpRequest();
			xmlhttp.open("GET","searchaddressservlet?address=" + address_text, false);
			xmlhttp.send();
			addressJson = JSON.parse(xmlhttp.responseText);
			alert("Do mean: " + addressJson.formatted_address + "?\nIf not, please search again.");
			document.getElementById("share_address_textField").value = addressJson.formatted_address;
		}
	});
	$("#share_refresh_image").mousedown(function() {
		document.getElementById("share_refresh_image").src = "images/refresh_down.png";
	});
	$("#share_refresh_image").mouseup(function() {
		document.getElementById("share_refresh_image").src = "images/refresh.png";
	});
	$("#user_search_image").click(function() {
		if (uid == "") {
			alert("Error: Please login with your facebook account first!");
			return;
		}
		
		var user_search_text = document.getElementById("follow_search_textField").value;
		if ((user_search_text == null) || (user_search_text == "")) {
			alert("Error: Please input the name to search!");
		}
		else {
			var xmlhttp = new XMLHttpRequest();
			xmlhttp.open("GET","searchuserservlet?id=" + uid + "&search=" + user_search_text, false);
			xmlhttp.send();
			var usersSearchJson = JSON.parse(xmlhttp.responseText);
			var follow_select = document.getElementById("follow_select");
			follow_select.options.length=0;
			for (var i = 0; i < usersSearchJson.length; i++) {
				follow_select.options.add(new Option(usersSearchJson[i].name, usersSearchJson[i].id));
			}
		}
	});
	$("#user_search_image").mousedown(function() {
		document.getElementById("user_search_image").src = "images/user_search_down.png";
	});
	$("#user_search_image").mouseup(function() {
		document.getElementById("user_search_image").src = "images/user_search.png";
	});
	
	//Button click
	$("#login_button").mousedown(function() {
		alert("Code for login is coming!");
	});
	$("#register_button").mousedown(function() {
		alert("Code for register is coming!");
	});
	$("#search_button").mousedown(function() {
		zipcode_textField = document.getElementById("zipcode_textField");
		zipcode = zipcode_textField.value;
		if (zipcode == "Empty is valid") {
			zipcode = "";
		}
		else if (!valid_zipCode(zipcode) && (zipcode != "")) {
			alert("Error: Zip Code should be 5 digits.");
			return;
		}
		
		mileradius_textField = document.getElementById("mileradius_textField");
		mileradius = mileradius_textField.value;
		if (mileradius == "Empty is valid") {
			mileradius = "";
		}
		else if (!valid_mileRadius(mileradius) && (mileradius != "")) {
			alert("Error: Mile Radius should an integer.");
			return;
		}
		document.getElementById("search_parameter").value = window.location.href;
		form = document.getElementById("search_form");
		form.action = "searchservlet";
		form.method = "get";
		form.submit();
	});
	$("#choose_button").mousedown(function() {
		var checked = false;
		var checkedCount = 0;
		var checkedString = "";
		for (var i = 0; i < result_number; i++) {
			if (document.getElementById("result_checkbox" + i) != null) {
				checkbox = document.getElementById("result_checkbox" + i);
				if (checkbox.checked) {
					checkedString = checkedString + "1";
					checkedCount++;
					checked = true;
				}
				else {
					checkedString = checkedString + "0";
				}
			}
			else {
				checkedString = checkedString + "0";
			}
		}
		if (!checked) {
			alert("Error: no store checked!");
			document.getElementById("choose_parameter").value = "show=1&search=<%=search %>";
		}
		else if (checkedCount > 6) {
			alert("Error: this is free Google Map API v3, which supports at most 8 " 
					+ "waypoints(include start and end). So you can choose at most 6 stores)!");
			document.getElementById("choose_parameter").value = "show=1&search=<%=search %>";
		}
		else {
			document.getElementById("choose_parameter").value = "search=<%=search %>&choose=" 
				+ checkedString;
		}
		form = document.getElementById("result_form");
		form.action = "chooseservlet";
		form.method = "post";
		form.submit();
	});
	$("#share_button").mousedown(function() {
		if (uid == "") {
			alert("Error: Please login with your facebook account first!");
			return;
		}
		var item = document.getElementById("share_item_textField").value;
		var price = document.getElementById("share_price_textField").value;
		var address = document.getElementById("share_address_textField").value;
		if (item == "") {
			alert("Error: Please input item!");
			return;
		}
		if (price == "") {
			alert("Error: Please input price!");
			return;
		}
		
		if (!valid_sharePrice(price)) {
			alert("Please input the price in USD(e.g. $100).");
			return;
		}
		if (address == "") {
			alert("Error: Please input address!");
			return;
		}
		
		//Finished Check
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET","searchaddressservlet?address=" + address, false);
		xmlhttp.send();
		addressJson = JSON.parse(xmlhttp.responseText);
		document.getElementById("share_address_textField").value = addressJson.formatted_address;
		document.getElementById("share_parameter").value = uid + "," + name + "," + addressJson.latitude 
			+ "," + addressJson.longitude;
		
		//Form submit
 		form = document.getElementById("share_form");
		form.action = "shareservlet";
		form.method = "post";
		form.submit();
	});
	$("#follow_list_button").click(function() {
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET","searchfollowservlet?id=" + uid + "&add_follow_string=true", false);
		xmlhttp.send();
		var followSearchJson = JSON.parse(xmlhttp.responseText);
		var follow_select = document.getElementById("follow_select");
		follow_select.options.length=0;
		for (var i = 0; i < followSearchJson.length; i++) {
			follow_select.options.add(new Option(followSearchJson[i].name, followSearchJson[i].id)); 
		}
	});
	$("#follow_button").click(function() {
		if (uid == "") {
			alert("Error: Please login with your facebook account first!");
			return;
		}
		
		var follow_select = document.getElementById("follow_select");
		if (follow_select.options[follow_select.selectedIndex] == null) {
			alert("Error: Please select a user!");
			return;
		}
		var follow_option = follow_select.options[follow_select.selectedIndex];
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("POST","followservlet?follow=true&followerID=" + uid + "&followeeID=" 
				+ follow_option.value + "&followeeName=" + follow_option.text, false);
		xmlhttp.send();
		if (xmlhttp.responseText == "OK") {
			alert("Follow succeeds!");
			follow_select.options.length=0;
		}
		else {
			alert(xmlhttp.responseText);
		}
	});
	$("#unfollow_button").click(function() {
		if (uid == "") {
			alert("Error: Please login with your facebook account first!");
			return;
		}
		
		var follow_select = document.getElementById("follow_select");
		if (follow_select.options[follow_select.selectedIndex] == null) {
			alert("Error: Please select a user!");
			return;
		}
		var follow_option = follow_select.options[follow_select.selectedIndex];
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("POST","followservlet?follow=false&followerID=" + uid + "&followeeID=" 
				+ follow_option.value + "&followeeName=" + follow_option.text, false);
		xmlhttp.send();
		if (xmlhttp.responseText == "OK") {
			alert("Unfollow succeeds!");
			follow_select.options.length=0;
		}
		else {
			alert(xmlhttp.responseText);
		}
	});
	
	//Select Change
	$("#watch_user_select").change(function() {
		if (uid == "") {
			alert("Error: Please login with your facebook account first!");
			return;
		}
		var watch_user_select = document.getElementById("watch_user_select");
		if (watch_user_select.options[watch_user_select.selectedIndex] == null) {
			alert("Error: Please select a user!");
			return;
		}
		var watch_user_option = watch_user_select.options[watch_user_select.selectedIndex];
		if (watch_user_option.text == "- Please select a user -") {
			return;
		}
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET","searchshareservlet?id=" + watch_user_option.value, false);
		xmlhttp.send();
		var shareJson = JSON.parse(xmlhttp.responseText);
		var share_select = document.getElementById("share_select");
		share_select.options.length=0;
		for (var i = 0; i < shareJson.length; i++) {
			var share_string = shareJson[i].date + " " + shareJson[i].userName + ": " + 
				shareJson[i].price + " " + shareJson[i].item;
			share_select.options.add(new Option(share_string, shareJson[i].userID)); 
		}
	});
});
</script>
<!-- End: jQuery -->
</body>
</html>