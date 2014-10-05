function [ X1, y1 ] = timeslice( X, y, span, skip, length )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

num_frames = size(X, 2) / span;
idx = 1 : skip : num_frames - length + 1;
X1 = zeros(size(X, 1) * size(idx, 2), span * length);
y1 = zeros(size(X, 1) * size(idx, 2), 1);
count = 1;

for i = 1 : size(X, 1)
    for j = idx
        X1(count, :) = X(i, 1 + (j - 1) * span : (j - 1) * span + span * length);
        y1(count, 1) = y(i);
        count = count + 1;
    end
end