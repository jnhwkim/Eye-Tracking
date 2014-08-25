% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: August 25 2014
%
% Analysis on LTM test for the participants who have watched the video
% Pororo Season 3.

function anal_ltm_s()
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
    for i = 1:size(L,2)
        clear(strcat('L_', int2str(i)));
        clear(strcat('S_', int2str(i)));
        if i <= size(C,2)
            clear(strcat('C_', int2str(i)));
        end
    end
    
    %% For a report
    L_vec = reshape(L, size(L,1) * size(L,2), 1);
    S_vec = reshape(S, size(S,1) * size(S,2), 1);
    C_vec = reshape(C, size(C,1) * size(C,2), 1);
    types_m = [mean(L_vec),mean(S_vec),mean(C_vec)]
    types_std = [std(L_vec), std(S_vec), std(C_vec)];
    types_sem = [std(L_vec) / sqrt(size(L_vec,1)),...
            std(S_vec) / sqrt(size(S_vec,1)),...
            std(C_vec) / sqrt(size(C_vec,1))]
    
    f = figure(1);
    set(f, 'Position', [100 300 400 250]);
    barwitherr(types_sem, types_m, 0.5, 'b');
    ylabel('Memory Score');
    Labels = {'Long','Short','Not Seen'};
    set(gca, 'XTick', 1:3, 'XTickLabel', Labels);
    axis([0.5 3.5 0 5]);
    
    %% Long Fixation Types
    [participant_id,S1,S2,S3,S4,S5,S6,S7,S8] = import_types('types_short.csv');
    types = [S1,S2,S3,S4,S5,S6,S7,S8];

    %% Clear unused variables
    for i = 1:size(L,2)
        clear(strcat('S', int2str(i)));
    end
    
    %% Classify and count
    labels = {'Alert', 'No Alert'};
    elements = cell(size(labels, 2),1);
    for i = 1:size(labels, 2)
        if strcmp(labels{i}, 'Alert')
            [row,col]=find(strcmp(types, '1'));
        else 
            [row,col]=find(~strcmp(types, '1'));
        end
        for j = 1:size(row,1)
            elements{i} = [elements{i}; S(row(j),col(j))];
        end
    end
    
    %% TTEST2
    [h, p] = ttest2(elements{1}, elements{2})
    
    %% For the second report
    m = zeros(size(elements));
    sem = zeros(size(elements));
    n = zeros(size(elements));
    r = zeros(size(elements));
    for i = 1:size(elements)
        m(i) = mean(elements{i});
        sem(i) = std(elements{i}) / size(elements{i},1);
        n(i) = size(elements{i},1);
        r(i) = n(i) / size([elements{1};elements{2}],1);
    end
    
    [m,sem,n,r]
    
    f = figure(2);
    set(f, 'Position', [600 300 400 250]);
    bar(m, 0.5, 'b');
    ylabel('Memory Score');
    set(gca, 'XTick', 1:2, 'XTickLabel', labels);
    axis([0.5 2.5 0 5]);
    hold on
    plot(get(gca,'xlim'), [types_m(2) types_m(2)]);
       
     %% Statistical significance of each category.
     noc = size(elements, 1);
     p_values = zeros(noc,1);
     for i = 1:noc
        a = elements{i};
        b = [];
        for j = 1:noc
            if j ~= i
                b = [b; elements{j}];
            end
        end
        diff = mean(a) - mean(b);
        
    	[h,p,dist] = sigdiff(L_vec, size(a,1), diff, 1000);
        p_values(i) = p;
     end
     p_values
     
end