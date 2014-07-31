% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: July 30 2014
%
% Generate three type of animated-gif, which are 
% 1) long fixation sequences
% 2) non-fixation sequences
% 3) control sequences from the other similar movie.

function gen_type_seq(movie, target)

    %% Switch the function is here.
    PERIOD_TYPE = 'C'; % Type can be L or S or C.
    
    %% Target files.
    % Notice that this script expands to include the second part of recordings.
    % refer to line 42.
    if nargin < 2
        target = '*';
    end
    filenames = dir(sprintf('data/pororo_s03p01_%s.tsv', target));
    
    %% The period getter selection
    if 'L' == PERIOD_TYPE
        periodGetter = @get_long; % get long fixation period table.
        disp('*** gen_long_seq ***');
    elseif 'S' == PERIOD_TYPE
        periodGetter = @get_short; % get long fixation period table.
        disp('*** gen_short_seq ***');
    elseif 'C' == PERIOD_TYPE
        periodGetter = @get_const; % get the predefined period table.
        disp('*** gen_const_seq ***');
    end

    %% Constants
    if 'L' == PERIOD_TYPE
        THRESHOLD_INIT = 2000; THRESHOLD_STEP = 200; NUM_FIX_SEQ = 8;
    elseif 'S' == PERIOD_TYPE
        THRESHOLD_INIT = 150; THRESHOLD_STEP = -10; NUM_FIX_SEQ = 8;
    elseif 'C' == PERIOD_TYPE
        THRESHOLD_INIT = 1; THRESHOLD_STEP = 0; NUM_FIX_SEQ = 4;
    end
    SPAN_LENGTH = 3000; SPANING = true;
    UNIT = 30; VERBOSE = true; FRAME_PER_SEC = 10;
    
    %% Video Inforamtion
    if ispc
        PATH_TO_PORORO3_VIDEO = 'd:\Movies\pororo_1.avi';
        PATH_TO_PORORO2_VIDEO = 'd:\Movies\Pororo_ENGLISH2_1.avi';
    else
        PATH_TO_PORORO3_VIDEO = '/Users/calvin/Desktop/Pororo/pororo_1.avi';
        PATH_TO_PORORO2_VIDEO = '/Users/calvin/Desktop/Pororo/Pororo_ENGLISH2_1.avi';
    end
    
    %% Reading the whole video is very slow. 
    %% Pass it as an argument.
    if nargin < 1
        disp('Reading a video..');
        if 'C' == PERIOD_TYPE
            movie = VideoReader(PATH_TO_PORORO2_VIDEO);
        else
            movie = VideoReader(PATH_TO_PORORO3_VIDEO);
        end
        disp('doen.');
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
            frames = get_interval_frame(movie, start_ts, end_ts, FRAME_PER_SEC);
            out = strcat('img/animated_gif/', participant_id, '/', ...
                PERIOD_TYPE, '_', int2str(order), '.gif');
            order = order + 1;
            
           %% Generate animated-gifs
           if 'C' == PERIOD_TYPE
               % Aspect fill and remove the black line of the bottom.
               preprocessor = @(im) (imresize(im(1:400, round((720-720*416/544)/2):720-round((720-720*416/544)/2), :), [272, 360]));
           else
               proprocessor = @(im) (imresize(im, 0.5));
           end
           gen_anigif(frames, FRAME_PER_SEC, out, preprocessor);
        end
    end
end