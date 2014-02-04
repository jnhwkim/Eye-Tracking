% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim
% Created: Jan 12 2014
%
% It shows the multiple images in a table.
%
% usage: showImages(X(:,:,:,1:10:90))
%        (X is a 32 * 32 * 3 * N matrix)
function showImages(X)

w = size(X, 1);
h = size(X, 2);
c = size(X, 3);
N = size(X, 4);
W = ceil(sqrt(N));
H = ceil(N / W);
img = [];

for i = 1 : H
  row = [];
  for j = 1 : W
    idx = (i - 1) * W + j;
    if idx > N
      row = [row zeros(w, h, c)];
    else
      row = [row X(:,:,:,idx)];
    end
  end
  img = [img; row];
end

imagesc(img);

end
