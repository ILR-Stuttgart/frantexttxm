<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:txm="http://textometrie.org/1.0" exclude-result-prefixes="tei" version="2.0"
    xmlns:x="http://www.atilf.fr/allegro">

    <xsl:output indent="yes"/>

    <xsl:template match="/*">
        <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:txm="http://textometrie.org/1.0">
            <xsl:apply-templates/>
        </TEI>
    </xsl:template>

    <xsl:template match="tei:teiHeader">
        <xsl:copy/>
        <!--Leaves the element, removes the contents which is not correctly parsed by TXM. -->
    </xsl:template>
    
    <xsl:template match="x:wf">
        <!-- Turns FRANTEXT x:wf into a correct tei:w. Eliminates "whitespace words" from FT source (bug in source) -->
        <xsl:if test="normalize-space(@word) != ''">
            <xsl:element name="w" namespace="http://www.tei-c.org/ns/1.0">
                <!-- Adds a ref attribute using pb and lb milestones -->
                <xsl:attribute name="ref">
                    <xsl:value-of select="substring(base-uri(), string-length(base-uri()) - 7, 4)"/>
                    <xsl:text>, p. </xsl:text>
                    <xsl:value-of select="preceding::tei:pb[1]/@n"/>
                </xsl:attribute>
                <!-- Copies the pos and lemma attribute nodes -->
                <xsl:apply-templates select="@pos | @lemma"/>
                <!-- Turns the @word node into text -->
                <xsl:value-of select="@word"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- Copy everything templates -->

    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:copy/>
    </xsl:template>

</xsl:stylesheet>
