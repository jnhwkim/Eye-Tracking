function [x, y] = scalar2pos(scalar, scale)
%SCALAR2POS Decode a given scalar to x, y position
%   the position x, y are on the 2D space (scale x scale).

    x = floor(scalar / scale) + 1;
    y = floor(mod(scalar, scale));

end

