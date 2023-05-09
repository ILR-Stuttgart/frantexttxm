FRANTEXT for TXM
================

Tom Rainsford, ILR Stuttgart, May 2023

1. Description
--------------

The files provided in this repository may be used to process XML
files downloaded from the FRANTEXT platform in the following ways:

1. The files in the `import` directory allow TXM to import FRANTEXT
XML files directly.
2. The files in the `conll` directory convert the imported XML-TXM
files to into Conll format so that they can be parsed.

IMPORTANT NOTICE: This repository does **not** contain XML files 
from FRANTEXT. A subscription to FRANTEXT is required in order to obtain
the source texts.

2. Importing into TXM
---------------------

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

3. Converting to Conll
----------------------

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

Resources
---------
FRANTEXT: [https://www.frantext.fr/](https://www.frantext.fr/)
Saxon XSLT processor: [https://www.saxonica.com](https://www.saxonica.com)
TXM: [https://txm.gitpages.huma-num.fr/textometrie/](https://txm.gitpages.huma-num.fr/textometrie/)

