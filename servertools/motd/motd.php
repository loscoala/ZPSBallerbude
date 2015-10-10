<?php
/*
 * * * * * * * * * * * * * * * * * * * * * * * * * *
 * (c) 2009 KillerSpieler                          *
 * http://steamcommunity.com/groups/ZPSBallerbude  *
 * License: GPLv3+                                 *
 * * * * * * * * * * * * * * * * * * * * * * * * * *
 */ 
$xp = new XSLTProcessor;
$xsl = new DOMDocument;
$xsl->load('motd.xsl');
$xp->importStylesheet($xsl);
$xml = new DOMDocument;
$xml->load('motd.xml');
$output = $xp->transformToXML($xml) or die('Sorry, this service is temporarily not available');
echo $output;
?>
