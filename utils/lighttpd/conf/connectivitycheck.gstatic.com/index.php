<?php
	ob_start();
	header("HTTP/1.1 204 No Content");
        
        //header("HTTP/1.1 404");
        //header("Location:http://ermes", true, 302);

       //header("Location: /captive.html", true, 302);
        //header('Location: /captive.html');
        ///header('Refresh: 1; url=/captive.html');
        //print 'You will be redirected in 1 seconds';
        header("Content-Length: 0");
        //Date: Mon, 25 Mar 2019 11:19:43 GMT
        header("Date: ".date_format($date, 'D, d M Y H:i:s e'));
        header("Cache-Control: no-cache, no-store, must-revalidate"); // HTTP 1.1.
	header("Pragma: no-cache"); // HTTP 1.0.
	header("Expires: 0"); //Proxies.
	ob_end_flush(); //now the headers are sent
?>
