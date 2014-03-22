
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
def printFixations(tobbiFilename, timings, prior, post, skip):
    idx = 0
    fixations = []
    originalFixations = []
    timestamps = []

    Tr = getTobbiTransformationMatrix()

    with open(tobbiFilename, 'rU') as f, open('fixation.out', 'w') as w:
        # Print a header for the output file.
        _printHeader(w)

        header = f.readline()
        wholefile = f.readlines()
        for line in wholefile:
            
            # parse the line
            timestamp, event, fixX, fixY = parseTobbiLine(header, line)

            # skip
            if int(timestamp) < skip :
                continue
            else :
                timestamp = int(timestamp) - skip

            # process conditions
            if idx < len(timings):
                # Check if it's within interval.
                diff = int(timestamp) - int(timings[idx])
                if diff > post and 0 < len(fixations):
                    if (DEBUG): 
                        print "[03] Process", len(fixations), "fixations for", \
                            timings[idx] 
                    _printFixations(w, timings[idx], timestamps, \
                        fixations, originalFixations)
                    fixations = []
                    originalFixations = []
                    timestamps = []
                    idx = idx + 1

                # Queue a fixation coordinate
                if diff > prior and event == "Fixation":
                    try:
                        fixation = getUnitCoord(Tr, int(fixX), int(fixY))
                        originalFixation = [fixX, fixY]
                    except ValueError:
                        # Caution: Missing one of x, y fixation points.
                        if (DEBUG): print "[03] Missing fixation point of x:", \
                            fixX, "y:", fixY, "at", timestamp
                        # Exclude missing fixation data.
                        continue

                    if 0 == len(originalFixations) or \
                        originalFixations[-1] != [fixX, fixY]:
                        fixations.append(fixation)
                        originalFixations.append(originalFixation)
                        timestamps.append(timestamp)

            # process reminders
            else:
                _printFixations(w, timings[idx], timestamps, \
                    fixations, originalFixations)

# Parse Tobbi eye-tracking data to extract the required fields.
def parseTobbiLine(header, line, delimiter = "\t"):
    header = header.split(delimiter)
    line = line.split(delimiter)
    timestamp = line[header.index('RecordingTimestamp')]
    gazeEventType = line[header.index('GazeEventType')]
    fixationPointX = line[header.index('FixationPointX (MCSpx)')]
    fixationPointY = line[header.index('FixationPointY (MCSpx)')]
    return timestamp, gazeEventType, fixationPointX, fixationPointY

# Print a header for a given file description.
def _printHeader(f):
    f.write("{}\t{}\t{}\t{}\t{}\t{}\n" \
            .format("Time", "Record", "Normalized_X", "Normalized_Y", "X", "Y"))

# Print fixations for a given file description.
def _printFixations(f, t_ts, o_ts, fixations, originalFixations):
    for i in range(len(fixations)):
        fixX = fixations[i][0]
        fixY = fixations[i][1]
        oFixX = originalFixations[i][0]
        oFixY = originalFixations[i][1]
        f.write("{}\t{}\t{}\t{}\t{}\t{}\n" \
            .format(t_ts, o_ts[i], fixX, fixY, oFixX, oFixY))

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

def printList(f, list):
    for e in list:
        f.write("{}\n".format(e))

def main():
    # Define Filenames
    SUBTITLE_FILENAME = "data/pororo_1.smi"
    TOBBI_ET_FILENAME = "data/proro1-29min.tsv"

    # Check getting Timings from smi file
    timings = changeFormatAsTobbiTimestamp(getTimings(SUBTITLE_FILENAME))

    # Print timings to a file.
    with open('timings.txt', 'w') as f:
        printList(f, timings)

    # print fixations with interval prior=1s, post=1s, skip=2530ms.
    printFixations(TOBBI_ET_FILENAME, timings, -1000, 1000, 2530)

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