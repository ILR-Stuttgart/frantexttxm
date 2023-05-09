<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:txm="http://textometrie.org/1.0"
    version="2.0">
    
<!-- Converts XML-TXM to Conll format, i.e.:
    - tokenizes into sentences using both punctuation and any higher
      TEI units.
    - Retains the word ID in the MISC column.
 -->
    <xsl:variable name="sentence-end" select="'.!?'"/>
    <xsl:variable name="closing-punc" select="'»”’)]}'"/>
    <!-- Set to "yes" to export annotation -->
    <xsl:param name="include-annotation" select="'no'"/>
    
    <xsl:output method="text" encoding="UTF-8"/>
    <xsl:template match="/">
        <xsl:variable name="words-and-milestones">
            <xsl:apply-templates select="//tei:w" mode="pass1"/>
        </xsl:variable>
        <xsl:apply-templates select="$words-and-milestones" mode="pass2"/>
    </xsl:template>
    
    <xsl:template match="tei:w" mode="pass1">
        <!-- Introduced a milestone element under two conditions.
        Number 1: does not have the same parent.
        Number 2: the previous word, disregarding closing brackets and
        parentheses, is a sentence-closing punctuation mark.
        -->
        <xsl:choose>
            <xsl:when test="parent::node() != preceding::tei:w[1]/parent::node()">
                <splitme/>
            </xsl:when>
            <xsl:when test="not(contains($closing-punc, txm:form/text())) and not(contains($sentence-end, txm:form/text())) and contains($sentence-end, preceding::txm:form[not(contains($closing-punc, text()))][1]/text())">
                <splitme/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <xsl:apply-templates select="."/>
    </xsl:template>
    
    <xsl:template match="tei:w" mode="pass2">
        <!-- Column 1: ID -->
        <xsl:choose>
         <!-- Option 1 (works), count length of node lists -->
         <!-- xsl:when test="preceding::splitme">
            <xsl:value-of select="position() - count(preceding::splitme[1]/preceding::tei:w) - count(preceding::splitme)"/>
        </xsl:when -->
        <!-- Option 2 (probably more efficient): use txm:ana , type="#n" -->
        <xsl:when test="preceding::splitme[1]/preceding::txm:ana[@type='#n']">
            <xsl:value-of select="number(txm:ana[@type='#n']/text()) - number(preceding::splitme[1]/preceding::txm:ana[@type='#n'][1]/text())"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="number(txm:ana[@type='#n']/text())"/>
        </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#x0009;</xsl:text>
        <!-- Column 2: form -->
        <xsl:value-of select="txm:form/text()"/>
        <xsl:text>&#x0009;</xsl:text>
        <!-- Column 3: blank (lemma) -->
        <xsl:choose>
            <xsl:when test="$include-annotation = 'yes'">
                <xsl:value-of select="txm:ana[@type='#lemma']/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>_</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#x0009;</xsl:text>
        <!-- Column 4: blank (upos) -->
        <xsl:text>_&#x0009;</xsl:text>
        <!-- Column 5: blank (xpos) -->
        <xsl:choose>
            <xsl:when test="$include-annotation = 'yes'">
                <xsl:value-of select="txm:ana[@type='#pos']/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>_</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#x0009;</xsl:text>
        <!-- Column 6: blank (feats) -->
        <xsl:text>_&#x0009;</xsl:text>
        <!-- Column 7: blank (head) -->
        <xsl:text>_&#x0009;</xsl:text>
        <!-- Column 8: blank (deprel) -->
        <xsl:text>_&#x0009;</xsl:text>
        <!-- Column 9: blank (deps) -->
        <xsl:text>_&#x0009;</xsl:text>
        <!-- Column 10: misc -->
        <xsl:text>XmlId=</xsl:text>
        <xsl:value-of select="@id"/>
        <!-- end of line -->
        <xsl:text>&#x000a;</xsl:text>
    </xsl:template>
    
    <xsl:template match="splitme" mode="pass2">
        <!-- Add a newline -->
        <xsl:text>&#x000a;</xsl:text>
    </xsl:template>
    
    <!-- Here are the basic "copy everything" functions -->
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
</xsl:stylesheet>
