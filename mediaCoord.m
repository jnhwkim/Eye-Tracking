% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim
% Created: Feb 4 2014
%
% It converted screen coordinations (640x480) to the given media 
% coordinations by using the infrared markers' locations.
%
% usage: mediaCoord(sCoords, irCoords, irMap, sSize)
%           sCoords = coordinations of screen
%           irCoords = coordinations of infrared markers
%           irMap = mapping IR markers' coordinations to a unit space
%           sSize = screen size
%           mSize = media size
function mCoord = mediaCoord(sCoords, irCoords, irMap, sSize, mSize)
% # of rows check for sCoord, irCoords
N = 0;
mCoord = zeros(size(sCoords));

for i = 1 : N
    % Find x and y in a unit space.
    x = 0;
    y = 0;

    % and translate x using sSize and mSize
    x = x + 0;

    mCoord[i] = [x, y];
end

end
