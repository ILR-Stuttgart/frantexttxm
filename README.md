FRANTEXT for TXM
================

Tom Rainsford, ILR Stuttgart, May 2023

# Description

The files provided in this repository may be used to process XML
files downloaded from the FRANTEXT platform in the following ways:

1. The files in the `import` directory allow TXM to import FRANTEXT
XML files directly.
2. The files in the `conll` directory convert the imported XML-TXM
files to into Conll format so that they can be parsed.

IMPORTANT NOTICE: This repository does **not** contain XML files 
from FRANTEXT. A subscription to FRANTEXT is required in order to obtain
the source texts.

# Importing into TXM

1. Download and install TXM version 0.8.2
2. Create a corpus in FRANTEXT containing the texts that you want to
include in your corpus and download the XML files.
3. Export the metadata for your corpus from FRANTEXT as a CSV file
using the "Exporter" function.
4. Create a new directory and copy the following files into it:
    + the XML files downloaded from FRANTEXT
    + the `.csv` file containing the metadata, which must be renamed as
    `metadata.csv`.
        + Ensure also that you remove the `.xml` suffix from the `id`
        column.
    + the `xsl` directory contained in `import` in this repository.
5. Launch TXM and select `Import > XML-XTZ + CSV`.
6. Select the directory you created in step 4 and launch the importer.

## An important note on tokenization

The original FRANTEXT tokenization is based on lexical units, and
so FRANTEXT tokens may contain spaces, e.g. *parce que*, *Louis XIV*,
or even *au fur et à mesure*.

By default, the import XSL eliminates all tokens containing whitespace,
modifying the `pos` and `lemma` tags as follows:
+ the single `pos` tag is copied to all tokens with an asterisk
appended to the `pos` tag of all but the final word.
    + For example, the token `parce que` tagged `CS` becomes two tokens:
    `parce` tagged `CS*` and `que` tagged `CS`.
+ where possible, the `lemma` tag is also retokenized.
    + For example, the token `parce que`, lemma `parce que` becomes two
    tokens: the token `parce` with lemma `parce` and the token `que`
    with lemma `que`.
+ where the `lemma` tag cannot be redistributed across the new tokens,
the whitespace is replaced by a full stop and the tag is copied to
all new tokens. As with the `pos` tag, an asterisk is appended to the
lemma tag on all but the final token.
    + For example, the token `pource que`, lemma `pour ce que` becomes
    two tokens, a token `pource`, lemma `pour.ce.que*` and a second 
    token `que`, lemma `pour.ce.que`.

If you wish to retain the original FRANTEXT tokenization, simply
modify the file
[import/xsl/2-front/xml-frantext_to_xml-txm-xtz.xsl](https://github.com/ILR-Stuttgart/frantexttxm/blob/main/import/xsl/2-front/xml-frantext_to_xml-txm-xtz.xsl)
before importing.

Replace the line:
```
<xsl:param name="retokenize" select="'yes'"/>
```
with the line
```
<xsl:param name="retokenize" select="'no'"/>
```

# Converting to Conll

When the texts are imported, TXM creates a new XML-TXM file containing
unique identifiers for each token. These can be found in 
`TXM-0.8.2/corpora/<NAME OF YOUR CORPUS>/txm/<NAME OF YOUR CORPUS>`.

To convert these files to Conll format while *retaining* the unique
identifiers, use the SAXON parser with the `xml-txm_to_conll.xsl`
stylesheet:

```
java -cp <PATH>/frantexttxm/saxonb.jar net.sf.saxon.Transform <XML-TXM FILE> <PATH>/frantexttxm/conll/xml-txm_to_conll.xsl > <OUTPUT_FILE>
```

If you want the Conll file to contain the Frantext lemmas and pos tags, use
the following command:

```
java -cp <PATH>/frantexttxm/saxonb.jar net.sf.saxon.Transform <XML-TXM FILE> <PATH>/frantexttxm/conll/xml-txm_to_conll.xsl include-annotation=yes > <OUTPUT_FILE>
```

# Resources

FRANTEXT: [https://www.frantext.fr/](https://www.frantext.fr/)
Saxon XSLT processor: [https://www.saxonica.com](https://www.saxonica.com)
TXM: [https://txm.gitpages.huma-num.fr/textometrie/](https://txm.gitpages.huma-num.fr/textometrie/)

