<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" xmlns:marc="http://www.loc.gov/MARC21/slim" exclude-result-prefixes="oai marc">
    <xsl:strip-space elements="*"/>
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/*">
        <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
            <xsl:copy-of select="oai:responseDate"/>
            <xsl:copy-of select="oai:request"/>
            <xsl:apply-templates/>
        </OAI-PMH>
    </xsl:template>
    <xsl:template match="oai:ListRecords">
        <xsl:element name="ListRecords">
            <xsl:for-each select="oai:record">
                <xsl:element name="record">
                    <xsl:element name="header">
                        <xsl:attribute name="status">deleted</xsl:attribute>
                            <xsl:for-each select="oai:header/*">
                                <xsl:copy-of select="."/>
                            </xsl:for-each>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>
