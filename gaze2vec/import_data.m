function [RecordingTimestamp1,FixationIndex1,SaccadeIndex1,GazeEventType1,GazeEventDuration1,FixationPointXADCSpx1,FixationPointYADCSpx1,GazePointXADCSpx1,GazePointYADCSpx1,FixationPointXMCSpx1,FixationPointYMCSpx1,GazePointXMCSpx1,GazePointYMCSpx1] = import_data(filename, startRow, endRow)
%IMPORTFILE 텍스트 파일의 숫자형 데이터를 열 벡터로 가져옵니다.
%   [RECORDINGTIMESTAMP1,FIXATIONINDEX1,SACCADEINDEX1,GAZEEVENTTYPE1,GAZEEVENTDURATION1,FIXATIONPOINTXADCSPX1,FIXATIONPOINTYADCSPX1,GAZEPOINTXADCSPX1,GAZEPOINTYADCSPX1,FIXATIONPOINTXMCSPX1,FIXATIONPOINTYMCSPX1,GAZEPOINTXMCSPX1,GAZEPOINTYMCSPX1]
%   = IMPORTFILE(FILENAME) 디폴트 선택 항목의 텍스트 파일 FILENAME에서 데이터를 읽습니다.
%
%   [RECORDINGTIMESTAMP1,FIXATIONINDEX1,SACCADEINDEX1,GAZEEVENTTYPE1,GAZEEVENTDURATION1,FIXATIONPOINTXADCSPX1,FIXATIONPOINTYADCSPX1,GAZEPOINTXADCSPX1,GAZEPOINTYADCSPX1,FIXATIONPOINTXMCSPX1,FIXATIONPOINTYMCSPX1,GAZEPOINTXMCSPX1,GAZEPOINTYMCSPX1]
%   = IMPORTFILE(FILENAME, STARTROW, ENDROW) 텍스트 파일 FILENAME의 STARTROW 행에서
%   ENDROW 행까지 데이터를 읽습니다.
%
% Example:
%   [RecordingTimestamp1,FixationIndex1,SaccadeIndex1,GazeEventType1,GazeEventDuration1,FixationPointXADCSpx1,FixationPointYADCSpx1,GazePointXADCSpx1,GazePointYADCSpx1,FixationPointXMCSpx1,FixationPointYMCSpx1,GazePointXMCSpx1,GazePointYMCSpx1]
%   = importfile('pororo_s03p01_bjlee.tsv',2, 43944);
%
%    TEXTSCAN도 참조하십시오.

% MATLAB에서 다음 날짜에 자동 생성됨: 2014/06/07 16:24:21

%% 변수를 초기화합니다.
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% 각 텍스트 라인에 대한 형식 문자열:
%   열1: double (%f)
%	열2: double (%f)
%   열3: double (%f)
%	열4: 텍스트 (%s)
%   열5: double (%f)
%	열6: double (%f)
%   열7: double (%f)
%	열8: double (%f)
%   열9: double (%f)
%	열10: double (%f)
%   열11: double (%f)
%	열12: double (%f)
%   열13: double (%f)
% 자세한 내용은 도움말 문서에서 TEXTSCAN을 참조하십시오.
formatSpec = '%f%f%f%s%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% 텍스트 파일을 엽니다.
fileID = fopen(filename,'r');

%% 형식 문자열에 따라 데이터 열을 읽습니다.
% 이 호출은 이 코드를 생성하는 데 사용되는 파일의 구조체를 기반으로 합니다. 다른 파일에 대한 오류가 발생하는 경우 가져오기 툴에서
% 코드를 다시 생성하십시오.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% 텍스트 파일을 닫습니다.
fclose(fileID);

%% 가져올 수 없는 데이터에 대한 사후 처리 중입니다.
% 가져오기 과정에서 가져올 수 없는 데이터에 규칙이 적용되지 않았으므로 사후 처리 코드가 포함되지 않았습니다. 가져올 수 없는
% 데이터에 사용할 코드를 생성하려면 파일에서 가져올 수 없는 셀을 선택하고 스크립트를 다시 생성하십시오.

%% 가져온 배열을 열 변수 이름으로 할당
RecordingTimestamp1 = dataArray{:, 1};
FixationIndex1 = dataArray{:, 2};
SaccadeIndex1 = dataArray{:, 3};
GazeEventType1 = dataArray{:, 4};
GazeEventDuration1 = dataArray{:, 5};
FixationPointXADCSpx1 = dataArray{:, 6};
FixationPointYADCSpx1 = dataArray{:, 7};
GazePointXADCSpx1 = dataArray{:, 8};
GazePointYADCSpx1 = dataArray{:, 9};
FixationPointXMCSpx1 = dataArray{:, 10};
FixationPointYMCSpx1 = dataArray{:, 11};
GazePointXMCSpx1 = dataArray{:, 12};
GazePointYMCSpx1 = dataArray{:, 13};

