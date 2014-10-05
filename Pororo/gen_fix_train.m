%% Read files
filenames = dir('data/pororo_s03*.tsv');

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

    durations_raw = [RecordingTimestamp FixationIndex GazeEventDuration];
    durations_dup = durations_raw(~isnan(durations_raw(:,2)),:);
    durations = unique(durations_dup, 'rows');
    durations_all = [durations_all; durations];

end

%%
LF = zeros(10000, 1);
for i = 1 : 10000
    ts = 1000 + (i-1)*400;
    a=find(durations_all(:,1)>=ts & durations_all(:,1)<ts+1000);
    LF(i) = median(durations_all(a,3));
end

% Normalization
% LF = (LF - min(LF)) / (max(LF) - min(LF));

save('model/data/train_LF.mat', 'LF');