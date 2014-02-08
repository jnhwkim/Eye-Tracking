%% Load the data
% Note that (the number of row - 1) 33.3 means a time point in millseconds.
if isempty(irCoords)
    irCoords = importIRMarkersFile('Maisy/maisy1_ir_markers.tsv',1, 11043);
end
% It consumes your precious 13 seconds on the modern computer.
% IRMarkerIDs can be used to validate the IRMarkers data.
if isempty(sCoords)
    [sCoords, IRMarkerIDs] = importEyeTrackingFile('Maisy/maisy1_eye_tracking_jhkim.tsv', 2, 11044);
end

%% IR Marker Mapping Information
irMap = irMap();

%% Screen Size
sSize = [640 480];
%% Media Size
% Needed to be adjusted to fit to the height of the screen.
mSize = [720 544];

%% Get the media coordinations
mCoord = mediaCoord(sCoords, irCoords, irMap, sSize, mSize);

%% Test Case
EPSILON = 0.05;
q1 = mCoord(1,:);
a1 = [0.185, 1.216];
d1 = pdist([q1; a1]);
q2 = mCoord(1001, :);
a2 = [0.364, 0.253];
d2 = pdist([q2; a2]);

if (d1 < EPSILON) && (d2 < EPSILON)
    fprintf('You did!\n');
else
    fprintf('Wrong! Distance is %d and %d\n', d1, d2);
end
