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
# @date   2014.02.27. initial writing
# @date   2014.03.02. logic update
# @author Jin-Hwa Kim (jhkim@bi.snu.ac.kr)

import sys
import numpy as np
from sets import Set

DEBUG = True

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

    if (DEBUG): print "[02] Subtitle Parsed with",len(timings),"timestamps"

    timings.sort()
    timings = changeFormatAsTobbiTimestamp(timings)

    return timings

# Change the timestamp format as Tobbi's.
def changeFormatAsTobbiTimestamp(timings):
    if False:
        newTimings = []
        for timing in timings:
            newTimings.append(str(timing))
        return newTimings
    else:
        return timings

# Get the transformation matrix for mapping Tobbi Snapshot coordinate system 
# to a unit space coordinate system.
# @param snapshotCoords np.array of x, y pairs
# @param unitCoords np.array of x, y pairs
def getTransformationMatrix(snapshotCoords, unitCoords):
    # AX = y; A = yX'pinv(XX')
    # Using a linear algebra library
    Q = np.dot(snapshotCoords, np.transpose(snapshotCoords))
    Tr = np.dot(np.dot(unitCoords, np.transpose(snapshotCoords)), \
         np.linalg.pinv(Q))
    return Tr

# Get a transformed coordinate using a given transformation matrix.
def getUnitCoord(Tr, x, y):
    # Encapsulate x and y to a x, y pair
    coord = encapsulateCoord(x, y)

    # Matrix * matrix
    unitCoord = np.dot(Tr, coord)
    
    return unitCoord

# encapsulate to a coordinate
# It follows the linear algebra library convention.
def encapsulateCoord(x, y):
    return np.array([x, y, 1])

# encapsulate to a coordinate matrix
# It follows the linear algebra library convention.
def encapsulateCoords(listOfXYs):
    return np.transpose(np.array(listOfXYs))

# print a set of fixations with regard to timestamps.
def printFixations(tobbiFilename, timings, skip):
    idx = 0
    fixations = []
    originalFixations = []

    Tr = getTobbiTransformationMatrix()

    with open(tobbiFilename, 'rU') as f, open('fixation.out', 'w') as w:
        header = f.readline()
        wholefile = f.readlines()
        for line in wholefile:
            # skip
            if skip > 0:
                skip = skip - 1
                continue

            # parse the line
            timestamp, event, fixX, fixY = parseTobbiLine(header, line)
            #if (DEBUG): 
            #    print idx+1, len(timings), timestamp, timings[idx+1], event
            # process conditions
            if idx < len(timings):
                if int(timestamp) < int(timings[idx]):
                    pass
                else:
                    if (DEBUG): 
                        print "[03] Process", len(fixations), "fixations for", \
                            timestamp 
                    _printFixations(w, timestamp, fixations)
                    fixations = []
                    originalFixations = []
                    idx = idx + 1

                # queue a fixation coordinate
                if event == "Fixation":
                    try:
                        fixation = getUnitCoord(Tr, int(fixX), int(fixY))
                        originalFixation = [fixX, fixY]
                    except ValueError:
                        # Caution: Missing one of x, y fixation points.
                        if (DEBUG): print "[03] Missing fixation point of x:", \
                            fixX, "y:", fixY, "at", timestamp
                        # Exclude missing fixation data.
                        continue
                    try:
                        # if a given fixation already exists, it throws an error.
                        originalFixations.index(originalFixation)
                    except ValueError:
                        fixations.append(fixation)
                        originalFixations.append(originalFixation)

            # process reminders
            else:
                _printFixations(w, timestamp, fixations)

# Parse Tobbi eye-tracking data to extract the required fields.
def parseTobbiLine(header, line, delimiter = "\t"):
    header = header.split(delimiter)
    line = line.split(delimiter)
    timestamp = line[header.index('RecordingTimestamp')]
    gazeEventType = line[header.index('GazeEventType')]
    fixationPointX = line[header.index('FixationPointX (MCSpx)')]
    fixationPointY = line[header.index('FixationPointY (MCSpx)')]
    return timestamp, gazeEventType, fixationPointX, fixationPointY

# Print fixations for a given file description.
def _printFixations(f, timestamp, fixations):
    for fixation in fixations:
        fixX = fixation[0]
        fixY = fixation[1]
        f.write("{}\t{}\t{}\n".format(timestamp, fixX, fixY))

# Get the transformation matrix for Tobbi data.
def getTobbiTransformationMatrix():
    SCALING_FACTOR = 0.1716
    a = encapsulateCoords([[159,158,1],[1120,178,1],[1080,700,1],[175,686,1]])
    b = encapsulateCoords([[-SCALING_FACTOR,0,1],[1+SCALING_FACTOR,0,1],\
                           [1+SCALING_FACTOR,1,1],[-SCALING_FACTOR,1,1]])
    Tr = getTransformationMatrix(a,b)
    print "[00] Tr = ",
    print(Tr)
    return Tr

def main():
    # Define Filenames
    SUBTITLE_FILENAME = "pororo_1.smi"
    TOBBI_ET_FILENAME = "proro1-29min.tsv"

    # Check getting Timings from smi file
    timings = changeFormatAsTobbiTimestamp(getTimings(SUBTITLE_FILENAME))

    # print fixations
    printFixations(TOBBI_ET_FILENAME, timings, 0)

def debug():
    # Check the transformation matrix
    a = encapsulateCoords([[-10,-50,1],[300,-10,1],[310,290,1],[10,310,1]])
    b = encapsulateCoords([[0,0,1],[1,0,1],[1,1,1],[0,1,1]])
    Tr = getTransformationMatrix(a,b)
    ans = getUnitCoord(Tr, 150, 150)
    print "[00] ans = ",
    print(ans)

if __name__ == "__main__":
    debug()
    main()