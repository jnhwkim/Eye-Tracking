% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: Sep 25 2014
%
% Get the timestamp list for validation sequences in milliseconds.

function [LF, S] = gen_fix_valid()
    %% Criteria
    VERBOSE = false;
    addpath('..');
    [ts, pids] = get_valid_ts();
    LF = zeros(size(pids, 2), 16);
    S = zeros(size(pids, 2), 16, 2);
    
    for i = 1 : size(pids, 2)
        filenames = dir(sprintf('../data/pororo_s03*_%s.tsv', pids{i}));
        durations_all = [];
        for j = 1 : size(filenames, 1)
            filename = filenames(j).name;
            disp(filename);
            warning('off','MATLAB:iofun:UnsupportedEncoding');
            [   RecordingTimestamp, ...
                FixationIndex, ...
                SaccadeIndex, ...
                GazeEventType, ...
                GazeEventDuration, ...
                FixationPointXADCSpx, FixationPointYADCSpx, ...
                GazePointXADCSpx, GazePointYADCSpx, ...
                FixationPointXMCSpx, FixationPointYMCSpx, ...
                GazePointXMCSpx, GazePointYMCSpx    ] = ...
                    import_data(strcat('../data/', filename));
                
                durations_raw = [RecordingTimestamp, ...
                                 FixationIndex, GazeEventDuration, ...
                                 GazePointXADCSpx, GazePointYADCSpx];
                durations_dup = durations_raw(~isnan(durations_raw(:,2)),:);
                durations = durations_dup;
                durations_all = [durations_all; durations];
        end
        for k = 1 : size(ts, 2)
            criteria = find(durations_all(:,1) >= ts(i, k) + 0 & ...
                             durations_all(:,1) < ts(i, k) + 3000);
            if 0 == size(criteria, 1) % can't find the criteria
                LF(i, k) = 0;
                S(i, k) = 0;
            else
                LF(i, k) = max(durations_all(criteria,3), [], 1);
                gaze_x_raw = durations_all(criteria, 4);
                gaze_x_vld = gaze_x_raw(~isnan(gaze_x_raw),:);
                gaze_y_raw = durations_all(criteria, 5);
                gaze_y_vld = gaze_y_raw(~isnan(gaze_y_raw),:);
                S(i, k, :) = [var(gaze_x_vld), var(gaze_y_vld)];
            end
        end
    end
end