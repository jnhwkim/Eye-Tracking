% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: Sep 25 2014
%
% Generate training data of animated-gif.

addpath('../');

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

if ~exist('movie', 'var')
    disp('Reading a video..');
    movie = VideoReader(PATH_TO_PORORO3_VIDEO);
    disp('doen.');
else
    disp('Reuse movie variable.');
end

%% Main
if ~exist('../img/animated_gif/train', 'dir')
    mkdir('../img/animated_gif/train');
end

order = 1;
for j = 1 : TRAIN_DATA_SIZE
   %% Using parameters
    start_ts = (SKIP + (j-1) * INTERVAL) * 1000; 
    end_ts = (SKIP + (j-1) * INTERVAL + WINDOW_SIZE) * 1000;
    if VERBOSE
        fprintf('\t%.3f => %.3f\n', start_ts, end_ts);
    end
    frames = get_interval_frame(movie, start_ts, end_ts, FRAME_PER_SEC);
    out = strcat('../img/animated_gif/train/T_', ...
                  int2str(j), '.gif');

   %% Generate animated-gifs
   preprocessor = @(im) (imresize(im, 0.5));
   gen_anigif(frames, FRAME_PER_SEC, out, preprocessor);
end