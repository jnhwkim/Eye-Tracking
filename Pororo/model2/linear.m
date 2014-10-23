% Linear modeling for eye movement.

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
[ types, participant_id ] = get_types();
[ ratings ] = get_ratings();
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
else
    load('tmp/salMaps.mat');
end
    
%% Gaze saliency hit test
SALMAP_SIZE = [size(salMaps{1,1}, 1), size(salMaps{1,1}, 2)];
salTrace = cell(size(ts, 1), size(ts, 2));
salsum = zeros(size(ts, 1), size(ts, 2));
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
        
        saltrc = [];
        salmap = salMaps{i,j};
        
        % gaussian filtering
        %h = fspecial('gaussian', [3 3], 0.5);
        %salmap = imfilter(salmap, h, 'replicate');
        
        salmap = salmap / sum(salmap(:)); % normalized
        
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
        salsum(i,j) = sum(saltrc); %sum of hit
    end
end

%% Linear Modeling
SS = S(:,:,1) + S(:,:,2);
X = [LF(1:88)', SS(1:88)', salsum(1:88)']; % Long fixations
y = types(1:88)';

% linear model fitting for alert
mdl = fitlm(X(:,2), y)
[h,p] = ttest2(X(y==1,2),X(y==0,2))
%anova(mdl)

X = [LF(:), SS(:), salsum(:)];
y = ratings(:);

% linear model fitting for recall
mdl = fitlm(X(:,[1,3]), y)
[h,p] = ttest2(X(y>4,3),X(y<=4,3))
%anova(mdl)
