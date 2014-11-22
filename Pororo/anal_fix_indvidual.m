%% Read files

figurestyle;

participants = {'bjlee', 'cekim', 'cylee', 'dsbaek', 'eskim', 'hhkim', ...
    'jhkim', 'jhlee', 'jhryu', 'jkim', 'kwon', 'kwpark', 'mhseo', ...
    'sbryu', 'swlee', 'yhlee', 'yrseo', 'yspark'};
medians = zeros(size(participants, 2), 1);

participants = {'cylee', 'eskim', 'hhkim', 'jhlee', 'jhryu', 'kwpark', 'swlee', 'yhlee'};

%% Figure setting
f1 = figure(1);
cm = colormap('Lines');

for p = 1 : size(participants, 2)
    filenames = dir(strcat('data/pororo_s03p0*_', participants{p}, '.tsv'));

    durations_all = [];

    for i = 1 : size(filenames, 1)
        filename = filenames(i).name;
        disp(filename);
        warning('off','MATLAB:iofun:UnsupportedEncoding');
        [   RecordingTimestamp, FixationIndex, SaccadeIndex, ...
            GazeEventType, GazeEventDuration, FixationPointXADCSpx, ...
            FixationPointYADCSpx, GazePointXADCSpx, GazePointYADCSpx, ...
            FixationPointXMCSpx, FixationPointYMCSpx, ...
            GazePointXMCSpx, GazePointYMCSpx    ] = ...
                import_data(strcat('data/', filename));

        durations_raw = [FixationIndex GazeEventDuration];
        durations_dup = durations_raw(~isnan(durations_raw(:,1)),:);
        durations = unique(durations_dup, 'rows');
        durations_all = [durations_all; durations];
    end
   
    durations_in_bins = round(durations_all(:,2) ./ 33.33);
    bin_size = max(durations_in_bins);
    bin_offset = min(durations_in_bins);
    h = hist(durations_in_bins, bin_size-bin_offset);
    h = [zeros(1, bin_offset), h];
    max_x = round(bin_size/2);
    plot([1:max_x], log(h(1:max_x)), 'Color', cm(p,:));
    medians(p) = median(durations_all(:,2));
    hold on;
end

hold off;

xlabel('Fixation Duration (1/30 sec)', 'FontSize', 16);
ylabel('Logarithm of the Number of Fixations', 'FontSize', 16);
axis([0 120 0 9]);

% Adjust xlabel y-position
y_offset = 0.7;
xlabel_pos = get(get(gca,'xlabel'),'position');
ylimits = get(gca,'ylim');
xlabel_pos(2) = ylimits(1) - y_offset;
set(get(gca,'xlabel'), 'position', xlabel_pos);

x_offset = 0.65;
ylabel_pos = get(get(gca,'ylabel'), 'position');
ylabel_pos(1) = ylabel_pos(1) - x_offset;
set(get(gca,'ylabel'), 'position', ylabel_pos);

set(f1, 'Position', [100 600 620 420]);
