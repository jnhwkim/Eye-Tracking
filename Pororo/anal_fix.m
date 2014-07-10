%% Read files
filenames = dir('data/*.tsv');
DURA_FILENAME = 'tmp/durations_all.mat';

if ~exist(DURA_FILENAME, 'file')

    durations_all = [];

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
        durations_dup = durations_raw(~isnan(durations_raw(:,1)),:);
        durations = unique(durations_dup, 'rows');
        durations_all = [durations_all; durations];

    end
    save(DURA_FILENAME, 'durations_all');
else
    load(DURA_FILENAME);
end

durations_in_bins = round(durations_all(:,2) ./ 33.33);
bin_size = max(durations_in_bins);
bin_offset = min(durations_in_bins);
h = hist(durations_in_bins, bin_size-bin_offset);
h = [zeros(1, bin_offset), h];
plot([1:bin_size/2], log(h(1:bin_size/2)));
% plot([1:bin_size], log(h(1:bin_size)));
xlabel('Fixation Duration (1/30 sec)', 'FontSize', 16);
ylabel('Logarithm of the Number of Fixations', 'FontSize', 16);

% Adjust xlabel y-position
y_offset = 1.0;
xlabel_pos = get(get(gca,'xlabel'),'position');
ylimits = get(gca,'ylim');
xlabel_pos(2) = ylimits(1) - y_offset;
set(get(gca,'xlabel'), 'position', xlabel_pos);
