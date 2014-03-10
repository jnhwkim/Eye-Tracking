% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim
% Created: Feb 9 2014
%
% show fixation points on the image.
%
function showFixation(time, fixations)

figure;
%data = imread(strcat('pororo_1_',time,'.bmp'));
%imagesc([0,1],[0,1], data);
data = imread(strcat('pororo_1_3069.bmp'));
imagesc([0,1],[0,1], data);

hold on;
for i=1:size(fixations,1)
   if abs(fixations(i,1) - str2double(time)) < 34
       plot(fixations(i,2), fixations(i,3), '+');
   end
end

end