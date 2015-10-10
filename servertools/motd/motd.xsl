<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
    <xsl:output method="xml" indent="yes" encoding="ISO-8859-1"/>
    <xsl:template match="/greeting">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de-DE">
            <head>
<!--
 * * * * * * * * * * * * * * * * * * * * * * * * * *
 * (c) 2009 KillerSpieler, Walki                   *
 * http://steamcommunity.com/groups/ZPSBallerbude  *
 * License: GPLv3+                                 *
 * * * * * * * * * * * * * * * * * * * * * * * * * *
-->
                <title>Ballerbude rules and serversettings</title>
                <meta http-equiv="content-type" content="application/xhtml+xml; charset=ISO-8859-1"/>
                <meta name="author" content="Walki, KillerSpieler"/>
                <meta name="description" content="Ballerbude greeting page."/>
                <link rel="stylesheet" type="text/css" href="greeting09.css"/>
            </head>
            <body>
                <div>
                    <object width="300" height="42">
                        <param name="src" value="joinserver.mp3"/>
                        <param name="autoplay" value="true"/>
                        <param name="controller" value="true"/>
                        <param name="bgcolor" value="#FF9900"/>
                        <embed src="joinserver.mp3" autostart="true" loop="false" width="300" height="42" hidden="true" controller="true" bgcolor="#000000"></embed>
                    </object>
                </div>
                <div id="header"><xsl:text> </xsl:text></div>
                <div id="content">
                    <xsl:apply-templates select="//title"/>
                    <table class="tabelle">
                        <thead>
                            <tr>
                                <th class="lle">Deutsch:</th>
                                <th>English:</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="lle">
                                    <ul>
                                        <xsl:apply-templates select="//de-rule"/>
                                    </ul>
                                </td>
                                <td>
                                    <ul>
                                        <xsl:apply-templates select="//en-rule"/>
                                    </ul>
                                </td>
                            </tr>
                            <tr>
                                <td class="lle">
                                    <ul>
                                        <xsl:apply-templates select="//de-settings"/>
                                    </ul>
                                </td>
                                <td>
                                    <ul>
                                        <xsl:apply-templates select="//en-settings"/>
                                    </ul>
                                </td>
                            </tr>
                            <tr>
                                <td class="lle">
                                    <p class="info2">
                                        Halte Dich an die Regeln und viel Spaß beim spielen!
                                        <br />
                                        Besucht uns auf:
                                        <a href="http://steamcommunity.com/groups/ZPSBallerbude">
                                            http://steamcommunity.com/groups/ZPSBallerbude
                                        </a>
                                    </p>
                                </td>
                                <td>
                                    <p class="info2">
                                        Follow the rules and have fun!
                                        <br />
                                        Visit us:
                                        <a href="http://steamcommunity.com/groups/ZPSBallerbude">
                                            http://steamcommunity.com/groups/ZPSBallerbude
                                        </a>
                                    </p>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="title">
        <h1>
            <xsl:value-of select = "."/>
        </h1>
    </xsl:template>
    <xsl:template match="de-rule">
        <li>
            <xsl:value-of select = "."/>
        </li>
    </xsl:template>
    <xsl:template match="en-rule">
        <li>
            <xsl:value-of select = "."/>
        </li>
    </xsl:template>
    <xsl:template match="de-settings">
        <xsl:for-each select="//de-settings//setting">
            <li>
                <xsl:value-of select="description"/>
                <p class="info" style="color:red;">
                    <xsl:value-of select="value"/>
                </p>
            </li>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="en-settings">
        <xsl:for-each select="//en-settings//setting">
            <li>
                <xsl:value-of select="description"/>
                <p class="info" style="color:red;">
                    <xsl:value-of select="value"/>
                </p>
            </li>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
