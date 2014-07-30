% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: July 30 2014
%
% Generate three type of animated-gif, which are 
% 1) long fixation sequences *
% 2) non-fixation sequences
% 3) control sequences from the other similar movie.

function gen_long_seq

    %% Switch the function is here.
    PERIOD_TYPE = 'S'; % Type can be L or S.
    
    %% The period getter selection
    if 'L' == PERIOD_TYPE
        periodGetter = @get_long; % get long fixation period table.
        disp('*** gen_long_seq ***');
    elseif 'S' == PERIOD_TYPE
        periodGetter = @get_short; % get long fixation period table.
        disp('*** gen_short_seq ***');
    end

    %% Constants
    NUM_FIX_SEQ = 8;
    if 'L' == PERIOD_TYPE
        THRESHOLD_INIT = 2000;
        THRESHOLD_STEP = 200;
    elseif 'S' == PERIOD_TYPE
        THRESHOLD_INIT = 150;
        THRESHOLD_STEP = -10;
    end
    SPAN_LENGTH = 3000;
    SPANING = true;
    UNIT = 30;
    VERBOSE = true;
    FRAME_PER_SEC = 10;
    % Notice that this script expands to include the second part of recordings.
    % refer to line 42.
    filenames = dir('data/pororo_s03p01_*.tsv');
    
    %% Video Inforamtion
    if ispc
        PATH_TO_PORORO3_VIDEO = 'd:\Movies\pororo_1.avi';
    else
        PATH_TO_PORORO3_VIDEO = '/Users/calvin/Desktop/Pororo/pororo_1.avi';
    end
    if ~exist('M_1', 'var')
        M_1 = VideoReader(PATH_TO_PORORO3_VIDEO);
    end
    
    %% Main
    for i = 1 : size(filenames, 1)
        filename = strcat('data/', strrep(filenames(i).name, 's03p01', 's03p0*'));
        count = -1;
        threshold = THRESHOLD_INIT + THRESHOLD_STEP;
        while count < NUM_FIX_SEQ && threshold > 0
            threshold = threshold - THRESHOLD_STEP;
            period_table = periodGetter(dir(filename), threshold, 1, UNIT, true);
            period_table = uint32(period_table * 1000 / UNIT);
            count = size(period_table, 1);
            if VERBOSE
                disp(strcat('threshold = ', int2str(threshold), ', count = ', int2str(count)));
            end
        end
        if threshold <= 0
            disp('Further process is not valid!');
        end
        
        filename_split = strsplit(filenames(i).name, '.');
        label_split = strsplit(filename_split{1}, '_');
        participant_id = label_split{3};

        if VERBOSE
            fprintf('Participant ID: %s\n', participant_id);
        end
        if ~exist(strcat('img/animated_gif/', participant_id), 'dir')
            mkdir(strcat('img/animated_gif/', participant_id));
        end
            
        order = 1;
        for j = randsample(1:count, NUM_FIX_SEQ)
           %% Using parameters
            start_ts = period_table(j,1); end_ts = period_table(j,2);
            if SPANING
                start_ts = start_ts + (end_ts - start_ts) / 2 - SPAN_LENGTH / 2;
                end_ts = start_ts + SPAN_LENGTH;
            end
            if VERBOSE
                fprintf('\t%.3f => %.3f\n', start_ts, end_ts);
            end
            frames = get_interval_frame(M_1, start_ts, end_ts, FRAME_PER_SEC);
            out = strcat('img/animated_gif/', participant_id, '/', ...
                PERIOD_TYPE, '_', int2str(order), '.gif');
            order = order + 1;
            imout = uint8(zeros(272, 360, 1, size(frames, 4)));
           %% Colormap for animated-gif
            for k = 1 : size(frames, 4)
                im = imresize(squeeze(frames(:,:,:,k)), 0.5);
                if ~exist('imcat', 'var')
                    imcat = uint8(zeros(size(im, 1) * size(frames, 4), size(im, 2), 3));
                end
                imcat((size(im, 1) * (k - 1) + 1):size(im, 1) * k, ...
                    :, :) = im;
            end
            [imind, cm] = rgb2ind(imcat, 256,'nodither');
           %% Making the frames for animation 
            for k = 1 : size(frames, 4)
                im = imresize(squeeze(frames(:,:,:,k)), 0.5);
                imout(:,:,1,k) = rgb2ind(im, cm,'nodither');
            end
            imwrite(imout, cm, out, 'DelayTime', 1.0/FRAME_PER_SEC, 'LoopCount', inf);
        end
    end
end