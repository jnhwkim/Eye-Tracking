addpath('../../SaliencyToolbox/');
addpath('../ltm/');

% path = '../img/animated_gif/cekim/C_1.gif';
% 
% [X, map] = imread(path);
% 
% idx = 1;
% img = ind2rgb(X(:,:,:,idx), map);
% 
% salMaps = batchSaliency({img,img});

%% All Fixation Types
[types, participant_id] = get_types();
num_participants = size(participant_id, 1);

TYPES = ['L', 'S'];
FRAME_SKIP = 5;
NUM_DATA = 8;
map_dim = [17 22];
map_size = map_dim(1) * map_dim(2);
num_frames = 21; % 2 seconds

count = 1;

%% Switch
METHOD = 'gray';
TRAIN = true;

if TRAIN
    TYPES = ['T'];
    num_participants = 1;
    participant_id = {'train'};
    FRAME_SKIP = 0;
    NUM_DATA = 1000;
end

if strcmp('saliency', METHOD) || strcmp('gray', METHOD)
    FEATURE_SIZE = map_size * num_frames;
elseif strcmp('track', METHOD)
    FEATURE_SIZE = 2 * (num_frames - 1);
end

if TRAIN
    X = zeros(NUM_DATA, FEATURE_SIZE);
else
    X = zeros(num_participants * NUM_DATA * 2, FEATURE_SIZE);
end

for id = 1 : num_participants
    for type = TYPES
        for i = 1 : NUM_DATA
            path = sprintf('../img/animated_gif/%s/%c_%d.gif', ...
                            participant_id{id}, type, i);
            [data, map] = imread(path);
            img = cell(num_frames, 1);
            disp(path);
            for idx = 1 : num_frames
                % middle 2 seconds
                img{idx} = ind2rgb(data(:,:,:,idx+FRAME_SKIP), map); 
            end
            
            if strcmp('saliency', METHOD) || strcmp('track', METHOD)
                salMaps = batchSaliency(img);
            end
            
            feature_vec = zeros(FEATURE_SIZE, 1);
            if strcmp('track', METHOD)
               trace = zeros(num_frames, 2);
            end
            for idx = 1 : num_frames 
                if strcmp('saliency', METHOD)
                    salMap = salMaps(idx).data;
                    salMap_rescale = imresize(salMap, map_dim);
                    feature_vec(1+(idx-1)*map_size:idx*map_size,1) = ...
                        salMap_rescale(:);
                elseif strcmp('track', METHOD)
                    max_val = max(salMaps(idx).data(:));
                    [x, y] = find(salMaps(idx).data==max_val);
                    if 0 == max_val || 1 < size(x, 1)
                        if 1 < idx 
                            x = trace(idx-1, 1); y = trace(idx-1, 2);
                        else
                            x = round(map_dim(1) / 2); y = round(map_dim(2) / 2);
                        end
                    end
                    trace(idx, :) = [x, y];
                    if 1 < idx
                        feature_vec((idx-2)*2+1 : (idx-1)*2, 1) = ...
                            trace(idx, :);
                    end
                elseif strcmp('gray', METHOD)
                    I = imresize(rgb2gray(img{idx}), map_dim);
                    feature_vec(1+(idx-1)*map_size:idx*map_size,1) = ...
                        I(:);
                end
            end
            X(count,:) = feature_vec'; count = count + 1;
        end
    end
end

if strcmp('track', METHOD)
    X1 = [];
    FEATURE_NUM = 10;
    FEATURE_SIZE = 40;
    for i = 1 : 2 : FEATURE_SIZE - FEATURE_NUM * 2
        X1 = [X1; X(:,i:i+FEATURE_NUM * 2-1)];
    end
    X = [X1, X1 .* X1];
    % y???
end

if TRAIN
    y = import_label('../img/animated_gif/train_label.txt');
else
    y = types'; y = y(:);
end

% Save the result.
save(sprintf('data/train_%s.mat', METHOD), 'X', 'y');
