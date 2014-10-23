% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: Sep 25 2014
%
% Get the timestamp list for validation sequences in milliseconds.

function [LF, S, GZ] = gen_fix_valid()
    %% Criteria
    VERBOSE = false;
    addpath('..');
    [ts, pids] = get_valid_ts();
    LF = zeros(size(pids, 2), 16);
    S = zeros(size(pids, 2), 16, 2);
    GZ = cell(size(pids, 2), 16);
    
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
                                 GazePointXADCSpx, GazePointYADCSpx, ...
                                 FixationPointXMCSpx, FixationPointYMCSpx, ...
                                 GazePointXMCSpx, GazePointYMCSpx];
                durations_dup = durations_raw(~isnan(durations_raw(:,2)),:);
                durations = durations_dup;
                durations_all = [durations_all; durations];
        end
        for j = 1 : size(ts, 2)
            criteria = find(durations_all(:,1) >= ts(i, j) + 0 & ...
                             durations_all(:,1) < ts(i, j) + 3000);
            if 0 == size(criteria, 1) % can't find the criteria
                LF(i, j) = 0;
                S(i, j) = 0;
            else
                % Fixation Duration
                LF(i, j) = max(durations_all(criteria,3), [], 1);

                % Recalculate the criteria
                criteria = find( ...
                    durations_all(:,1) >= ts(i, j) + (3000 - LF(i,j))/2 & ...
                    durations_all(:,1) <  ts(i, j) + (3000 + LF(i,j))/2);
                       
                gaze_x_raw = durations_all(criteria, 4);
                gaze_y_raw = durations_all(criteria, 5);
         
                gaze_x_vld = gaze_x_raw(~isnan(gaze_x_raw),:);
                gaze_y_vld = gaze_y_raw(~isnan(gaze_y_raw),:);
                
                rowall_raw = durations_all(criteria, :);
                rowall_vld = rowall_raw(~isnan(gaze_x_raw),:);
                GZ{i, j} = rowall_vld;
                    
                if size(gaze_x_vld) ~= size(gaze_y_vld)
                    disp('Warning: valid gaze x, y are not the same size!');
                end
                
                % Use the sliding window technique to avoid smooth pursuit
                WINDOW_SIZE = 5;
                K = size(gaze_x_vld, 1) - WINDOW_SIZE + 1;
                
                if WINDOW_SIZE < size(gaze_x_vld, 1)
                    S_sub = zeros(K, 2);
                    for k = 1 : K
                       gaze_x_sel = gaze_x_vld(k:k+WINDOW_SIZE-1,1);
                       gaze_y_sel = gaze_y_vld(k:k+WINDOW_SIZE-1,1);
                       S_sub(k, :) = [var(gaze_x_sel), var(gaze_y_sel)];
                    end
                    S(i, j, :) = median(S_sub);
                else
                    S(i, j, :) = [var(gaze_x_vld), var(gaze_y_vld)];
                end
            end
        end
    end
end