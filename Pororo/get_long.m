% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: July 28 2014
%
% Find time intervals for given constraints.

function [period_table, fixations, hi, max_ts] = get_long(filenames, seconds, threshold, unit)

%% filenames = dir('data/*.tsv');
%% seconds using the fixations whose duration are longer than this.
%% threshold the minumum value of frequency to find long fixation periods.
%% wsize the basis to calculate the frequencies, in miliseconds.

    %% Auto-saving filenames
    FIXS_FILENAME = strcat('tmp/fixations_all_', int2str(seconds), '.mat');
    DURA_FILENAME = strcat('tmp/durations_all_', int2str(seconds), '.mat');
    LONG_FILENAME = strcat('tmp/long_ts_all_', int2str(seconds), '.mat');
    
    %% Running Options
    MEDIAN_ADJUSTMENT = true;
    VERBOSE = false;
    
    %% Run Script
    if ~exist(DURA_FILENAME, 'file') || ...
       ~exist(LONG_FILENAME, 'file') || ...
       ~exist(FIXS_FILENAME, 'file')

        fixations_all = [];
        durations_all = [];
        long_ts_all = [];

        for i = 1 : size(filenames, 1)

            filename = filenames(i).name;
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
                    import_data(strcat('data/', filename)); %#ok<*NASGU,*ASGLU>

            durations_raw = [FixationIndex GazeEventDuration];
            fixations_raw = [durations_raw ...
                             RecordingTimestamp ...
                             FixationPointXMCSpx ...
                             FixationPointYMCSpx ...
                             ones(size(FixationIndex))*i];
            durations_dup = durations_raw(~isnan(durations_raw(:,1)),:);
            fixations_dup = fixations_raw(~isnan(fixations_raw(:,1)),:);
            fixations_dup = fixations_raw(~isnan(fixations_raw(:,4)),:);
            durations = unique(durations_dup, 'rows');

            % Median Adjustment for the Recalibration.
            if MEDIAN_ADJUSTMENT
                fixation_median = median(fixations_dup(:,4:5));
                median_diff = [0.5 0.5] - fixation_median;
                median_adjustment = ones(size(fixations_dup,1),1)*median_diff;
                fixations_dup(:,4:5) = fixations_dup(:,4:5)+median_adjustment;
            end

            durations_all = [durations_all; durations];
            fixations_all = [fixations_all; fixations_dup];

            % Append RecordingTimestamp
            idx2ts = [FixationIndex RecordingTimestamp];
            long_fix_idx = durations(durations(:,2) >= seconds, 1);
            long_ts = idx2ts(ismember(idx2ts(:,1), long_fix_idx), 2);
            long_ts_all = [long_ts_all; long_ts];

        end
        save(FIXS_FILENAME, 'fixations_all');
        save(DURA_FILENAME, 'durations_all');
        save(LONG_FILENAME, 'long_ts_all');
    else
        load(FIXS_FILENAME);
        load(DURA_FILENAME);
        load(LONG_FILENAME);
    end
    
    %% Show the long fixation recording timestamps
    max_ts = ceil(max(long_ts_all) / 1000 * unit);
    hi = hist(long_ts_all, max_ts);
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
        elseif period_temp - ts(1, i) < -0.4 * unit
            if (period_temp - period_start) > unit % longer than 1 second
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


