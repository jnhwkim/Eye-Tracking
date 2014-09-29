% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: Sep 25 2014
%
function [ idx ] = get_valid_idx( ts )
%GET_VALID_IDX Get the corresponding idx of training data to the timestamp list
% for validation sequences in milliseconds.

%% 
if 1 > nargin
    ts = get_valid_ts();
end

TRAIN_DATA_SIZE = 1000;
INTERVAL = 4;
WINDOW_SIZE = 2;
SKIP = 1;
PADDING = .5;

idx = size(ts);

for i = 1 : size(ts, 1)
    for j = 1 : size(ts, 2)
        t = ts(i,j);
        idx(i,j) = floor((t / 1000 - PADDING + WINDOW_SIZE) / 4) + 1;
    end
end

end

