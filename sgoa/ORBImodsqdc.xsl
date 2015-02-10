<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:qdc="http://epubs.cclrc.ac.uk/xmlns/qdc/"
    xmlns:dcterms="http://purl.org/dc/terms/" exclude-result-prefixes="xs xd oai dc qdc dcterms ulg oai_dc"
    xmlns:ulg = "http://orbi.ulg.ac.be/ulg/"
    version="2.0">
<xd:doc scope="stylesheet">
    <xd:desc>
        <xd:p><xd:b>Created on:</xd:b> Dec 17, 2014</xd:p>
        <xd:p><xd:b>Author:</xd:b> tintanet</xd:p>
        <xd:p></xd:p>
    </xd:desc>
</xd:doc>
<xsl:output method="xml" encoding="UTF-8" indent="no"/>
<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
<xsl:variable name="schemaMODS">http://www.loc.gov/standards/mods/v3/mods-3-5.xsd</xsl:variable>

<!-- Un template pour obtenir l'issn/eissn/ numéro de volume dans une grande chaine splittée par des espaces -->
<xsl:template match="text()" name="split">
    <xsl:param name="pText" select="."/>
    <xsl:param name="target" />
    <xsl:variable name="afterTarget">
        <xsl:value-of select="substring-after($pText,concat($target,'='))"/>
    </xsl:variable>
    <xsl:variable name="beforeOtherIdt">
        <xsl:value-of select="substring-before($afterTarget,'&amp;')"/>
    </xsl:variable>
    <xsl:value-of select="$beforeOtherIdt"/>
</xsl:template>

<!-- un template pour se débarasser des retours à la ligne 
     et des séquences de whitespace -->
<xsl:template match="text()" name="deleteCarriage">
    <xsl:param name="pText" select="."/>
    <xsl:value-of select="translate(normalize-space($pText),'&#xA;', '')"/>
</xsl:template>



<!-- un template pour afficher les issn et les eissn et le numéro de volume dans une balise relatedItem-->
<xsl:template match="text()" name="findISXN">
    <xsl:param name="pText" select="."/>
    <xsl:if test="contains($pText,'&amp;issn=') or contains($pText,'&amp;eissn=') or contains($pText,'&amp;volume=')">
        <relatedItem type="host" xmlns="http://www.loc.gov/mods/v3">
            <xsl:if test="contains($pText,'&amp;issn=')">
                <identifier type="issn" xmlns="http://www.loc.gov/mods/v3">
                    <xsl:call-template name="split">
                        <xsl:with-param name="pText" select="$pText"/>
                        <xsl:with-param name="target" select="'issn'"/>
                    </xsl:call-template>
                </identifier> 
            </xsl:if>
            <xsl:if test="contains($pText,'&amp;eissn=')">
                <identifier type="eissn" xmlns="http://www.loc.gov/mods/v3">
                    <xsl:call-template name="split">
                        <xsl:with-param name="pText" select="$pText"/>
                        <xsl:with-param name="target" select="'eissn'"/>
                    </xsl:call-template>
                </identifier>
            </xsl:if>
            <xsl:if test="contains($pText,'&amp;volume=')">
                <part xmlns="http://www.loc.gov/mods/v3">
                    <detail type="volume">
                        <number>
                            <xsl:call-template name="split">
                                <xsl:with-param name="pText" select="$pText"/>
                                <xsl:with-param name="target" select="'volume'"/>
                            </xsl:call-template>
                        </number>
                    </detail>
                </part>
            </xsl:if>
            
        </relatedItem>
    </xsl:if>
</xsl:template>

<!-- template pour récupérer le DOI sous forme info:doi -->
<xsl:template match="text()" name="infoDOI">
    <xsl:param name="pText" select="."/>
    <xsl:if test="starts-with($pText,'info:doi:')">
        <xsl:variable name="afterinfodoi">
            <xsl:value-of select="substring-after($pText,'info:doi:')"/>
        </xsl:variable>
       <!-- <identifier type="doi" xmlns="http://www.loc.gov/mods/v3">-->
            <xsl:value-of select="$afterinfodoi"/>
        <!--</identifier>-->
    </xsl:if>
</xsl:template>
    
<!-- Template pour récupérer le doi sous la forme http://dx.doi.org/doi -->
<xsl:template match="text()" name="dxDoiOrg">
    <xsl:param name="pText" select="."/>
    <xsl:if test="starts-with($pText,'http://dx.doi.org/')">
        <xsl:value-of select="substring($pText,19)"/>
    </xsl:if>
</xsl:template>
    
<!-- Template pour récupération du fulltext -->
<xsl:template match="text()" name="fullText">
    <xsl:param name="pText" select="."/>
    
    <xsl:variable name="argToTreat">
        <xsl:call-template name="deleteCarriage">
            <xsl:with-param name="pText" select="$pText"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:if test="ends-with(translate($argToTreat,$uppercase,$smallcase),'.pdf')">
        <url access="raw object" xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$argToTreat"/></url>
    </xsl:if>
</xsl:template>    
    

<!-- Le template principal -->
<xsl:template match="/">
    <modsCollection xmlns="http://www.loc.gov/mods/v3">
        <xsl:attribute name="xsi:noNamespaceSchemaLocation">
            <xsl:value-of select="$schemaMODS"/>
        </xsl:attribute>
        <mods>
            <xsl:for-each select="//oai:record">
                <xsl:if test="oai:metadata/dcterms:qualifieddc/dc:title">
                    <titleInfo>
                        <title>
                            <xsl:call-template name="deleteCarriage">
                                <xsl:with-param name="pText" select="oai:metadata/dcterms:qualifieddc/dc:title"/>
                                </xsl:call-template>
                        </title>
                    </titleInfo>
                </xsl:if>
                <!-- Récupération des issn/eissn et numéro de volume-->
                <xsl:if test="oai:metadata/dcterms:qualifieddc/ulg:bibliographicCitation">
                    <xsl:call-template name="findISXN">
                        <xsl:with-param name="pText" select="oai:metadata/dcterms:qualifieddc/ulg:bibliographicCitation"/>
                    </xsl:call-template>                    
                </xsl:if>
                
                <!-- Récupération du DOI -->
                <xsl:variable name="finalDOI">
                    <xsl:for-each select="oai:metadata/dcterms:qualifieddc/dc:identifier[@type='dcterms:URI']">
                        
                        <xsl:call-template name="infoDOI">
                            <xsl:with-param name="pText" select="."/>
                        </xsl:call-template>
                        
                        <!-- insertion d'un séparateur pour séparer deux doubles doi -->
                        <xsl:value-of select="'|'"/>
                        
                        <xsl:call-template name="dxDoiOrg">
                            <xsl:with-param name="pText" select="."/>
                        </xsl:call-template>
                        
                    </xsl:for-each>
                </xsl:variable>                
                <xsl:if test="$finalDOI!=''">                    
                    <identifier type="doi"><xsl:value-of select="substring-before(replace($finalDOI, '^\|+', ''),'|')"/></identifier>
                </xsl:if>
                
                <!-- récupération de l'url de la notice -->
                <location>
                    <xsl:variable name="afterHandle">
                        <xsl:value-of select="substring-after(oai:header/oai:identifier,'oai:orbi.ulg.ac.be:')"/>
                    </xsl:variable>
                    <url access="object in context">http://orbi.ulg.ac.be/jspui/handle/<xsl:value-of select="$afterHandle"/></url>
                    <!-- récupération du fulltext -->
                    <xsl:for-each select="oai:metadata/dcterms:qualifieddc/dc:identifier[@type='dcterms:URI']">
                        <xsl:call-template name="fullText">
                            <xsl:with-param name="pText" select="."/>
                        </xsl:call-template>
                    </xsl:for-each>                        
                </location>
                <!-- Récupération du type de document -->
                <xsl:if test="oai:metadata/dcterms:qualifieddc/dc:type">
                    <genre>
                        <xsl:for-each select="oai:metadata/dcterms:qualifieddc/dc:type">
                            <xsl:if test="position()=1">
                                <xsl:value-of select="substring(.,24)"/>
                            </xsl:if>
                        </xsl:for-each>
                    </genre>
                </xsl:if>
                
                <!-- récupération des droits sur le record -->
                <xsl:if test="oai:metadata/dcterms:qualifieddc/dcterms:accessRights">
                    <accessCondition type="use and reproduction"><xsl:value-of select="substring(oai:metadata/dcterms:qualifieddc/dcterms:accessRights,24)"/></accessCondition>
                </xsl:if>
                <recordInfo>
                    <recordContentSource>ORBI</recordContentSource>
                    <recordChangeDate>
                        <xsl:value-of select="oai:header/oai:datestamp"/>
                    </recordChangeDate>
                    <recordIdentifier>
                        <xsl:value-of select="oai:header/oai:identifier"/>
                    </recordIdentifier>
                    <recordOrigin>Converted from QDC to MODS (ORBI)</recordOrigin>
                </recordInfo>
           </xsl:for-each>
        </mods>
    </modsCollection>
</xsl:template>
</xsl:stylesheet>
