<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd dc oai oai_dc dcterms"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:dcterms="http://purl.org/dc/terms/"
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
                    <xsl:for-each select="oai:metadata/oai_dc:dc/dc:title">
                        <xsl:if test="position()=1">
                            <titleInfo>
                                <title><xsl:value-of select="translate(.,'&#xA;', '')"/></title>
                            </titleInfo>
                        </xsl:if>
                    </xsl:for-each>
                    
                    <!-- Récupération des dc:creator -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:creator">
                        <name type="personal">
                            <xsl:for-each select="oai:metadata/oai_dc:dc/dc:creator">
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
                    
                    <!-- Récupération des dc:contributor ey mise en place dans <name type="corporate"><namepart> -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:contributor">
                        <name type="corporate">
                            <xsl:for-each select="oai:metadata/oai_dc:dc/dc:contributor">
                                <namePart>
                                    <xsl:value-of select="."/>
                                </namePart>
                            </xsl:for-each>
                        </name>
                    </xsl:if>
                    
                    <!-- Récuparation des dc:subject et transformation en <subject><topic> -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:subject | oai:metadata/oai_dc:dc/dc:coverage">
                        <subject>
                            <xsl:for-each select="oai:metadata/oai_dc:dc/dc:subject">
                                <!-- cherche s'il existe un attribut de type xml:lang à la balise dc:subject 
                                    si oui on le stocke dans la variable xmllangattribute -->
                                <xsl:variable name="xmllangattribute">
                                    <xsl:value-of select="current()/@xml:lang"/>
                                </xsl:variable>
                                <topic>
                                    <!-- test si la variable xmllangattribute est non vide
                                        si c'est bien le cas ajoute l'attribut xml:lang à la balise topic -->
                                    <xsl:if test="string($xmllangattribute)!=''">
                                        <xsl:attribute name="xml:lang">
                                            <xsl:value-of select="$xmllangattribute"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="."/>
                                </topic>
                            </xsl:for-each>
                            <xsl:for-each select="oai:metadata/oai_dc:dc/dc:coverage">
                                <geographic>
                                    <xsl:value-of select="."/>
                                </geographic>
                            </xsl:for-each>
                        </subject>
                    </xsl:if>
                    
                    <!-- récupération du publisher et/ou de la date et mise en forme sous balise originInfo -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:publisher | oai:metadata/oai_dc:dc/dc:date">
                        <originInfo>
                            <xsl:for-each select="oai:metadata/oai_dc:dc/dc:publisher">
                                <publisher>
                                    <xsl:value-of select="."/>
                                </publisher>
                            </xsl:for-each>
                            <xsl:if test="oai:metadata/oai_dc:dc/dc:date">
                                <dateCaptured>
                                    <xsl:value-of select="oai:metadata/oai_dc:dc/dc:date"/>
                                </dateCaptured>
                            </xsl:if>
                        </originInfo>
                    </xsl:if>
                    
                    <!-- ne récupère le contenu que d'une seule balise dc:description -->
                    <xsl:for-each select="oai:metadata/oai_dc:dc/dc:description">
                        <xsl:if test="position()=1">
                            <!-- cherche s'il existe un attribut de type xml:lang à la balise dc:description 
                                si oui on le stocke dans la variable xmllangattribute -->
                            <xsl:variable name="xmllangattribute">
                                <xsl:value-of select="current()/@xml:lang"/>
                            </xsl:variable>
                            <abstract type="description">
                                <!-- si xmllangattribute non vide alors on a un attribut xml:lang dans
                                     la balise dc:description: on reporte donc celui ci dans la balise
                                     abstract -->
                                <xsl:if test="string($xmllangattribute)!=''">
                                    <xsl:attribute name="xml:lang">
                                        <xsl:value-of select="$xmllangattribute"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="translate(.,'&#xA;', '')"/>
                            </abstract>
                        </xsl:if>
                    </xsl:for-each>
                    
 
                    
                    <!-- récupération des informations dc:source et mise en place de celles ci sous balise relatedItem (sans attribut) -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:relation">
                        <relatedItem>
                            <titleInfo>
                                <title>
                                    <xsl:value-of select="oai:metadata/oai_dc:dc/dc:relation"/>
                                </title>
                            </titleInfo>
                        </relatedItem>
                    </xsl:if>
                    
                    <!-- récupération des informations dc:source et mise en place de celles ci sous balise relatedItem type=original -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:source">
                        <relatedItem type="original">
                            <titleInfo>
                                <title>
                                    <xsl:value-of select="oai:metadata/oai_dc:dc/dc:source"/>
                                </title>
                            </titleInfo>
                        </relatedItem>
                    </xsl:if>
                    
                    <!-- récupération des issn/eissn -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:identifier[starts-with(text(),'urn:issn')] | oai:metadata/oai_dc:dc/dc:identifier[starts-with(text(),'urn:eissn')]">
                        <relatedItem type="series">
                            <xsl:if test="oai:metadata/oai_dc:dc/dc:identifier[starts-with(text(),'urn:issn')]">
                                <identifier type="issn"><xsl:value-of select="substring(oai:metadata/oai_dc:dc/dc:identifier[starts-with(text(),'urn:issn')],10)"/></identifier>
                            </xsl:if>
                            <xsl:if test="oai:metadata/oai_dc:dc/dc:identifier[starts-with(text(),'urn:eissn')]">
                                <identifier type="eissn"><xsl:value-of select="substring(oai:metadata/oai_dc:dc/dc:identifier[starts-with(text(),'urn:eissn')],10)"/></identifier>
                            </xsl:if>
                        </relatedItem>
                    </xsl:if>
                    
                    <!-- récupération des url notices et fulltext -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:identifier[starts-with(text(),'http://')]">
                        <location>
                            <xsl:for-each select="oai:metadata/oai_dc:dc/dc:identifier[starts-with(text(),'http://orbi.ulg.ac.be') and not(contains(translate(text(),$smallcase,$uppercase),'.PDF'))]">
                                <url access="object in context">
                                    <xsl:value-of select="."/>
                                </url>
                            </xsl:for-each>
                            <xsl:for-each select="oai:metadata/oai_dc:dc/dc:identifier[starts-with(text(),'http://') and contains(translate(text(),$smallcase,$uppercase),'.PDF')]">
                                <url access="raw object">
                                    <xsl:value-of select="."/>
                                </url>
                            </xsl:for-each> 
                        </location>
                    </xsl:if>
                    
                    <!-- Récupération de l'éventuel DOI -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:identifier[starts-with(text(),'http://dx.doi.org')]">
                        <identifier type="DOI">
                            <xsl:value-of select="substring(oai:metadata/oai_dc:dc/dc:identifier[starts-with(text(),'http://dx.doi.org')],19)"></xsl:value-of>
                        </identifier>
                    </xsl:if>
                    
                    
                    
                    <!-- Récupération du language de la notice -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:language">
                        <language>
                            <languageTerm type="code">
                                <xsl:value-of select="oai:metadata/oai_dc:dc/dc:language"/>
                            </languageTerm>
                        </language>
                    </xsl:if>
                    
                    <!-- récupération du type d'accès -->
                    <xsl:variable name="typeaccess">
                        <xsl:for-each select="oai:metadata/oai_dc:dc/dc:rights[contains(text(),'info:eu-repo/semantics/')]">
                            <xsl:value-of select="substring(text(),24)"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="string($typeaccess)!=''">
                        <accessCondition><xsl:value-of select="$typeaccess"/></accessCondition>
                    </xsl:if>
                    <xsl:if test="string($typeaccess)=''">
                        <accessCondition>undefined</accessCondition>
                    </xsl:if>

                    <!-- Récupération du type de record -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:type">
                        <genre>
                            <xsl:for-each select="oai:metadata/oai_dc:dc/dc:type">
                                <xsl:if test="position()=1">
                                    <xsl:value-of select="substring(.,24)"/>
                                </xsl:if>
                            </xsl:for-each>
                        </genre>
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
