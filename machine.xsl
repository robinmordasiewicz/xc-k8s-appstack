<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="@*|node()" name="identity">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="domain/*[1][not(/domain/metadata)]">
	    <xsl:element name ="metadata">
    <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
    <libosinfo:os id="http://centos.org/centos/7.0"/>
    </libosinfo:libosinfo>
  </xsl:element>
    <xsl:call-template name="identity" />
    </xsl:template>

</xsl:stylesheet>
