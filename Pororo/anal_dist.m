% Copyright (C) 2015 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: Feb 23 2015
%

%% Configure the default parameters
configure;

%% Analyse the long fixations 
% For all data, 
filenames = dir('data/pororo_s03p0*.tsv');
% three participants commonly fix on the same sequences 
threshold = 3; 
% longer than 2 seconds.
seconds = 2000;
% Hz
unit = 30;

% Find the period for the given constrants.
[period_table, fixations] = get_long(filenames, seconds, threshold, unit, true);

% Filter the periods shorter than 2 seconds.
min_period = 2000;
target_period = 500; % middel 1 frame
filtered_table = [];
for i  = 1 : size(period_table, 1)
    start_t = period_table(i, 1);
    end_t = period_table(i, 2);
    diff = (end_t - start_t) * 1000 / unit;
    if diff >= min_period
        % Centering and crop 2 seconds.
        center = start_t * 1000 / unit + diff / 2;
        cropped = [center - target_period / 2, center + target_period / 2];
        cropped = cropped * unit / 1000;
        filtered_table = [filtered_table; cropped];
    end
end

% Manually select the typical periods.
selected_idx = [23];
filtered_table = filtered_table(selected_idx, :);

% Display found periods
f = figure(1);
set(f, 'Position', [100 100 360 272]);
last = false;
show_period(fixations, 0, filtered_table, unit, last);

%% Display distribution
mu = timely_fixations(1:12,1:2); % 13th data is at outside of screen.
sigma = eye(2) / 10;

[X Y] = meshgrid(0:0.05:1, 0:0.05:1);
Z = zeros(size(X));

for i = 1 : size(mu, 1)
    z = mvnpdf([X(:), Y(:)], mu(i,:), sigma);
    z = reshape(z, size(X));
    Z = Z + z;
end
Z = Z / size(mu, 1);

f = figure(2);
set(f, 'Position', [100 372 360 272]);
subplot('Position', [0, 0, 1, 1]);
I = imread('dist/sel_img.png');
imagesc([0,1],[0,1], I);
hold on;
contour(X,Y,Z,3);
axis off;
%imshow(Z, [0 1]);
%surf(X,Y,Z);