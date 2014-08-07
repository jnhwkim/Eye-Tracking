% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: August 7 2014
%
% Analysis on LTM test for the participants who have watched the video
% Pororo Season 3.

function anal_ltm()
    %% SEM analysis
    [participant_id,regtime,...
        L_1,L_2,L_3,L_4,L_5,L_6,L_7,L_8,...
        S_1,S_2,S_3,S_4,S_5,S_6,S_7,S_8,...
        C_1,C_2,C_3,C_4] = import_pororo3('pororo3.csv');
    
    L = [L_1,L_2,L_3,L_4,L_5,L_6,L_7,L_8];
    S = [S_1,S_2,S_3,S_4,S_5,S_6,S_7,S_8];
    C = [C_1,C_2,C_3,C_4];
    
    %% Clear unused variables
    clear('participant_id'); clear('regtime');
    for i = 1:8
        clear(strcat('L_', int2str(i)));
        clear(strcat('S_', int2str(i)));
        if i <= 4
            clear(strcat('C_', int2str(i)));
        end
    end
    
    %% For a report
    sem = [std(mean(L,2)),std(mean(S,2)),std(mean(C,2))];
    m = [mean(mean(L,2)),mean(mean(S,2)),mean(mean(C,2))];
    
%     barwitherr(sem, m, 0.5);
%     Labels = {'Long','Short','Control'};
%     set(gca, 'XTick', 1:3, 'XTickLabel', Labels);
    
    %% Long Fixation Types
    [participant_id,L1,L2,L3,L4,L5,L6,L7,L8] = import_types('types.csv');
    types = [L1,L2,L3,L4,L5,L6,L7,L8];

    %% Clear unused variables
    for i = 1:8
        clear(strcat('L', int2str(i)));
    end
    
end