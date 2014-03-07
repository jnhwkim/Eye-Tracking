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
    Tr = np.dot(np.dot(unitCoords, np.transpose(snapshotCoords)), np.linalg.pinv(Q))
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
    return np.array([x, y])

# encapsulate to a coordinate matrix
# It follows the linear algebra library convention.
def encapsulateCoords(listOfXYs):
    return np.transpose(np.array(listOfXYs))

# print a set of fixations with regard to timestamps.
def printFixations(tobbiFilename, timings, skip):
    idx = 0
    targets = []

    with open(tobbiFilename, 'rU') as f:
        with open('fixation.out', 'w') as w:
            wholefile = f.readlines()
            for line in wholefile:
                # skip
                if skip > 0:
                    skip = skip - 1
                    continue

                # parse the line
                timestamp, fixX, fixY = parseTobbiLine(line)

                # process conditions
                if timestamp < timings[idx+1]:
                    targets.append(line)
                else:
                    fixations = grapFixations(targets)
                    _printFixations(w, timestamp, fixations)
                    targets = []

# Parse Tobbi eye-tracking data to extract the required fields.
def parseTobbiLine(line):
    # @TODO
    pass

# Print fixations for a given file description.
def _printFixations(f, timestamp, fixations):
    for fixation in fixations:
        fixX = fixation[0]
        fixY = fixation[1]
        f.write("{}\t{}\t".format(timestamp, fixX, fixY))

def main():
    pass

def debug():
    # Check the transformation matrix
    a = encapsulateCoords([[-10,-50],[300,-10],[310,290],[10,310]])
    b = encapsulateCoords([[0,0],[1,0],[1,1],[0,1]])
    Tr = getTransformationMatrix(a,b)
    ans = getUnitCoord(Tr, 150, 150)
    print(ans)

    # Define Filenames
    SUBTITLE_FILENAME = "pororo_1.smi"
    TOBBI_ET_FILENAME = "proro1-29min.tsv"

    # Check getting Timings from smi file
    timings = changeFormatAsTobbiTimestamp(getTimings(SUBTITLE_FILENAME))
    print(timings)

    # print fixations
    printFixations(TOBBI_ET_FILENAME, timings, 0)

if __name__ == "__main__":
    debug()
    main()