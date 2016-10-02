<?xml version="1.0" encoding="UTF-8"?>
<!--
    URL extraction for fetch-mirror-sites.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />

    <xsl:template match="/">
        <!--
            Keep the URLs synced with the driver script.
        -->
        <xsl:choose>

            <!-- CTAN (TeX) -->
            <xsl:when test="$url='ctan.org/mirrors'">
                <xsl:apply-templates select="//main/div[@class='left']/a" />
                <xsl:apply-templates select="//main/div[@class='right']/ul/li/a" />
            </xsl:when>

            <!-- Gentoo -->
            <xsl:when test="$url='gentoo.org/downloads/mirrors'">
                <xsl:apply-templates
                    select="id('content')//td[last()]/a[code]" />
            </xsl:when>

            <!-- GNU -->
            <xsl:when test="$url='gnu.org/prep/ftp.html'">
                <xsl:apply-templates
                    select="id('content')//li[not(contains(., '(alpha)'))]/a" />
            </xsl:when>

            <!-- X.Org -->
            <xsl:when test="$url='x.org/wiki/Releases/Download'">
                <xsl:apply-templates select="id('content')//li/a" />
            </xsl:when>

        </xsl:choose>
    </xsl:template>

    <!--
        Assume we're always going to be interested in href and not the
        link text, which is often something useless like "FTP".
    -->
    <xsl:template match="a[@href]">
        <xsl:apply-templates select="@href" />
    </xsl:template>

    <xsl:template match="text()|@*">
        <xsl:value-of select="normalize-space(.)" />
        <!-- Terminate each URL with a newline. -->
        <xsl:text>&#xA;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
