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

clear;

%% All Fixation Types
[types, participant_id] = get_types();
num_participants = size(participant_id, 1);

map_size = 9 * 11;
num_frames = 21; % 2 seconds
X = zeros(num_participants * 16, map_size * num_frames);
count = 1;

for id = 1 : num_participants
    for type = ['L', 'S']
        for i = 1 : 8
            path = sprintf('../img/animated_gif/%s/%c_%d.gif', ...
                            participant_id{id}, type, i);
            [data, map] = imread(path);
            img = cell(num_frames, 1);
            disp(path);
            for idx = 1 : num_frames
                % middle 2 seconds
                img{idx} = ind2rgb(data(:,:,:,idx+5), map); 
            end
            salMaps = batchSaliency(img);
            
            feature_vec = zeros(map_size(1)*num_frames,1);
            for idx = 1 : num_frames 
                salMap = salMaps(idx).data;
                salMap_half = imresize(salMap, 0.5); % size:9x11
                feature_vec(1+(idx-1)*map_size:idx*map_size,1) = ...
                    salMap_half(:);
            end
            X(count,:) = feature_vec'; count = count + 1;
        end
    end
end

y = types';
y = y(:);
save('saliency_half.mat', 'X');
save('alert_label.mat', 'y');