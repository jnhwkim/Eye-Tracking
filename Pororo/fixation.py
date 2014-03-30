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

import sys, os
import numpy as np
from sets import Set
import common

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

# print a set of fixations with regard to timestamps.
def printFixations(source_filename, timings, prior, post, skip):
    idx = 0
    fixations = []
    originalFixations = []
    timestamps = []

    (path, filename, name, extension) = common.pfne(source_filename)

    with open(source_filename, 'rU') as f, \
         open(path + os.sep + name + ".fix", 'w') as w:
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
                    _printFixations(w, timings[idx], timestamps, fixations)
                    fixations = []
                    originalFixations = []
                    timestamps = []
                    idx = idx + 1

                # Queue a fixation coordinate
                if diff > prior and event == "Fixation":
                    try:
                        fixation = [fixX, fixY]
                    except ValueError:
                        # Caution: Missing one of x, y fixation points.
                        if (DEBUG): print "[03] Missing fixation point of x:", \
                            fixX, "y:", fixY, "at", timestamp
                        # Exclude missing fixation data.
                        continue

                    if 0 == len(fixations) or \
                        fixations[-1] != fixation:
                        fixations.append(fixation)
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
    f.write("{}\t{}\t{}\t{}\n" \
            .format("Time", "Record", "X", "Y"))

# Print fixations for a given file description.
def _printFixations(f, t_ts, o_ts, fixations):
    for i in range(len(fixations)):
        fixX = fixations[i][0]
        fixY = fixations[i][1]
        f.write("{}\t{}\t{}\t{}\n" \
            .format(t_ts, o_ts[i], fixX, fixY))

def printList(f, list):
    for e in list:
        f.write("{}\n".format(e))

def main():
    # Define Filenames
    SUBTITLE_FILENAME = "raw/pororo_1.smi"
    TOBBI_ET_FILENAME = "data/pororo_s03p01_kwon.tsv"

    # Check getting Timings from smi file
    timings = changeFormatAsTobbiTimestamp(getTimings(SUBTITLE_FILENAME))

    # Print timings to a file.
    with open('timings.txt', 'w') as f:
        printList(f, timings)

    # print fixations with interval prior=1s, post=1s, skip=2530ms.
    printFixations(TOBBI_ET_FILENAME, timings, -1000, 1000, 0)

if __name__ == "__main__":
    main()