function IRMarkers = importIRMarkersFile(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%
% Example:
%   IRMarkers = importIRMarkersFile('Maisy/maisy1_ir_markers.tsv',1, 11043);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2014/02/04 17:31:55

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: double (%f)
%	column2: text (%s)
%   column3: text (%s)
%	column4: text (%s)
%   column5: text (%s)
%	column6: text (%s)
%   column7: text (%s)
%	column8: text (%s)
%   column9: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
fprintf('Loading IR markers data...\n');
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
fprintf('done.\n');

for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
TimeNum = dataArray{:, 1};

%% Make a package
N = size(TimeNum, 1);
NUM_OF_IR_MARKERS = 8;
IRMarkers = zeros(N, NUM_OF_IR_MARKERS, 3);

for i = 1:N
    for j = 1:NUM_OF_IR_MARKERS
        IRMarker = dataArray{:, j+1};
        [cellArray, matches] = strsplit(cell2mat(IRMarker(i)), ':');
        
        if size(matches) > 0
            numArray = cellfun(@str2num, cellArray);
        else
            numArray = [];
        end
        row = [numArray zeros(1, 3 - size(numArray, 2))];
        IRMarkers(i,j,:) = row;
    end
end
