% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: July 31 2014
%
% Find time intervals for given constraints.

function [period_table] = get_short(filenames, seconds, threshold, unit, nocache)

%% It returns the static information.
    
    %% Running Options
    VERBOSE = false;
    
    %% Run Script
    period_table = [[100000:60000:3940000]' [103000:60000:3943000]'];

    period_table = period_table * unit / 1000;
    
end
