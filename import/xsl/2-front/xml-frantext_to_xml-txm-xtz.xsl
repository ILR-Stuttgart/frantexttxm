<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:txm="http://textometrie.org/1.0" exclude-result-prefixes="tei" version="2.0"
    xmlns:x="http://www.atilf.fr/allegro">

    <xsl:output indent="yes"/>
    <!-- The parameter below tells the XSL whether to retokenize the
    "tokens with spaces" that Frantext insists on including.
    Set to "yes" to enable retokenization. -->
    <xsl:param name="retokenize" select="'yes'"/>

    <xsl:template match="/*">
        <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:txm="http://textometrie.org/1.0">
            <xsl:choose>
                <xsl:when test="$retokenize='yes'">
                    <xsl:apply-templates mode="retokenize"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
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
    
    <xsl:template match="x:wf" mode="retokenize">
        <!-- Splits FRANTEXT x:wf according to whitespace -->
        <!-- Collect data in variables before for loop -->
        <xsl:variable name="tokens" select="tokenize(normalize-space(@word), '\s+')"/>
        <!-- Regroup anything + le or + ledit in the lemma -->
        <xsl:variable name="lemma">
            <xsl:choose>
                <xsl:when test="@pos='P+D'">
                    <xsl:value-of select="replace(replace(@lemma, '\sle$', '.le'), '\sledit$', '.ledit')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@lemma"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Tokenize the lemma attribute -->
        <xsl:variable name="lemmas" select="tokenize(normalize-space($lemma), '\s+')"/>
        <!-- Store node as a variable before iterating strings -->
        <xsl:variable name="xwf" select="."/>
        <!-- Iterate over tokens -->
        <xsl:for-each select="$tokens">
            <xsl:element name="w" namespace="http://www.tei-c.org/ns/1.0">
                <!-- Adds a ref attribute using pb and lb milestones -->
                <xsl:attribute name="ref">
                    <xsl:value-of select="substring(base-uri($xwf), string-length(base-uri($xwf)) - 7, 4)"/>
                    <xsl:text>, p. </xsl:text>
                    <xsl:value-of select="$xwf/preceding::tei:pb[1]/@n"/>
                </xsl:attribute>
                <!-- Add the pos attribute with a supplementary * if it
                isn't the last token -->
                <xsl:attribute name="pos">
                    <xsl:value-of select="$xwf/@pos"/>
                    <xsl:if test="position() &lt; count($tokens)">
                        <xsl:text>*</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                <!-- Create lemma attribute -->
                <xsl:attribute name="lemma">
                    <!-- Store position of token in list -->
                    <xsl:variable name="position" select="position()"/>
                    <xsl:choose>
                        <!-- First case: the lemma list is the same
                        length as the tokens list. -->
                        <xsl:when test="count($tokens) = count($lemmas)">
                            <xsl:value-of select="$lemmas[$position]"/>
                        </xsl:when>
                        <!-- Alternate: mismatched lemma and token lengths -->
                        <xsl:otherwise>
                            <!-- Use dot and repeat lemma for all tokens.
                            Add a star sign for non-final lemmas. -->
                            <xsl:value-of select="string-join($lemmas, '.')"/>
                            <xsl:if test="position() &lt; count($tokens)">
                                <xsl:text>*</xsl:text>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <!-- Add value of element node (the word) -->
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>       
    </xsl:template>

    <!-- Copy everything templates -->

    <xsl:template match="*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="text()" mode="#all">
        <xsl:copy/>
    </xsl:template>

</xsl:stylesheet>
