function show_salmap( X, row )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

figure;
for i = 1 : size(X, 2) / 374
    imagesc(reshape(X(1,1+17*22*(i-1):17*22*(i+0)), [17 22]));
    pause;
end

end

