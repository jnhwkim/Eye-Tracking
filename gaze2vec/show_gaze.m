function show_gaze
%SHOW_GAZE Show gaze points given by gaze data on the corresponding image
%   It is used for the sanity check.

% options
image_path = '../Pororo/screenshots/';
format = 'pororo_1_%d.bmp';
IMAGE_DIM = 256;
CROPPED_DIM = 224;
extra_bins = 30;
ts2idx = @(ts)(floor((ts + 1) / 100 * 3) + 1);
% position is encoded as a vector (256x256).
data = load('gaze_data.mat');
gaze_data = data.gaze_data;
P = size(gaze_data, 2);
% read images
images = dir_sorted([image_path '*.bmp'], format);
figure(1);
for i = 1 : size(images, 1)
   filename = images{i,1};
   ts = sscanf(filename, format);
   I = imread([image_path filename]);
   I = imresize(I, [IMAGE_DIM, IMAGE_DIM]);
   pause(.1);
   imagesc(I);
   hold on;
   for j = ts2idx(ts) : ts2idx(ts) + extra_bins - 1
       for p = 1 : P
        [x, y] = scalar2pos(gaze_data(j,p), IMAGE_DIM);
        plot(x, y, 'x');
       end
   end
   hold off;
end
end

