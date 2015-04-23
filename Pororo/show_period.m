% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: July 28 2014
%
% Show the sequence for given time intervals.

function period_table = show_period(fixations, seconds, period_table, unit, last)

    %% Configure the default parameters
    configure;
    
    %% Include the last frame?
    if nargin < 5
        last = true;
    end
    
    %% Set parameters
    FRAME_PER_SEC = 2;
    
    % The periods those're over the threshold and longer than 2 seconds.
    % [start_sec, end_sec; ...]
    period = period_table;
    period = period / unit;

    % Get the screenshots
    MAX_INTERVAL = max(period(:,2)-period(:,1));
    COL = round(MAX_INTERVAL * FRAME_PER_SEC + 1);
    ROW = size(period,1);
    
    fixations = fixations(fixations(:,2) >= seconds, 3:6);
    threshold = SECOND_UNIT / unit / 2;

    for p = 1 : ROW
        start_ts = period(p,1) * SECOND_UNIT;
        end_ts = period(p,2) * SECOND_UNIT;
        disp(sprintf('%.3f => %.3f', start_ts, end_ts));
        frames = get_interval_frame(M, start_ts, end_ts, FRAME_PER_SEC);
        if ~last
            COL = COL - 1;
        end
        for j = 1 : COL
            subplot('Position', [(j-1)/COL, (ROW-p)/ROW,...
                            1/COL, 1/ROW]);
            I = imresize(squeeze(frames(:,:,:,j)), 0.5);
            time = start_ts + (j-1) * SECOND_UNIT / FRAME_PER_SEC;
            show_fix(I, time, fixations, threshold);
            axis off;
        end
    end
    
end