% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: July 28 2014
%
% For all data, 
filenames = dir('data/pororo_s03p0*.tsv');
% three participants commonly fix on the same sequences 
threshold = 3; 
% longer than 2 seconds.
seconds = 2000;
% Hz
unit = 30;

% Find the period for the given constrants.
[period_table, fixations] = get_long(filenames, seconds, threshold, unit, false);

% Filter the periods shorter than 2 seconds.
min_period = 2000;
filtered_table = [];
for i  = 1 : size(period_table, 1)
    start_t = period_table(i, 1);
    end_t = period_table(i, 2);
    diff = (end_t - start_t) * 1000 / unit;
    if diff >= min_period
        % Centering and crop 2 seconds.
        center = start_t * 1000 / unit + diff / 2;
        cropped = [center - min_period / 2, center + min_period / 2];
        cropped = cropped * unit / 1000;
        filtered_table = [filtered_table; cropped];
    end
end

% Manually select the typical periods.
selected_idx = [10; 11; 23; % Alert
                4; 7; 18; % Successive
                3; 5; 17; % Stationary
                2]; % Unclassfied
filtered_table = filtered_table(selected_idx, :);

% Display found periods
f = figure(1);
set(f, 'Position', [100 100 800 1200]);
show_period(fixations, seconds, filtered_table, unit);
