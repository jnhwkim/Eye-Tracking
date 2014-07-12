%% Read files
filenames = dir('data/*GAT_eskim.tsv');
fixation_all = [];
No = size(filenames, 1);
MEDIAN_RECALIBRATION = false;
w = 1.0; h = 1.0;

%% Preprocessing
for i = 1 : No

    filename = filenames(i).name;
    filename_split = strsplit(filename,'.');
    N = ceil(sqrt(No));

    disp(sprintf('%d: %s', i, filename));
    
    if MEDIAN_RECALIBRATION
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
                import_data(strcat('data/pororo_s03p01_eskim.tsv'));
        
        fixation_raw = [FixationIndex FixationPointXMCSpx FixationPointYMCSpx];
        fixation_raw = fixation_raw(~isnan(fixation_raw(:,1)),:);
        fixation_raw = fixation_raw(~isnan(fixation_raw(:,2)),:);
        
        m = mean(fixation_raw(:,2:3))
        
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
            import_data(strcat('data/', filename));

    if(IS_RAW)
        fixation_raw = [FixationIndex FixationPointXADCSpx FixationPointYADCSpx];
    else
        fixation_raw = [FixationIndex FixationPointXMCSpx FixationPointYMCSpx];
    end
    
    fixation_raw = fixation_raw(~isnan(fixation_raw(:,1)),:);

    % Scope defined as [x_min,x_max; y_min,y_max];
    scope = [0, w; 0, h];
    for j = 1 : size(scope, 1)
        fixation_raw = fixation_raw( ...
                         fixation_raw(:,j+1)>scope(j,1),:);
        fixation_raw = fixation_raw( ...
                         fixation_raw(:,j+1)<scope(j,2),:);
    end
    
    x = fixation_raw(:,2); y = fixation_raw(:,3);
    if MEDIAN_RECALIBRATION
        x = x + (w/2 - m(1)); y = y + (h/2 - m(2));
    end
        
    %% Fixations
%     figure(1);
    %subplot('Position', [mod(i-1,N)/N, 1-1/N-floor((i-1)/N)/N, 1/N, 1/N]);
%     hold on;
    scatter(x, h-y, 'blue', 'o'); % Notice the y-inverted coordinates.
    grid on;
    set(gca,'XTick',0:w/4:w, ...
            'YTick',0:h/4:h);
    axis([0 w 0 h]);
    
end
