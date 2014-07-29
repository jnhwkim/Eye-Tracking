% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: July 29 2014
%
% Get fixation sequences or non-fixation sequences as a animated-gif.
% gen_seq('data/pororo_s03p01_jhkim.tsv', true, 'img/long_seq/');

function gen_seq(filename, isFixed, out)

    LONG_FIXATION = 1000;
    UNIT = 30;

    if isFixed
       period_table = get_long(dir(filename), LONG_FIXATION, 1, UNIT, true);
       period_table = uint32(period_table * 1000 / UNIT)
    end

end