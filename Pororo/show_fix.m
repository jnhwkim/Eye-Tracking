% % Copyright (C) 2014 Jin-Hwa Kim
% %
% % Author: Jin-Hwa Kim
% % Created: Feb 9 2014
% %
% % show fixation points on the image.
% %
% function showFixation(time, fixations)
% 
% data = imread(strcat('screenshots/pororo_1_',time,'.bmp'));
% imagesc([0,1],[0,1], data);
% intensity = 1;
% 
% hold on;
% for i=1:size(fixations,1)
%    if abs(fixations(i,1) - str2double(time)) < 34
%        plot(fixations(i,2), fixations(i,3), 'o', ...
%            'MarkerSize', 4, ...
%            'MarkerFaceColor', [intensity, 0, 0]);
%        intensity = max(intensity - 0.2, 0);
%    end
% end
% 
% end


% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim
% Created: Feb 9 2014
%
% show fixation points on the image.
%
function showFixation(I, time, fixations, threshold)

if ~isnumeric(time)
    time = str2num(time);
end
imagesc([0,1],[0,1], I);

timely_fixations = fixations(abs(fixations(:,1) - time) ...
                             < threshold, 2:end);
timely_fixations = unique(timely_fixations,'rows');

% column 3 indicates the number of subject for coloring.
if size(timely_fixations, 2) < 3
    timely_fixations = [timely_fixations, ones(size(timely_fixations, 1))];
end

N = size(timely_fixations,1);
hold on;

for i=1:N
   cm = colormap(jet(N));
   plot(timely_fixations(i,1), timely_fixations(i,2), 'o', ...
       'MarkerSize', 3, ...
       'MarkerFaceColor', cm(i,:));
end

% for i=1:N
%    %cm = colormap(jet(N));
%    cm = colormap(jet(17));
%    plot(timely_fixations(i,1), timely_fixations(i,2), 'o', ...
%        'MarkerSize', 8, ...
%        'MarkerFaceColor', cm(mod(timely_fixations(i,3)-1,17)+1,:));
% end

end