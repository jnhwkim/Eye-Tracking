% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: July 30 2014
%
% Find time intervals for given constraints.

function [period_table, fixations, hi, max_ts] = get_short(filenames, seconds, threshold, unit, nocache)

%% filenames = dir('data/*.tsv');
%% seconds using the gazes whose duration are shorter than this.
%% threshold the minumum value of frequency to find long fixation periods.
%% wsize the basis to calculate the frequencies, in miliseconds.

    %% Auto-saving filenames
    DURA_FILENAME = strcat('tmp/durations_all_', int2str(seconds), '.mat');
    LONG_FILENAME = strcat('tmp/long_ts_all_', int2str(seconds), '.mat');
    
    %% Running Options
    VERBOSE = false;
    
    %% Run Script
    if nocache || ~exist(DURA_FILENAME, 'file') || ...
       ~exist(LONG_FILENAME, 'file') || ...
       ~exist(FIXS_FILENAME, 'file')

        fixations_all = [];
        durations_all = [];
        long_ts_all = [];

        for i = 1 : size(filenames, 1)

            filename = filenames(i).name;
            if VERBOSE
                disp(filename);
            end

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
                    import_data(strcat('data/', filename)); %#ok<*NASGU,*ASGLU>

            durations_raw = [RecordingTimestamp GazeEventDuration];
            durations_dup = durations_raw(~isnan(durations_raw(:,2)),:);
            durations = unique(durations_dup, 'rows');
            durations_all = [durations_all; durations];

            % Append RecordingTimestamp
            long_ts = durations(durations(:,2) < seconds, 1);
            long_ts_all = [long_ts_all; long_ts];

        end
        if ~nocache
            save(DURA_FILENAME, 'durations_all');
            save(LONG_FILENAME, 'long_ts_all');
        end
    else
        load(DURA_FILENAME);
        load(LONG_FILENAME);
    end
    
    %% Show the long fixation recording timestamps
    max_ts = ceil(max(long_ts_all) / 1000 * unit);
    long_ts_all = [long_ts_all; 1];
    hi = hist(long_ts_all, max_ts); % Notice: first bin has extra one for shaphing.
    hi(1) = hi(1) - 1;
    if VERBOSE
        plot([1:max_ts], hi);
    end
    ts = find(hi>=threshold);

    %% Get a period table
    period_table = [];
    period_start = -1;
    period_temp = -1;
    for i = 1:size(ts, 2)
        if i == 1
            % notice that each frame has width 1.
            period_start = ts(1, i) - 1;
        elseif period_temp - ts(1, i) < -0.1 * unit
            if period_temp < 4000.900 * unit && (period_temp - period_start) > unit * 3 % longer than 3 second
                period_table = [period_table; period_start, period_temp]; %#ok<AGROW>
            end
            period_start = ts(1, i) - 1;
        end
        period_temp = ts(1, i);
    end
    
    %% Output
    period_table = [period_table; period_start, period_temp];
    fixations = fixations_all;
end


