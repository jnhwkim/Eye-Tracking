% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: Sep 25 2014
%
% Get the timestamp list for validation sequences in milliseconds.

function LF = gen_fix_valid()
    %% Criteria
    VERBOSE = false;
    addpath('..');
    pids = {'hhkim', 'jkim', 'swlee', 'jhryu', 'dsbaek', 'kwpark', ...
            'yspark', 'mhseo', 'yhlee', 'jhlee', 'cekim'};
    LF = zeros(size(pids, 2), 16);
    ts = get_valid_ts();
    
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
                
                durations_raw = [RecordingTimestamp FixationIndex GazeEventDuration];
                durations_dup = durations_raw(~isnan(durations_raw(:,2)),:);
                durations = unique(durations_dup, 'rows');
                durations_all = [durations_all; durations];
        end
        for k = 1 : size(ts, 2)
            criterion = find(durations_all(:,1) >= ts(i, k) + 500 & ...
                             durations_all(:,1) < ts(i, k) + 2500);
            if 0 == size(criterion, 1)
                LF(i, k) = 0;
            else
                LF(i, k) = max(durations_all(criterion,3), [], 1);    
            end
        end
    end
end