<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:qdc="http://epubs.cclrc.ac.uk/xmlns/qdc/"
    xmlns:dcterms="http://purl.org/dc/terms/" exclude-result-prefixes="xs xd oai dc qdc dcterms"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 17, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> tintanet</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
    <xsl:variable name="schemaMODS">http://www.loc.gov/standards/mods/v3/mods-3-5.xsd</xsl:variable>
    <xsl:template match="/">
        <modsCollection xmlns="http://www.loc.gov/mods/v3">
            <xsl:attribute name="xsi:noNamespaceSchemaLocation">
                <xsl:value-of select="$schemaMODS"/>
            </xsl:attribute>
            <xsl:for-each select="//oai:record">
                <mods>
                    <!-- récupération du titre du record -->
                    <xsl:if test="oai:metadata/qdc:qualifieddc/dcterms:title">
                        <titleInfo>
                            <title><xsl:value-of select="oai:metadata/qdc:qualifieddc/dcterms:title"/></title>
                        </titleInfo>
                    </xsl:if>
                    
                    <!-- récupération des dcterms:creator -->
                    <xsl:if test="oai:metadata/qdc:qualifieddc/dcterms:creator">
                        <name type="personal">
                            <xsl:for-each select="oai:metadata/qdc:qualifieddc/dcterms:creator">
                                <namePart>
                                    <xsl:value-of select="."/>
                                </namePart>
                                <role>
                                    <roleTerm type="text">
                                        <xsl:text>creator</xsl:text>
                                    </roleTerm>
                                </role>                                
                            </xsl:for-each>
                        </name>
                    </xsl:if> 
                    
                    <!-- Récupération des dcterms:contributor et mise en place dans <name type="corporate"><namepart> -->
                    <xsl:if test="oai:metadata/qdc:qualifieddc/dcterms:contributor">
                        <name type="corporate">
                            <xsl:for-each select="oai:metadata/qdc:qualifieddc/dcterms:contributor">
                                <namePart>
                                    <xsl:value-of select="."/>
                                </namePart>
                            </xsl:for-each>
                        </name>
                    </xsl:if>
                    
                    
                    <!-- récupération des dcterms:subject -->
                    <xsl:if test="oai:metadata/qdc:qualifieddc/dcterms:subject[not(@scheme='OST')]">
                        <subject>                            
                            <xsl:for-each select="oai:metadata/qdc:qualifieddc/dcterms:subject[not(@scheme='OST')]">
                                <topic><xsl:value-of select="."/></topic>
                            </xsl:for-each>
                        </subject>
                    </xsl:if>
                    
                    <!-- récupération des dcterms:publisher  et/ou de la date d'embargo (copyrightDate) -->
                    <xsl:if test="oai:metadata/qdc:qualifieddc/dcterms:publisher | oai:metadata/qdc:qualifieddc/dcterms:available[@scheme='W3CDTF']">
                        <originInfo>
                            <xsl:for-each select="oai:metadata/qdc:qualifieddc/dcterms:publisher">
                                <publisher>
                                    <xsl:value-of select="."/>
                                </publisher>
                            </xsl:for-each>
                            <xsl:for-each  select="oai:metadata/qdc:qualifieddc/dcterms:available[@scheme='W3CDTF']">
                                <copyrightDate>
                                    <xsl:value-of select="."/>
                                </copyrightDate>
                            </xsl:for-each>
                            
                        </originInfo>                            
                    </xsl:if>
                    
                    <!-- récupération des descriptions ou des abstract -->
                    <xsl:if test="oai:metadata/qdc:qualifieddc/dcterms:description | oai:metadata/qdc:qualifieddc/dcterms:abstract">
                        <xsl:for-each select="oai:metadata/qdc:qualifieddc/dcterms:description">
                            <abstract type="description">
                                <xsl:value-of select="translate(.,'&#xA;', '')"/>
                            </abstract>
                        </xsl:for-each>
                        <xsl:for-each select="oai:metadata/qdc:qualifieddc/dcterms:abstract">
                            <xsl:variable name="xmllangattribute">
                                <xsl:value-of select="current()/@xml:lang"/>
                            </xsl:variable>
                            <abstract>
                                <xsl:if test="string($xmllangattribute)!=''">
                                    <xsl:attribute name="xml:lang">
                                        <xsl:value-of select="$xmllangattribute"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="translate(.,'&#xA;', '')"/>
                            </abstract>
                        </xsl:for-each>
                    </xsl:if>
                    
                    <!-- récupération du doi -->
                    <xsl:for-each select="oai:metadata/qdc:qualifieddc/dcterms:identifier[@scheme='URN']">
                        <xsl:choose>
                            <xsl:when test="starts-with(text(),'urn:doi:')">
                                <identifier type="DOI">
                                    <xsl:value-of select="substring(text(),9)"/>
                                </identifier>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                    
                    <!-- récupération des issn et eissn -->
                    <xsl:if test="oai:metadata/qdc:qualifieddc/dcterms:isPartOf[@scheme='URN']">
                        <relatedItem type="series">
                            <xsl:for-each select="oai:metadata/qdc:qualifieddc/dcterms:isPartOf[@scheme='URN']">
                                <xsl:choose>
                                    <xsl:when test="starts-with(text(),'urn:issn:')">
                                        <identifier type="issn"><xsl:value-of select="substring(.,10)"/></identifier>    
                                    </xsl:when>
                                    
                                    <!--<xsl:when test="starts-with(text(),'urn:isbn:')">
                                        <identifier type="isbn"><xsl:value-of select="substring(.,10)"/></identifier>    
                                    </xsl:when>-->
                                    
                                    <xsl:when test="starts-with(text(),'urn:eissn:')">
                                        <identifier type="eissn"><xsl:value-of select="substring(.,11)"/></identifier>    
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:for-each>
                        </relatedItem>
                    </xsl:if>
                    
                    <!-- récupération de l'url de la notice -->
                    <xsl:if test="oai:metadata/qdc:qualifieddc/dcterms:identifier[@scheme='URI']">
                        <location>
                            <url access="object in context">
                                <xsl:value-of select="oai:metadata/qdc:qualifieddc/dcterms:identifier[@scheme='URI']"/>
                            </url>
                         </location>
                    </xsl:if>
                    
                    <!-- Récupération du language de la notice -->
                    <xsl:if test="oai:metadata/qdc:qualifieddc/dcterms:language[@scheme='RFC1766']">
                        <language>
                            <languageTerm type="code">
                                <xsl:value-of select="oai:metadata/qdc:qualifieddc/dcterms:language[@scheme='RFC1766']"/>
                            </languageTerm>
                        </language>
                    </xsl:if>
                    
                    <!-- récupération du type -->
                    <xsl:if test="oai:metadata/qdc:qualifieddc/dcterms:type">
                        <genre><xsl:value-of select="oai:metadata/qdc:qualifieddc/dcterms:type"/></genre>
                    </xsl:if>
                    
                    <!-- récupération du droit d'accès au record -->
                    <xsl:if test="oai:metadata/qdc:qualifieddc/dcterms:rights">
                        <accessCondition><xsl:value-of select="oai:metadata/qdc:qualifieddc/dcterms:rights"/></accessCondition>
                    </xsl:if>
                    <!-- récupération de l'identifier du record (recordIdentifier) et de son datestamp (recordDateChange) -->
                    <recordInfo>
                        <recordIdentifier>
                            <xsl:value-of select="oai:header/oai:identifier"/>
                        </recordIdentifier>
                        <recordChangeDate>
                            <xsl:value-of select="oai:header/oai:datestamp"/>
                        </recordChangeDate>
                    </recordInfo>                        
                </mods>
            </xsl:for-each>
        </modsCollection>            
    </xsl:template>
</xsl:stylesheet>
