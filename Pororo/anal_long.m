%% Read files
filenames = dir('data/*.tsv');
FIXS_FILENAME = 'tmp/fixations_all.mat';
DURA_FILENAME = 'tmp/durations_all.mat';
LONG_FILENAME = 'tmp/long_ts_all.mat';
if ispc
    PATH_TO_PORORO_VIDEO = 'd:\Movies/pororo_1.avi';
else
    PATH_TO_PORORO_VIDEO = '/Users/calvin/Desktop/Pororo/pororo_1.avi';
end
LONG = 2000;

%% Running Options
MEDIAN_ADJUSTMENT = true;
VERBOSE = false;

%% Run a script
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
                import_data(strcat('data/', filename));

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
        long_fix_idx = durations(durations(:,2)>=LONG, 1);
        long_ts = idx2ts(ismember(idx2ts(:,1), long_fix_idx),2);
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
THRESHOLD = 12; % ref. possible_max(hi) = 17*30 = 510
SEG = 5; % It means the window size of sampling is 200 ms.
max_ts = ceil(max(long_ts_all) / 1000 * SEG);
hi = hist(long_ts_all, max_ts);
if VERBOSE 
    plot([1:max_ts], hi);
end
ts = find(hi>=THRESHOLD);

%% Get a period table
period_table = [];
period_start = -1;
period_temp = -1;
for i = 1:size(ts, 2)
    if i == 1
        % notice that each frame has width 1.
        period_start = ts(1, i) - 1;
    elseif period_temp - ts(1, i) < -2
        period_table = [period_table; period_start, period_temp]; %#ok<AGROW>
        period_start = ts(1, i) - 1;
    end
    period_temp = ts(1, i)
end
period_table = [period_table; period_start, period_temp];
    
% The periods those're over the threshold and longer than 2 seconds.
% [start_sec, end_sec; ...]
period = period_table;
period = period / SEG;
      
% Get the screenshots
MAX_INTERVAL = max(period(:,2)-period(:,1));
FRAME_PER_SEC = 2;
COL = round(MAX_INTERVAL * FRAME_PER_SEC + 1);
ROW = size(period,1);
SECOND_UNIT = 1000;
if ~exist('M', 'var')
    M = VideoReader(PATH_TO_PORORO_VIDEO);
end
fixations = fixations_all(fixations_all(:,2)>=LONG,3:6);
threshold = SECOND_UNIT / SEG / 2;

for p = 1 : ROW
    start_ts = period(p,1) * SECOND_UNIT;
    end_ts = period(p,2) * SECOND_UNIT;
    disp(sprintf('%.3f => %.3f', start_ts, end_ts));
    frames = get_interval_frame(M, start_ts, end_ts, FRAME_PER_SEC);
    for j = 1 : size(frames,4)
        subplot('Position', [(j-1)/COL, (ROW-p)/ROW,...
                        1/COL, 1/ROW]);
        I = imresize(squeeze(frames(:,:,:,j)), 0.5);
        time = start_ts + (j-1) * SECOND_UNIT / FRAME_PER_SEC;
        show_fix(I, time, fixations, threshold);
        axis off;
    end
end













