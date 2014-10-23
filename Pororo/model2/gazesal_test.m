% Gaze Saliency Test

%% Preambles
addpath('..');
addpath('../model');
addpath('../../SaliencyToolbox/');
configure;
FRAME_PER_SEC = 30;

%% Get information
[LF, S, GZ] = gen_fix_valid();
[ts, pids] = get_valid_ts();
NUM_PARTICIPANTS = size(ts, 1);
NUM_TRIALS = size(ts, 2);

%% Get Saliency Map
salMaps = cell(size(ts));
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
        salMaps{i,j} = batchSaliency(img);
    end
end
save('tmp/salMaps.mat', 'salMaps');