<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd oai oai_dc dc dcterms xsi"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dcterms="http://purl.org/dc/terms/"    
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 16, 2014</xd:p>
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
                    <!-- récupération du titre de la notice dc:title -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:title">
                        <titleInfo>
                            <title>
                                <xsl:value-of select="oai:metadata/oai_dc:dc/dc:title"/>
                            </title>
                        </titleInfo>
                    </xsl:if>
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:creator">
                        <name type="personal">
                            <xsl:for-each select="oai:metadata/oai_dc:dc/dc:creator">
                                    <namePart>
                                        <xsl:value-of select="."/>
                                    </namePart>
                            </xsl:for-each>
                        </name>
                    </xsl:if>
                     <xsl:if test="oai:metadata/oai_dc:dc/dc:subject">
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
                    <!-- récupération de la description de la notice -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:description">
                        <abstract type="description">
                            <xsl:value-of select="oai:metadata/oai_dc:dc/dc:description"/>
                        </abstract>
                    </xsl:if>
                    <!-- Récupération du language de la notice -->
                    <xsl:if test="oai:metadata/oai_dc:dc/dc:language">
                        <language>
                            <languageTerm type="code">
                                <xsl:value-of select="oai:metadata/oai_dc:dc/dc:language"/>
                            </languageTerm>
                        </language>
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
                    
                    <!-- si il existe dans les balises dc:identifier une chaine démarrant par "http:" 
                         alors on valorise needlocation à True
                         On aaura besoin dans notre mods de la balise location -->
                    <xsl:variable name="needlocation">
                        <xsl:for-each select="oai:metadata/oai_dc:dc/dc:identifier">
                            <xsl:if test="starts-with(text(),'http://')">
                                True
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    
                    <!-- A la recherche des urls notices et fulltext dans les balises dc:identifier -->
                    <xsl:if test="string($needlocation)!=''">
                        <location>
                            <xsl:for-each select="oai:metadata/oai_dc:dc/dc:identifier">
                                <xsl:if test="contains(text(),'http://') and not(contains(translate(text(),$smallcase,$uppercase),'.PDF'))">
                                    <url access="object in context">
                                        <xsl:value-of select="."/>
                                    </url>
                                </xsl:if>
                                <xsl:if test="contains(text(),'http://') and contains(translate(text(),$smallcase,$uppercase),'.PDF')">
                                    <url access="raw object">
                                        <xsl:value-of select="."/>
                                    </url>
                                </xsl:if>
                            </xsl:for-each>
                        </location>
                    </xsl:if>
                    
                    <!-- A la recherche de DOI dans les balises dc:identifier -->
                    <xsl:for-each select="oai:metadata/oai_dc:dc/dc:identifier">
                        <xsl:if test="contains(text(),'DOI:')">
                            <identifier type="DOI"><xsl:value-of select="normalize-space(substring-after(.,'DOI:'))"/></identifier>
                        </xsl:if>
                    </xsl:for-each>
                    
                    <!-- récupération du type de notice -->
                    <xsl:for-each select="oai:metadata/oai_dc:dc/dc:type">
                        <genre><xsl:value-of select="."/></genre>
                    </xsl:for-each>
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
