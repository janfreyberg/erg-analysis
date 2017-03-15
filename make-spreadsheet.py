from cStringIO import StringIO
from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter
from pdfminer.converter import TextConverter
from pdfminer.layout import LAParams
from pdfminer.pdfpage import PDFPage
from os.path import join, basename
from os import listdir
import os
from glob import glob
import fnmatch
import csv
from datetime import datetime

currentdate = str(datetime.now().date())


def convert(fname, pages=None):
    if not pages:
        pagenums = set()
    else:
        pagenums = set(pages)

    output = StringIO()
    manager = PDFResourceManager()
    converter = TextConverter(manager, output, laparams=LAParams())
    interpreter = PDFPageInterpreter(manager, converter)

    infile = file(fname, 'rb')
    for page in PDFPage.get_pages(infile, pagenums):
        interpreter.process_page(page)
    infile.close()
    converter.close()
    text = output.getvalue()
    text = ' '.join(text.split()).lower()
    output.close
    return text


# Find files
currentfolder, _ = os.path.split(__file__)
files = glob(currentfolder.replace('analysis', 'data') + os.sep + '*.pdf')

# Extract the ID from the filename
ids = [basename(filename.split('_')[0]) for filename in files]
ids = list(set(ids))

# Initiate empty list that will become a list of dicts
sampleinfos = []

for subject in ids:
    # Empty dict
    sampleinfo = {}
    sampleinfo['id'] = subject

    if subject[0] == '0':
        sampleinfo['group'] = 'control'
    elif subject[0:4] == 'adhd':
        sampleinfo['group'] = 'adhd'
    else:
        sampleinfo['group'] = 'patient'

    # Go through both PDFs for this subject:
    for filename in fnmatch.filter(files, '*' + subject + '*'):
        # Load the pdf
        pdftext = convert(filename)

        # skip this if empty
        if 'no measurement was taken' in pdftext:
            break
            print(filename)

        # Determine what eye was used:
        if 'left eye not measured' in pdftext:
            sampleinfo['eye'] = 'right'
        elif 'right eye not measured' in pdftext:
            sampleinfo['eye'] = 'left'

        # Determine what protocol this was:
        if 'iscev' in pdftext:
            protocol = 'iscev'
        elif 'phnr' in pdftext:
            protocol = 'phnr'

        # Extract the metrics
        for wave in ['a', 'b']:
            for metric, index in [('latency', 2),
                                  ('amplitude', 4)]:
                sampleinfo[
                    ' '.join([protocol, wave, metric])
                ] = pdftext.split(wave + '-wave', 1)[1].split(' ')[index]

        # Fix issue with NM (meaning no measurement)
        sampleinfo = {key: value for key, value in sampleinfo.items()
                      if value != 'nm'}

    # Add the dict to a list:
    sampleinfos.append(sampleinfo)

# Write to a CSV file:
columnorder = ['id', 'eye', 'group',
               'iscev a latency', 'iscev a amplitude',
               'iscev b latency', 'iscev b amplitude',
               'phnr a latency', 'phnr a amplitude',
               'phnr b latency', 'phnr b amplitude']

with open(currentfolder + os.sep +
          currentdate + '-summary.csv', 'w') as csvfile:
    writer = csv.DictWriter(csvfile, columnorder,
                            lineterminator='\n')
    writer.writeheader()
    for sampleinfo in sampleinfos:
        writer.writerow(sampleinfo)
