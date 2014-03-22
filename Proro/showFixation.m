% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim
% Created: Feb 9 2014
%
% show fixation points on the image.
%
function showFixation(time, fixations)

data = imread(strcat('screenshots/pororo_1_',time,'.bmp'));
imagesc([0,1],[0,1], data);
intensity = 1;

hold on;
for i=1:size(fixations,1)
   if abs(fixations(i,1) - str2double(time)) < 34
       plot(fixations(i,2), fixations(i,3), 'o', ...
           'MarkerSize', 10, ...
           'MarkerFaceColor', [intensity, 0, 0]);
       intensity = max(intensity - 0.2, 0);
   end
end

end