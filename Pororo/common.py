# Common Utils

# @date   2014.03.30.
# @author Jin-Hwa Kim (jhkim@bi.snu.ac.kr)

import os

# Get the data from a given file.
def readData(filename, delimiter = '\t', header = False, verbose = False):
    data = []
    with open(filename, 'rU') as f:
        header = f.readline()
        if header == True:
            data.append(header)
        wholefile = f.readlines()
        for line in wholefile:
            data.append(line.split('\n')[0].split(delimiter))

    if verbose :
        print "[00] readData =>", data

    return data

def findOne(value, data):

    for row in data:
        if row[0] == value:
            return row[1:]

    print "Not found", value, "!"
    print data
    sys.exit(1)

def printList(f, list):
    for e in list:
        f.write("{}\n".format(e))

def pfne(fullname):
    (path, filename) = fullname.rsplit('/', 1)
    (name, extension) = filename.rsplit(".", 1)
    return path, filename, name, extension