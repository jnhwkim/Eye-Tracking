% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim
% Created: Feb 9 2014
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
N = size(sCoords, 1);
if N ~= size(irCoords, 1)
    error('The number of rows are mismatched!');
end

% Initialization
mCoord = zeros(size(sCoords));
FAIL = [-1, -1];
BACK_RECOVERY_STEP = 30;

for i = 1 : N
    % Counting IR Markers whose Media Cooridnate is available.
    % Find nonzero indexes of IR Markers
    mIndexes = find(irCoords(i,:,1));
    nzCoords = irCoords(i,mIndexes,:);
    M = size(nzCoords, 2);
    scMat = zeros(3, M);
    mcMat = zeros(3, M);
    count = 1;
    
    % Check the alignment of IR Markers
    if isempty(nzCoords(1,:,1))
        % fprintf('No IR Marker position at %d!\n', i);
        step = 1;
        while step < BACK_RECOVERY_STEP && i-step > 1 && isempty(nzCoords(1,:,1))
            mIndexes = find(irCoords(i-step,:,1));
            nzCoords = irCoords(i-step,mIndexes,:);
            step = step - 1;
        end
        if isempty(nzCoords(1,:,1))
            fprintf('Delayed recovery failed at %d.', i);
            mCoord(i,:) = FAIL;
            continue;
        end
    end
    if isFailedAlignment(irMap(nzCoords(1,:,1), :))
        fprintf('Bad IR Marker positions at %d!\n', i);
        mCoord(i,:) = FAIL;
        continue;
    end
        
    for j = 1 : M
        irIndex = nzCoords(1,j,1);
        irX = nzCoords(1,j,2);
        irY = nzCoords(1,j,3);
        if irMap(irIndex,1) ~= -1 && irMap(irIndex,2) ~= -1
            scMat(:, count) = [irX; irY; 1];
            mcMat(:, count) = [irMap(irIndex, 1); irMap(irIndex, 2); 1];
            count = count + 1;
        end
    end

    % Find the affine matrix A.
    Q = scMat * scMat';
    if det(Q) ~= 0
        A = mcMat * scMat' / Q; % b * inv(A) => b / A
    else 
        A = mcMat * scMat' * pinv(Q);
    end
    
    % Find x and y in a unit space.
    X = A * [sCoords(i,1); sCoords(i,2); 1];
    mCoord(i,:) = [X(1,1), X(2,1)];

    % and translate x using sSize and mSize
end
end

function flag = isFailedAlignment(irMapCoords)
flag = false;
if range(irMapCoords(:,1)) == 0 || range(irMapCoords(:,2)) == 0
    flag = true;
elseif size(irMapCoords, 1) < 3
    flag = true;
end
end