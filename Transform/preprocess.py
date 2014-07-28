# -*- coding:utf-8 -*-
# Transform given Active Display Coordinate (ADC) to Media Coordinate (MC).
# raw/pororo*.tsv -> data/pororo*.tsv
#
# @date   2014-03-30 
# @author Jin-Hwa Kim (jhkim@bi.snu.ac.kr)

import os, sys, getopt, glob, re
import numpy as np
from sets import Set
import common

# default options
verbose = False
DEBUG = True

# Get the transformation matrix for mapping Tobbi Snapshot coordinate system 
# to a unit space coordinate system.
# @param sourceCoords np.array of x, y pairs
# @param targetCoords np.array of x, y pairs
def getTransformationMatrix(sourceCoords, targetCoords):
    # AX = y; A = yX'pinv(XX')
    # Using a linear algebra library
    Q = np.dot(sourceCoords, np.transpose(sourceCoords))

    Tr = np.dot(np.dot(targetCoords, np.transpose(sourceCoords)), \
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

# Add MCx MCy to a given data.
def preprocess(source_filename, output_filename, snapshotCoords, length, delay, skip = 0):

    (path, filename, name, extension) = common.pfne(source_filename)

    idx = 0
    
    Tr = getTobbiTransformationMatrix(snapshotCoords)

    with open(source_filename, 'rU') as f, open(output_filename, 'w') as w:

        # Print a header for the output file.
        _printHeader(w)

        # Read lines.
        header = f.readline().split('\n')[0]
        wholefile = f.readlines()
        for line in wholefile:

            # parse the line
            timestamp, event, fixX, fixY, gzX, gzY = parseTobbiLine(header, line.split('\n')[0])

            # skip
            if int(timestamp) < skip :
                continue            

            # delay
            if int(timestamp) < delay :
                continue
            else :
                timestamp = int(timestamp) - delay

            # length
            if timestamp > length :
                break

            # Print
            # The number of Origin's columns is 9.
            origin = line.split('\n')[0].split('\t')[1:9]
            # try :
            w.write("{}\t{}".format(timestamp, '\t'.join(origin)))

            # Transformation
            try :
                fixation = getUnitCoord(Tr, int(fixX), int(fixY))
                w.write("\t{0:.3f}\t{1:.3f}".format(fixation[0], fixation[1]))
            except ValueError :
                fixation = ['', '']
                w.write("\t\t")
            try :
                gaze = getUnitCoord(Tr, int(gzX), int(gzY))
                w.write("\t{0:.3f}\t{1:.3f}\n".format(gaze[0], gaze[1]))
            except ValueError :
                gaze = ['', '']
                w.write("\t\t\n")

# Parse Tobbi eye-tracking data to extract the required fields.
def parseTobbiLine(header, line, delimiter = "\t"):
    header = header.replace("\xef\xbb\xbf", "").split(delimiter)
    line = line.split(delimiter)
    timestamp = line[header.index('RecordingTimestamp')]
    gazeEventType = line[header.index('GazeEventType')]
    fixationPointX = line[header.index('FixationPointX (MCSpx)')]
    fixationPointY = line[header.index('FixationPointY (MCSpx)')]
    gazePointX = line[header.index('GazePointX (ADCSpx)')]
    gazePointY = line[header.index('GazePointY (ADCSpx)')]
    return timestamp, gazeEventType, fixationPointX, fixationPointY, \
            gazePointX, gazePointY

# Print a header for a given file description.
def _printHeader(f):
    f.write("{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\n" \
        .format("RecordingTimestamp", "FixationIndex", "SaccadeIndex", \
            "GazeEventType", "GazeEventDuration", \
            "FixationPointX (ADCSpx)", "FixationPointY (ADCSpx)", \
            "GazePointX (ADCSpx)", "GazePointY (ADCSpx)", \
            "FixationPointX (MCSpx)", "FixationPointY (MCSpx)", \
            "GazePointX (MCSpx)", "GazePointY (MCSpx)"))

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
def getTobbiTransformationMatrix(snapshotCoords):
    
    # Pororo video resolution : 720 * 544
    M_SIZE = [720., 544.]
    # TV Screen resolution : 1920 * 1080
    S_size = [1920., 1080.]

    # Scaling factor for Pororo video on the screen.
    SCALING_FACTOR = (S_size[0] / (M_SIZE[0] * S_size[1] / M_SIZE[1]) - 1) / 2

    for row in snapshotCoords:
        row.append(1.)

    a = encapsulateCoords(snapshotCoords)
    b = encapsulateCoords([[-SCALING_FACTOR,0,1],[1+SCALING_FACTOR,0,1],\
                           [1+SCALING_FACTOR,1,1],[-SCALING_FACTOR,1,1]])
    Tr = getTransformationMatrix(a,b)
    
    if verbose:
        print "[00] Tr = ",
        print(Tr)
    
    return Tr

def usage():
    print "Usage: preprocess [OPTION]\n" +\
        "Transform given Active Display Coordinates (ADC) to Media Coordinates (MC).\n"+\
        "\n"+\
        "  -s, --source               Specifies source directory\n"+\
        "                             default: ./raw\n"+\
        "\n"+\
        "  -o, --output               Specifies source directory\n"+\
        "                             default: ./data\n"+\
        "\n"+\
        "  -v, --verbose              View more details\n"

def main():
    GAT = False
    # Define Filenames
    DELAY_FILENAME = "info/delay.csv" if not GAT else "info/gat.csv"
    SNAPSHOT_FILENAME = "info/snapshot.tsv"
    source = "raw/pororo_*.tsv"
    output = "data/"
    verbose = True

    try:
        opts, args = \
            getopt.getopt(sys.argv[1:], "vs:o:")

    except getopt.GetoptError:
        # print help information and exit:
        usage()
        sys.exit(2)

    for option, value in opts:

        if option == "-v":
            verbose = True

        if option in ("-s", "--source"):
            source = value

        if option in ("-o", "--output"):
            output = value

    # get file name list
    filenameList = glob.glob(source)

    snapshotCoordsList = common.readData(SNAPSHOT_FILENAME, '\t', False, verbose)
    delayList = common.readData(DELAY_FILENAME, ',', False, verbose)

    for fullname in filenameList:
        
        print "[01] Reading", fullname

        (path, filename, name, extension) = common.pfne(fullname)

        # snapshot coords
        snapshotCoords = common.findOne(name, snapshotCoordsList)
        tuples = []

        for i in range(4):
            tuples.append([float(snapshotCoords[i*2+0]), float(snapshotCoords[i*2+1])])

        length, delay, skip = [int(i) for i in common.findOne(name, delayList)]
        if verbose:
            print "delay => ", delay, "skip => ", skip, "length =>", length

        if GAT:
            _splited = re.split('s03p0\d', filename)
            output_filename = _splited[0] + 'GAT' + _splited[1]
        else:
            output_filename = filename

        # Do prepocess and store to a given output filename.
        if verbose:
            print "preprocess({}, {}, snapshotCoords, {}, {})"\
                .format(path + os.sep + filename, output + output_filename, length, delay, skip)
        
        preprocess(path + os.sep + filename, output + output_filename, tuples, length, delay, skip)

if __name__ == "__main__":
    main()
