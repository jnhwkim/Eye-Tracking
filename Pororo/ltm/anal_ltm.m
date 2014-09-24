% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: Aug. 7 2014
% Updated: Sep. 23 2014
%
% Analysis on LTM test for the participants who have watched the video
% Pororo Season 3.

function anal_ltm()
    % initialize
    close all; 
    
    %% SEM analysis
    [participant_id,regtime,...
        L_1,L_2,L_3,L_4,L_5,L_6,L_7,L_8,...
        S_1,S_2,S_3,S_4,S_5,S_6,S_7,S_8,...
        C_1,C_2,C_3,C_4] = import_ratings('ratings.csv');
    
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
    types_m = [mean(L_vec),mean(S_vec),mean(C_vec)];
    types_std = [std(L_vec), std(S_vec), std(C_vec)];
    types_sem = [std(L_vec) / sqrt(size(L_vec,1)),...
                 std(S_vec) / sqrt(size(S_vec,1)),...
                 std(C_vec) / sqrt(size(C_vec,1))];
    
    %% Figure 1
    f = figure(1);
    set(f, 'Position', [100 300 400 250]);
    barwitherr(2*types_sem, types_m, 0.5, 'b');
    ylabel('Recall Score');
    Labels = {'Long','Short','Not Seen'};
    set(gca, 'XTick', 1:3, 'XTickLabel', Labels);
    axis([0.5 3.5 0 5]);
    
    %% Long Fixation Types
    [participant_id,L1,L2,L3,L4,L5,L6,L7,L8] = import_types('types_long.csv');
    types = [L1,L2,L3,L4,L5,L6,L7,L8];

    %% Clear unused variables
    for i = 1:size(L,2)
        clear(strcat('L', int2str(i)));
    end
    
    %% Classify and count
    labels = {'Alert', 'No Alert'};
    elements = cell(size(labels, 2),1);
    for i = 1:size(labels, 2)
        if strcmp(labels{i}, 'Alert')
            [row,col]=find(strcmp(types, 'Alert'));
        else 
            [row,col]=find(~strcmp(types, 'Alert'));
        end
        for j = 1:size(row,1)
            elements{i} = [elements{i}; L(row(j),col(j))];
        end
    end
    
    %% Two-sample T-Test
    [h, p] = ttest2(elements{1}, elements{2});
    fprintf('Given Long, Alert? p < %.4f\n', p);
    
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
    elements_L = elements;
    
    %% Figure 2
    f = figure(2);
    set(f, 'Position', [500 300 400 250]);
    barwitherr(2*sem, m, 0.5, 'b');
    ylabel('Recall Score');
    set(gca, 'XTick', 1:2, 'XTickLabel', {'Long, Alert', 'Long, No Alert'});
    axis([0.5 2.5 0 5]);
    hold on
    plot(get(gca,'xlim'), [types_m(1) types_m(1)]);
    % text(1.01,4.71,'*','horizontalalignment','center','FontSize', 18);
    % sigstar([1 2], [p]);
    
    %% Short Fixation Types
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
    elements_S = elements;
    
    %% Two-sample T-Test
    [h, p] = ttest2(elements{1}, elements{2});
    fprintf('Given Short, Alert? p < %.4f\n', p);
    
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
    
    %% Figure 3
    f = figure(3);
    set(f, 'Position', [500 620 400 250]);
    barwitherr(2*sem, m, 0.5, 'b');
    ylabel('Recall Score');
    set(gca, 'XTick', 1:2, 'XTickLabel', {'Short, Alert', 'Short, No Alert'});
    axis([0.5 2.5 0 5]);
    hold on;
    plot(get(gca,'xlim'), [types_m(2) types_m(2)]);
    
    %% Alert Effect
    num_types = size(elements_S, 1);
    elements_ALL = cell(num_types,1);
    for i = 1 : num_types
        elements_ALL{i} = [elements_L{i}; elements_S{i}];
    end
    
    %% For the third report
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
    
    m = [m; types_m(3)];
    sem = [sem; types_sem(3)];
    
    %% Figure 4
    f = figure(4);
    set(f, 'Position', [100 620 400 250]);
    barwitherr(2*sem, m, 0.5, 'b');
    ylabel('Recall Score');
    Labels = {'Alert','No Alert','Not Seen'};
    set(gca, 'XTick', 1:3, 'XTickLabel', Labels);
    axis([0.5 3.5 0 5]);
    
    %% Two-sample T-Test
    [h, p] = ttest2(elements_ALL{1}, elements_ALL{2});
    fprintf('Alert? p < %.4f\n', p);
     
end