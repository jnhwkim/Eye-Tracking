function [ X1, y1 ] = make_evenly( X, y )
%MAKE_EVENLY Summary of this function goes here
%   Detailed explanation goes here

    num_smaller = size(find(y==1), 1);
    counters = randsample(find(y==0), num_smaller);
    idx = [counters; find(y==1)];
    idx = idx(randperm(length(idx)));
    y1 = y(idx);
    X1 = X(idx, :);

end

