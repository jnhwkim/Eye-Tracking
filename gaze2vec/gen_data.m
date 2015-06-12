function gen_data

%% ids of participants
participants = {'bjlee', 'cekim', 'cylee', 'dsbaek', 'eskim', 'hhkim', ...
    'jhkim', 'jhlee', 'jhryu', 'jkim', 'kwon', 'kwpark', 'mhseo', ...
    'sbryu', 'swlee', 'yhlee', 'yrseo', 'yspark'};
%% preprocess options
IMAGE_DIM = 256;
CROPPED_DIM = 224;
MAX_TSB = 15 * 10^4; % max # of timestamp bins
%% outs
medians = zeros(size(participants, 2), 2);
gaze_data = zeros(MAX_TSB, size(participants, 2));
%% read files
for p = 1 : size(participants, 2)
    filenames = dir(strcat('data/pororo_s03p0*_', participants{p}, '.tsv'));
    data = [];
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
        raw = [RecordingTimestamp FixationIndex GazeEventDuration ...
               FixationPointXMCSpx FixationPointYMCSpx];
        dup = raw(~isnan(raw(:,2)),:);
        dup = dup(~isnan(dup(:,4)),:);
        unq = unique(dup, 'rows');
        data = [data; unq];
    end
    medians(p,:) = median(data(:,4:5));
    ts2idx = @(ts)(floor((ts + 1) / 100 * 3) + 1);
    idxes = cellfun(ts2idx, num2cell(data(:,1)));
    assert(size(idxes, 1) == size(unique(idxes, 'rows'), 1));
    for i = 1 : size(idxes, 1)
        x = data(i,4) - medians(p,1) + 0.5;
        y = data(i,5) - medians(p,2) + 0.5;
        gaze_data(idxes(i), p) = pos2scalar(x, y, IMAGE_DIM);
        % debug
        %[x1, y1] = scalar2pos(results(idxes(i), p), IMAGE_DIM);
        %fprintf('%d %d vs. %d %d\n', x*IMAGE_DIM, y*IMAGE_DIM, x1, y1);
    end
end
save('gaze_data.mat', 'gaze_data');
end

function scalar = pos2scalar(x, y, scale)
    scalar = (round(x * scale) - 1) * scale + round(y * scale);
end
