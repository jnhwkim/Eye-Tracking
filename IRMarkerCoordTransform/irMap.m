% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim
% Created: Feb 9 2014
%
% Returns IR Marker Information.
%
function irMap = irMap()
MAX_NUM_OF_IR_MARKERS = 30;

% Others (-1, -1) are not-known.
irMap = ones(MAX_NUM_OF_IR_MARKERS, 2) .* -1

irMap(30,:) = [0, 0];
irMap(11,:) = [0.25, 0];
irMap(15,:) = [0.75, 0];
irMap(13,:) = [0, 0.5];
irMap(17,:) = [0, 1];
irMap(29,:) = [0.25, 1];
irMap(14,:) = [0.5, 1];
irMap(18,:) = [0.75, 1];


end
