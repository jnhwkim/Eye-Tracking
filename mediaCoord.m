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
%% Fixed variables
LT_MEDIA_FRCOORD =  [0.19 0.1]; % Position of media's left top corner in Frame coordinate
FR2ME =             mSize ./ [0.62 0.8]; % Conversion factor : Frame to Media
NO_OUTPUT =         [-1 -1];
FRAME_SPACING =     [4 2];
N =                 size(sCoords, 1);

%% Sanity check : # of rows check for sCoord, irCoords
if N ~= size(irCoords,1)
    error('Not the same number of entries: sCoords and irCoords')
end

mCoord = zeros(size(sCoords));
for i = 1 : N
    %% Is recorded?
    bRec = isnan(sCoords(i,:));
    if bRec(1) == 1 || bRec(2) == 2
        fprintf('%d : eye movement not recorded\n', i)
        mCoord(i,:) = NO_OUTPUT;
        continue
    end
    
    %% Pick 3 IR markers not on the same line
    selectedMKs = pick3IRMarkers(nonzeros(irCoords(i,:,1))', irMap);
    if selectedMKs == -1
        % Fewer than 3 markers or on the same line
        fprintf('%d : fewer than 3 IR markers\n', i)
        mCoord(i,:) = NO_OUTPUT;
        continue
    elseif selectedMKs == -2
        % On the same line
        fprintf('%d : no three IR markers not on the same line\n', i)
        mCoord(i,:) = NO_OUTPUT;
        continue
    end
    
    %% Get screen coordinate of IR markers
    irSelected = zeros(3,3); % 3 (markerID, x,y) of selected IR markers
    irSelected(1,:) = irCoords(i,selectedMKs(1),:);
    irSelected(2,:) = irCoords(i,selectedMKs(2),:);
    irSelected(3,:) = irCoords(i,selectedMKs(3),:);
    
    %% Get basis of Frame edge
    fromLT = zeros(3,2); % # of spacing from the "Left Top" IR marker
    fromLT(1,:) = irMap(irSelected(1,1),:) .* FRAME_SPACING;
    fromLT(2,:) = irMap(irSelected(2,1),:) .* FRAME_SPACING;
    fromLT(3,:) = irMap(irSelected(3,1),:) .* FRAME_SPACING;
    
    C = ones(3,3); % Coefficients
    C(1,2:3) = fromLT(1, :);
    C(2,2:3) = fromLT(2, :);
    C(3,2:3) = fromLT(3, :);
    
    frameBasis = C \ irSelected(:,2:3);
    % frameBasis(1,:) : sCoord of LT IR marker
    % frameBasis(2,:) : x basis : horizontal spacing between IR markers  
    % frameBasis(3,:) : y basis : vertical spacing between IR markers
    
    %% Screen pixel coordinate (640, 480) to Frame coordinate (1,1)
    Sc2Fr = frameBasis(2:3,:)';
    mCoord_temp = sCoords(i,:); % Original Screen pixel coordinate
    mCoord_temp = mCoord_temp - frameBasis(1,:); % Translation wrt LT IR marker
    mCoord_temp = (Sc2Fr \ mCoord_temp')' ./ FRAME_SPACING; % Representation wrt Frame coordinate
    
    %% Frame coordinate (1,1) to Media pixel coordinate (720,544)
    mCoord_temp = mCoord_temp - LT_MEDIA_FRCOORD; % Translation wrt LT corner of Media
    mCoord_temp = mCoord_temp .* FR2ME; % Conversion into Media pixel

    %% Incert calculated value
    mCoord(i,:) = mCoord_temp;
end

end

function selectedIDs = pick3IRMarkers(IRMarkerIDs, irMap)
% pick3IRMarkers returns indices of 3 IR markers
% IRMarkerIDs : an array of IR marker IDs, trailing zeros are tolarable (1xN)
% irMap : positional information of each IR marker (Nx2)
% selectedIDs : indices of 3 IR markers in IRMarkerIDs (1x3)
%               or an inter indicating exceptional case (-1 or -2)

% Sanity check : fewer than 3 IR markers?
N = size(nonzeros(IRMarkerIDs),1);
if N < 3
    selectedIDs = -1;
    return
end

% Pick 3 markers not on the same line
for i = 1:N
    M_1 = irMap(IRMarkerIDs(i), :);
    for j = i+1:N
        M_2 = irMap(IRMarkerIDs(j), :);
        for k =j+1:N
            M_3 = irMap(IRMarkerIDs(k), :);
            
            % Is three point on the same line?
            bVertical = M_1(1) == M_2(1) == M_3(1);
            bHorizontal = M_1(2) == M_2(2) == M_3(2);
            if ~(bVertical || bHorizontal)
                selectedIDs = [i, j, k];
                return
            end
        end
    end
end

% No markers on the same line
selectedIDs = -2;
end
