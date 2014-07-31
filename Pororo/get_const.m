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
    period_table = [    900000  930000;
                       1900000 1930000;
                       2900000 2930000;
                       3900000 3930000  ];

    period_table = period_table * unit / 1000;
    
end
