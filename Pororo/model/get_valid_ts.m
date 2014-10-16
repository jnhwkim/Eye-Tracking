% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: Sep 25 2014
%
% Get the timestamp list for validation sequences in milliseconds.

function [ts, pids] = get_valid_ts
    %% Criteria
    VERBOSE = false;
    PID_PREFIX = 'Participant ID:';
    pids = {'hhkim', 'jkim', 'swlee', 'jhryu', 'dsbaek', 'kwpark', ...
            'yspark', 'mhseo', 'yhlee', 'jhlee', 'cekim'};
    log_paths = {'../img/animated_gif/gen_long_seq.log', ...
                 '../img/animated_gif/gen_short_seq.log'};
    ts = zeros(size(pids,2), 16);
    for path_idx = 1:size(log_paths,2)
        path = log_paths(path_idx);
        fid = fopen(cell2mat(path));
        tline = fgetl(fid);
        flag = false;
        while ischar(tline)
            if strncmp(tline, PID_PREFIX, size(PID_PREFIX, 2))
                pid = tline(1, size(PID_PREFIX, 2)+2:end);
                idx = find(ismember(pids, pid));
                count = 1;
                if idx
                    flag = true;
                    if VERBOSE
                        disp(idx);
                    end
                else
                    flag = false;
                end
            elseif flag && 0 < size(strfind(tline, '=>'),2)
                A = sscanf(tline, '%d.%d => %d.%d');
                if VERBOSE
                    fprintf('%d -> %d\n', A(1), A(3));
                end
                ts(idx, count + (path_idx - 1) * 8) = A(1);
                count = count + 1;
            end
            % read next line
            tline = fgetl(fid);
        end
    end
end