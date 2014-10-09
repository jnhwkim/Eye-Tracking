% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: Sep 25 2014
%
% Generate training data of animated-gif.

%% Add path to referene
addpath('../');

%% Configure the default parameters
configure;

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
    frames = get_interval_frame(M, start_ts, end_ts, FRAME_PER_SEC);
    out = strcat('../img/animated_gif/train/T_', ...
                  int2str(j), '.gif');

   %% Generate animated-gifs
   preprocessor = @(im) (imresize(im, 0.5));
   gen_anigif(frames, FRAME_PER_SEC, out, preprocessor);
end