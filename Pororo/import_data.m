function [RecordingTimestamp1,FixationIndex1,SaccadeIndex1,GazeEventType1,GazeEventDuration1,FixationPointXADCSpx1,FixationPointYADCSpx1,GazePointXADCSpx1,GazePointYADCSpx1,FixationPointXMCSpx1,FixationPointYMCSpx1,GazePointXMCSpx1,GazePointYMCSpx1] = import_data(filename, startRow, endRow)
%IMPORTFILE �ؽ�Ʈ ������ ������ �����͸� �� ���ͷ� �����ɴϴ�.
%   [RECORDINGTIMESTAMP1,FIXATIONINDEX1,SACCADEINDEX1,GAZEEVENTTYPE1,GAZEEVENTDURATION1,FIXATIONPOINTXADCSPX1,FIXATIONPOINTYADCSPX1,GAZEPOINTXADCSPX1,GAZEPOINTYADCSPX1,FIXATIONPOINTXMCSPX1,FIXATIONPOINTYMCSPX1,GAZEPOINTXMCSPX1,GAZEPOINTYMCSPX1]
%   = IMPORTFILE(FILENAME) ����Ʈ ���� �׸��� �ؽ�Ʈ ���� FILENAME���� �����͸� �н��ϴ�.
%
%   [RECORDINGTIMESTAMP1,FIXATIONINDEX1,SACCADEINDEX1,GAZEEVENTTYPE1,GAZEEVENTDURATION1,FIXATIONPOINTXADCSPX1,FIXATIONPOINTYADCSPX1,GAZEPOINTXADCSPX1,GAZEPOINTYADCSPX1,FIXATIONPOINTXMCSPX1,FIXATIONPOINTYMCSPX1,GAZEPOINTXMCSPX1,GAZEPOINTYMCSPX1]
%   = IMPORTFILE(FILENAME, STARTROW, ENDROW) �ؽ�Ʈ ���� FILENAME�� STARTROW �࿡��
%   ENDROW ����� �����͸� �н��ϴ�.
%
% Example:
%   [RecordingTimestamp1,FixationIndex1,SaccadeIndex1,GazeEventType1,GazeEventDuration1,FixationPointXADCSpx1,FixationPointYADCSpx1,GazePointXADCSpx1,GazePointYADCSpx1,FixationPointXMCSpx1,FixationPointYMCSpx1,GazePointXMCSpx1,GazePointYMCSpx1]
%   = importfile('pororo_s03p01_bjlee.tsv',2, 43944);
%
%    TEXTSCAN�� �����Ͻʽÿ�.

% MATLAB���� ���� ��¥�� �ڵ� ������: 2014/06/07 16:24:21

%% ������ �ʱ�ȭ�մϴ�.
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% �� �ؽ�Ʈ ���ο� ���� ���� ���ڿ�:
%   ��1: double (%f)
%	��2: double (%f)
%   ��3: double (%f)
%	��4: �ؽ�Ʈ (%s)
%   ��5: double (%f)
%	��6: double (%f)
%   ��7: double (%f)
%	��8: double (%f)
%   ��9: double (%f)
%	��10: double (%f)
%   ��11: double (%f)
%	��12: double (%f)
%   ��13: double (%f)
% �ڼ��� ������ ���� �������� TEXTSCAN�� �����Ͻʽÿ�.
formatSpec = '%f%f%f%s%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% �ؽ�Ʈ ������ ���ϴ�.
fileID = fopen(filename,'r');

%% ���� ���ڿ��� ���� ������ ���� �н��ϴ�.
% �� ȣ���� �� �ڵ带 �����ϴ� �� ���Ǵ� ������ ����ü�� ������� �մϴ�. �ٸ� ���Ͽ� ���� ������ �߻��ϴ� ��� �������� ������
% �ڵ带 �ٽ� �����Ͻʽÿ�.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% �ؽ�Ʈ ������ �ݽ��ϴ�.
fclose(fileID);

%% ������ �� ���� �����Ϳ� ���� ���� ó�� ���Դϴ�.
% �������� �������� ������ �� ���� �����Ϳ� ��Ģ�� ������� �ʾ����Ƿ� ���� ó�� �ڵ尡 ���Ե��� �ʾҽ��ϴ�. ������ �� ����
% �����Ϳ� ����� �ڵ带 �����Ϸ��� ���Ͽ��� ������ �� ���� ���� �����ϰ� ��ũ��Ʈ�� �ٽ� �����Ͻʽÿ�.

%% ������ �迭�� �� ���� �̸����� �Ҵ�
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

