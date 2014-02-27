# -*- coding:utf-8 -*-
#
# KidsVideo
# Extract fixation points from eye-tracking exported data
# with regard to timestamps of subtitle information.
#
#          * * * <- fixations used
# -------+-------+-------
#        t <- target timestamp
#
# @date   2014.02.27.
# @author Jin-Hwa Kim (jhkim@bi.snu.ac.kr)

import sys

# Get timestamps from a given SMI subtitle file.
# from capture.py by Seungyeon Kim (sykim@bi.snu.ac.kr)
def getTimings( inFile ):

    timings = []
    file = open( inFile, "r" )
    ignore=False
    found=0
    to_find="&nbsp"
    wholefile = file.readlines()

    for line in wholefile:

        line = line.strip().lower()

        if line.startswith("<sync"):
          if not to_find in line:
            found=1
            ignore=True
            prefix, data = line.split("=",1)
            timestamp, postfix = data.split(">",1)

            try:
                timestamp = int(timestamp)
                timings.append(timestamp)

            except ValueError:
                print "[EE] Cannot parse '",timestamp,"'. ignoring this timestamp"

    print "[02] Subtitle Parsed with",len(timings),"timestamps"

    timings.sort()
    return timings

# Get the transformation matrix for mapping Tobbi Snapshot coordinate system 
# to a unit space coordinate system.
def getTransformationMatrix(snapshotCoords, unitCoords):
    pass

# Get a transformed coordinate using a given transformation matrix.
def getUnitCoord(Tr, x, y):
    pass

# print a set of fixations with regard to timestamps.
def printFixations(etFile, timings, skip):
    with open(etFile, 'rU') as f:
        pass









# Gets a corpus string from corpus filename.
def getCorpusStringFromFile(filename):
    with open(filename, 'rU') as f:
        corpusString = f.read()
        return corpusString

FA_DATA_FILE = "jhkim_corners_FA_20140221.txt"
FA_IDX_FILE = "jhkim_corners_FA_20140221.csv"
ET_DATA_FILE = "jhkim_corners_ET_20140221.tsv"

# Skip headers in data files
def skipHeaders(fad_f, fai_f, etd_f):
    fad_f.readline()
    fad_f.readline()
    fad_f.readline()
    etd_f.readline()

# Print as the sync file.
def printSync(idx, fad, etd, out):
    #print idx, etd[2], fad[1], fad[2], fad[3].split('\n')[0], etd[3], etd[4]
    out.write("{}\t{}\t{}\t{}\t{}\t{}\t{}\n".format(\
        idx, etd[2], fad[1], fad[2], fad[3].split('\n')[0], etd[3], etd[4]))

# Threshold is 10 ms.
EPSILON = 10

# Time which the face data is delayed (approx 9 sec).
ET_DELAY = 300

# CERT Time Sync Ratio ?!
FA_LEN = 28.766571
ET_LEN = 75.033 - (ET_DELAY / 1000)
SYNC_RATIO = ET_LEN / FA_LEN

# Skip
SKIP = 250

# Limit the amount of output.
LIMIT = 250

# Output file describer.
out = open('skip250.300.sync.tsv', 'w')
out.write('Idx\tTime\tYaw\tPitch\tRoll\tX\tY\n')

# Extract sync file.
with open(FA_DATA_FILE, 'rU') as fad_f:
    with open(FA_IDX_FILE, 'rU') as fai_f:
        with open(ET_DATA_FILE, 'rU') as etd_f:
            skipHeaders(fad_f, fai_f, etd_f)
            fad_line = fad_f.readline()
            #print fad_line
            fai_line = fai_f.readline()
            #print fai_line
            etd_line = etd_f.readline()
            #print etd_line

            i = 0
            while i < SKIP:
                fad_line = fad_f.readline()
                fai_line = fai_f.readline()
                etd_line = etd_f.readline()
                i = i + 1
            
            i = 0    
            while i < LIMIT and fad_line and fai_line and etd_line:
                fa_data = fad_line.split('\t')
                fa_time = (float)(fai_line.split('\t')[0]) * 1000 * SYNC_RATIO
                et_data = etd_line.split('\t')
                et_time = (float)(et_data[2])

                #print fa_time, et_time

                if abs(fa_time + ET_DELAY - et_time) < EPSILON and et_data[3] and fa_data[1] != 'NaN':
                    i = i + 1
                    #print i, fa_time, fa_data, et_data
                    printSync(i, fa_data, et_data, out)
                    
                    # move to next line
                    fad_line = fad_f.readline()
                    fai_line = fai_f.readline()
                    etd_line = etd_f.readline()
                else:
                    if fa_time + ET_DELAY < et_time:
                        fad_line = fad_f.readline()
                        fai_line = fai_f.readline()
                    else:
                        etd_line = etd_f.readline()
            
out.close()
            
            
            
