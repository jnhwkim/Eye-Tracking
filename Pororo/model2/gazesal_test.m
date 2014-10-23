% Gaze Saliency Test

%% Preambles
addpath('..');
addpath('../model');
addpath('../../SaliencyToolbox/');
configure;
FRAME_PER_SEC = 30;

%% Get information
if ~exist('LF', 'var')
    [LF, S, GZ] = gen_fix_valid();
end
[ts, pids] = get_valid_ts();
NUM_PARTICIPANTS = size(ts, 1);
NUM_TRIALS = size(ts, 2);

%% Get Saliency Map
if ~exist('salMaps', 'var')
    salMaps = cell(size(ts, 1), size(ts, 2));
    for i = 1 : NUM_PARTICIPANTS
        for j = 1 : NUM_TRIALS
            % interval is 1500 ms.
            dura = min(LF(i,j), 1500);
            start_ts = ts(i, j) + (3000 - dura) / 2;
            end_ts   = ts(i, j) + (3000 + dura) / 2;
            fprintf('[%d][%d] %d -> %d\n', i, j, start_ts, end_ts);

            % get frames
            frames = get_interval_frame(M, start_ts, end_ts, FRAME_PER_SEC);

            % get saliency map
            N_FRAMES = size(frames, 4);
            img = cell(N_FRAMES, 1);
            for k = 1 : N_FRAMES
                img{k} = squeeze(frames(:,:,:,k));
            end
            saldata = batchSaliency(img);
            salmap = zeros( size(saldata(1).data, 1), ...
                            size(saldata(1).data, 2), ...
                            N_FRAMES );
            for k = 1 : N_FRAMES
                salmap(:,:,k) = saldata(k).data;
            end
            salMaps{i, j} = salmap;
        end
    end
    save('tmp/salMaps.mat', 'salMaps');
end

%% 
SALMAP_SIZE = [size(salMaps{1,1}, 1), size(salMaps{1,1}, 2)];
salTrace = cell(size(ts, 1), size(ts, 2));
for i = 1 : NUM_PARTICIPANTS
    for j = 1 : NUM_TRIALS
        % interval is 1500 ms.
        dura = min(LF(i,j), 1500);
        start_ts = ts(i, j) + (3000 - dura) / 2;
        end_ts   = ts(i, j) + (3000 + dura) / 2;
        fprintf('[%d][%d] %d -> %d\n', i, j, start_ts, end_ts);
        
        % gaze tracing on saliency map.
        gaze = GZ{i,j};
        if size(gaze, 1) == 0
            continue;
        end
        salmap = salMaps{i,j};
        saltrc = [];
        for k = 1 : size(gaze, 1)
            rts = gaze(k, 1);
            if rts < start_ts || rts > end_ts
                continue;
            end
            
            idx = floor((rts - start_ts) / 33) + 1;
            g = gaze(k, 9:-1:8);
            if max(g) > 1 || min(g) < 0
                continue;
            end
            pos = ceil(g .* SALMAP_SIZE);
            sal = salmap(pos(1), pos(2), idx);
            saltrc = [saltrc; sal]; %#ok<AGROW>
        end
        salTrace{i, j} = saltrc; 
    end
end
