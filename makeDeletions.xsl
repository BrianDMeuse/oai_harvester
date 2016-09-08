<xsl:stylesheet version="1.0" xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<xsl:output method="text" indent="yes" encoding="UTF-8"/>
	<xsl:template match="/oai:OAI-PMH">
		<xsl:apply-templates select="oai:ListRecords"/>
	</xsl:template>
	<xsl:template match="oai:ListRecords">
		<xsl:for-each select="oai:record">
			<!--xsl:value-of select="substring-after(oai:header/oai:identifier,'MIU01-')"/-->
			<xsl:value-of select="oai:header/oai:identifier"/>
			<xsl:text>
</xsl:text>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="text()"/>
</xsl:stylesheet>
