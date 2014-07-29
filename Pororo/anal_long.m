% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: July 28 2014
%
% For all data, 
filenames = dir('data/pororo_s03p02*.tsv');
% three participants commonly fix on the same sequences 
threshold = 3; 
% longer than 2 seconds.
seconds = 2000;
% Hz
unit = 30;

[period_table, fixations, hi, max_ts] = get_long(filenames, seconds, threshold, unit, true);
show_period(fixations, seconds, period_table, unit);
%plot([1:max_ts], hi);