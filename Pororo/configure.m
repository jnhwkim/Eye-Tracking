%% USAGE: add lines below on the top of a script or inside of a function.
%% %% Configure the default parameters
%% configure;

%% Default Parameters
SECOND_UNIT = 1000;
UNIT = 30; VERBOSE = true; FRAME_PER_SEC = 10;

TRAIN_DATA_SIZE = 1000;
INTERVAL = 4;
WINDOW_SIZE = 2;
SKIP = 1;

%% Video Inforamtion
if ispc
    PATH_TO_PORORO3_VIDEO = 'd:\Movies\pororo_1.avi';
    PATH_TO_PORORO2_VIDEO = 'd:\Movies\Pororo_ENGLISH2_1.avi';
else
    PATH_TO_PORORO3_VIDEO = '/Users/Calvin/Documents/Projects/Pororo/Movies/pororo_3_1.avi';
    PATH_TO_PORORO2_VIDEO = '/Users/Calvin/Documents/Projects/Pororo/Movies/Pororo_2_1.avi';
end

%% Reading the whole video is very slow. 
if ~exist('M', 'var')
    disp('Reading a video..');
    M = VideoReader(PATH_TO_PORORO3_VIDEO);
    disp('doen.');
else
    disp('Reuse movie variable.');
end