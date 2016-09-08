<xsl:stylesheet version="1.0" xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	exclude-result-prefixes="oai">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<xsl:template match="/">
		<xsl:element name="metadata">
		<xsl:apply-templates select=".//oai:metadata/*[1]"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="*">
		<xsl:copy-of select="."/>
	</xsl:template>
</xsl:stylesheet>
