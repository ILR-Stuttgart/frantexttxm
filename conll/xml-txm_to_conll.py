#!/usr/bin/python3
########################################################################
# Reimplementation in Python of xml-txm_to_conll.xsl
# TMR, 25 October 2024
########################################################################

import argparse, re, xml.parsers.expat

SENTENCE_END = '.!?'
CLOSING_PNC = "'»”’)]}"
NEW_WORD = {'form': '', 'pos': '', 'lemma': '', 'xmlid': '', 'ancestors': []}

class MyParser(): # BaseClass
    
    def __init__(self):
        self.xmlparser = xml.parsers.expat.ParserCreate()
        self.xmlparser.StartElementHandler = self.start_element_handler
        self.xmlparser.EndElementHandler = self.end_element_handler
        self.xmlparser.CharacterDataHandler = self.character_data_handler
        self.ancestors = []
        self.words = []
        self.word = NEW_WORD.copy()
        self.is_form = False
        self.is_pos = False
        self.is_lemma = False
        self.node_i = 1

    def character_data_handler(self, data):
        if self.is_form:
            self.word['form'] += data
        elif self.is_pos:
            self.word['pos'] += data
        elif self.is_lemma:
            self.word['lemma'] += data
    
    def start_element_handler(self, name, attributes):
        self.ancestors.append(name + '_' + str(self.node_i))
        self.node_i += 1
        if name == 'txm:form':
            self.is_form = True
        elif name == 'txm:ana' and attributes.get('type', '') == '#pos':
            self.is_pos = True
        elif name == 'txm:ana' and attributes.get('type', '') == '#lemma':
            self.is_lemma = True
        elif name == 'w':
            self.word['xmlid'] = attributes.get('id', '')

    def end_element_handler(self, name):
        self.ancestors.pop(-1)
        if name == 'txm:form':
            self.is_form = False
        elif name == 'txm:ana':
            self.is_pos, self.is_lemma = False, False
        elif name == 'w':
            self.word['ancestors'] = self.ancestors[:]
            self.words.append(self.word)
            self.word = NEW_WORD.copy()

def main(xml='', outfile='', includeannotation=False):
    
    def newsent():
        nonlocal fconllu, i
        fconllu.write('\n')
        i = 1
    
    if not outfile: outfile = xml[:-4] + '.conllu'
    parser = MyParser()
    i, last_word = 0, parser.word.copy()
    with open(xml, 'r', encoding='utf-8') as fxml, open(outfile, 'w', encoding='utf-8') as fconllu:
        for line in fxml:
            parser.xmlparser.Parse(line)
            for word in parser.words:
                # Increment i
                i += 1
                # New sentence if different parent
                if last_word['ancestors'] != word['ancestors']:
                    newsent()
                # New sentence if word is not closing pnc and last word sentence_end
                elif word['form'] not in CLOSING_PNC and last_word['form'] in SENTENCE_END:
                    newsent()
                # Write word
                if includeannotation:
                    s = f'{str(i)}\t{word["form"]}\t{word["lemma"]}\t_\t{word["pos"]}\t_\t_\t_\t_\tXmlId={word["xmlid"]}\n'
                else:
                    s = f'{str(i)}\t{word["form"]}\t_\t_\t_\t_\t_\t_\t_\tXmlId={word["xmlid"]}\n'
                fconllu.write(s)
                # word become last_word unless it's CLOSING_PNC
                if not word['form'] in CLOSING_PNC:
                    last_word = word
            # Wipe the stored list of words
            parser.words = []
        
if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        description = \
        'Converts XML-TXM file to Conll-U, retaining word IDs.'
    )
    parser.add_argument('xml', type=str, help='XML input file.')
    parser.add_argument('--includeannotation', action='store_true', help='Copy annotation.')
    parser.add_argument('--outfile', help='Output file.', type=str, default='')
    kwargs = vars(parser.parse_args())
    #print(kwargs)
    main(**kwargs)


