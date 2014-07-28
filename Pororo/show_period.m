% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: July 28 2014
%
% Show the sequence for given time intervals.

function period_table = show_period(fixations, seconds, period_table, unit)

    SECOND_UNIT = 1000;
    FRAME_PER_SEC = 2;
    if ispc
        PATH_TO_PORORO_VIDEO = 'd:\Movies/pororo_1.avi';
    else
        PATH_TO_PORORO_VIDEO = '/Users/calvin/Desktop/Pororo/pororo_1.avi';
    end
    
    % The periods those're over the threshold and longer than 2 seconds.
    % [start_sec, end_sec; ...]
    period = period_table;
    period = period / unit;

    % Get the screenshots
    MAX_INTERVAL = max(period(:,2)-period(:,1));
    COL = round(MAX_INTERVAL * FRAME_PER_SEC + 1);
    ROW = size(period,1);
    
    if ~exist('M', 'var')
        M = VideoReader(PATH_TO_PORORO_VIDEO);
    end
    fixations = fixations(fixations(:,2) >= seconds, 3:6);
    threshold = SECOND_UNIT / unit / 2;

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
    
end