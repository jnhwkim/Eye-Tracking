#!/usr/bin/env python
import sys, os, getopt
import pymedia.muxer as muxer
import pymedia.video.vcodec as vcodec
import pygame
import glob

# ----------------------------------------------------------------------------------
# Dump video files into the BMP images in the directory specified
#
#                                               Seungyeon Kim
#                                               (sykim@bi.snu.ac.kr)
#
# based on the tutorial http://pymedia.org/tut/src/dump_video.py.html

def getVideoFileList( directory ):
    return glob.glob(directory+"/*.avi")

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

def dumpVideo( inFile, outFilePattern, timings, width, height ):

    dm= muxer.Demuxer( inFile.split( "." )[ -1 ] )

    f= open( inFile, "rb" )
    s= f.read( 4000000 )
    r= dm.parse( s )

    v= filter( lambda x: x[ "type" ]== muxer.CODEC_TYPE_VIDEO, dm.streams )

    if len( v )== 0:
        raise "[EE] There is no video stream in a file %s" % inFile

    v_id= v[ 0 ][ "index" ]
    #print "Assume video stream at %d index: " % v_id
    c= vcodec.Decoder( dm.streams[ v_id ] )
    fps = float(c.getParams()["frame_rate"]) / \
          float(c.getParams()["frame_rate_base"])

    print "[03] Detected frame per second:",fps

    mspf = 1.0 / fps * 1000.0
    print "[03] Detected micro second per frame:",mspf

    count= 0
    drop_count = 0
    current_frame = 0
    previous_image = None

    while len( s ) > 0:

        for fr in r:

            if fr[ 0 ]== v_id:

                d= c.decode( fr[ 1 ] )
                current_frame += 1
                msec = current_frame * mspf

                # Save file as RGB BMP
                if d:

                    if len(timings) > 0 and abs(timings[0] - msec) < mspf :

                        # convert format RGB
                        dd= d.convert( 2 )
                        image= pygame.image.fromstring( dd.data, dd.size, "RGB" )

                        if (width != -1 and height != -1) :
                            image = pygame.transform.scale( image, (width,height) )

                        # store it for delayed frames
                        previous_image = image

                        pygame.image.save( image, outFilePattern % timings.pop(0) )
                        count += 1
                        sys.stdout.write(".")
                        sys.stdout.flush()

                    else :
                        if len(timings) > 0 and (msec - timings[0]) > 3 * mspf :
                            drop_count += 1
                            timings.pop(0)

                # the case when there's no frame
                else :
                    if len(timings) >0 and abs(timings[0] - msec) < mspf :

                        if( previous_image ) :
                            pygame.image.save( previous_image, outFilePattern % timings.pop(0) )
                            count += 1
                        else :
                            drop_count += 1
                            timings.pop(0)

        s= f.read( 4000000 )
        r= dm.parse( s )

    print ""
    print "[04] Total",count,"captured in",current_frame,"frames"

    if (drop_count + len(timings) > 0 ) :
        print "[EE] Lost",drop_count+len(timings),"frames"

def usage():
    print "Usage: capture [OPTION]\n" +\
        "Capture directory's .avi files with subtitle timing information\n"+\
        "Image is saved in bmp format\n"+\
        "Subtitle file name must be the same with the video file\n"+\
        "Only supports .smi file\n"+\
        "\n"+\
        "  -d, --directory            Specifies target directory\n"+\
        "                             default: . (current directory)\n"+\
        "\n"+\
        "  -h, --height               Specifies image height\n"+\
        "                             default: Don't change\n"+\
        "\n"+\
        "  -w, --width                Specifies image width\n"+\
        "                             default: Don't change\n"+\
        "\n"+\
        "  -v, --verbose              View more details\n"

def main():

    try:
        opts, args = \
            getopt.getopt(sys.argv[1:], "vd:w:h:")

    except getopt.GetoptError:
        # print help information and exit:
        usage()
        sys.exit(2)

    # default options
    directory = "."
    width = -1
    height = -1
    verbose = False

    for option, value in opts:

        if option == "-v":
            verbose = True

        if option in ("-d", "--directory"):
            directory = value

        if option in ("-w", "--width"):
            width = int(value)

        if option in ("-h", "--height"):
            height = int(value)

    # get file name list
    videoFilenameList = getVideoFileList(directory)

    if(width != -1 and height != -1) :
        print "[00] Using custom resolution",str(width)+"x"+str(height)
    else :
        print "[00] Using default resolution"

    for fullname in videoFilenameList:
        
        print "[01] Capturing",fullname

        (path, filename) = fullname.rsplit("\\",1)
        (name, extension) = filename.rsplit(".",1)
        
        sys.exit

        smiFilename = path+"/"+name + ".smi"
        timings = getTimings( smiFilename )

        # make directory
        if not os.path.isdir(path+"/"+name+"/"):
            os.mkdir(path+"/"+name+"/")

        pattern = path+"/"+name+"/"+name+"_%d.bmp"
        dumpVideo( fullname, pattern, timings, width, height)

if __name__ == "__main__":
    main()
