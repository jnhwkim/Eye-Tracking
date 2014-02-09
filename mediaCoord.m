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

mCoord = zeros(size(sCoords));

for i = 1 : size(irCoords, 1)
    
    % Counting IR Markers whose Media Cooridnate is available
    markCount = 0;
    for j = 1 : size(irCoords, 2)
        if irCoords(i, j, 1) ~= 0
            if irMap(irCoords(i,j,1),1) ~= -100 && irMap(irCoords(i,j,1),2) ~= -100
               markCount = markCount + 1; 
            end
        end
    end
    
    if markCount ~= 0
        markSCoord = zeros(3, markCount);
        markMCoord = zeros(3, markCount);
        mindex = 1;
        for k = 1 : size(irCoords, 2)
            if irCoords(i, k, 1) ~= 0
                if irMap(irCoords(i,k,1),1) ~= -100 && irMap(irCoords(i,k,1),2) ~= -100
                    markSCoord(:, mindex) = [irCoords(i, k, 2); irCoords(i, k ,3); 1];
                    markMCoord(:, mindex) = [irMap(irCoords(i, k, 1), 1); irMap(irCoords(i, k, 1), 2); 1];
                    mindex = mindex + 1;
                end
            end
        end

        TempMat = markSCoord * transpose(markSCoord);
        if det(TempMat) ~= 0
            AMat = markMCoord * transpose(markSCoord) * inv(TempMat);
        else 
            AMat = markMCoord * transpose(markSCoord) * pinv(TempMat);
        end
        MMat = AMat * [sCoords(i,1); sCoords(i,2); 1];
        mCoord(i,:) = [MMat(1,1), MMat(2,1)];
    else
        mCoord(i,:) = [-1000, -1000];
    end

    
    % Find x and y in a unit space.


    % and translate x using sSize and mSize


    % save the media coordinations.

end
