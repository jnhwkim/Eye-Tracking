function results = simpletest
    NKNOTS = 10;
    REPEAT = 3;
    results = zeros(3, NKNOTS);
    for i = 1 : NKNOTS
        subresults = zeros(3, 3);
        for j = 1 : REPEAT
            [X, labels] = do_simpletest((i-1)/NKNOTS);
            subresults(:, j) = X;
        end
        results(:, i) = mean(subresults, 2);
    end
    
    % Visualization
    plot(results');
    % ylabel('Recall Score', 'FontSize', 13);
    set(gca, 'XTick', 1:3, 'XTickLabel', labels);
    set(gca, 'FontSize', 13);
    box off;
end

function [X, labels] = do_simpletest(lazy_on_neutral)
% SIMPLETEST      simple test on active long fixation
%   [X, labels] = SIMPLETEST(lazy_on_neutral) tests the simulation
%                 being lazy with the given probabiltiy on neutral
%                 stimuli seen.

%% Simple Active Long Fixation Modeling
VERBOSE = 2;

%% Series of Saliency Maps
WIDTH = 2;
HEIGHT = 2;
LENGTH = 100000;
SMOOTHNESS = 5;

LONG_THRESHOLD = 5;
ALERT_THRESHOLD = 0.10;
LAZY_THRESHOLD = 0.20;

NEGLECT_FACTOR = 0.01;
ENHANCE_FACTOR = 1.10;

salmap = rand(LENGTH, WIDTH, HEIGHT);

%% Smoothing
for iter = 1 : SMOOTHNESS
    salmapn = salmap;
    for i = 2 : LENGTH - 1
        salmapn(i,:,:) = salmapn(i-1,:,:) / 2 + salmapn(i+1,:,:) / 2;
    end
    salmap = salmapn;
end

%% Normalization
for i = 1 : LENGTH
    salmap(i,:,:) = salmap(i,:,:) / sum(sum(salmap(i,:,:)));
end

if 4 <= VERBOSE 
    plot(squeeze(salmap(1:100,1,:)));
    plot(squeeze(salmap(1:100,2,:)));
end

%% Gaze Simulation
gaze = zeros(LENGTH, 1);
sali = zeros(LENGTH, 1);
dura = zeros(LENGTH, 1);
selc = zeros(LENGTH, 1);

for i = 1 : LENGTH
    prob = salmap(i,:,:); prob = prob(:); prob_cum = prob;
    target = rand(1);
    sali(i) = find(prob==max(prob));
    if prob(sali(i)) < ALERT_THRESHOLD + mean(prob(find(prob~=max(prob))))
        sali(i) = -1;
    end
    lazy = false;
    if 1 < i && rand(1) < lazy_on_neutral && selc(i-1) < LAZY_THRESHOLD 
        gaze(i,1) = gaze(i-1,1);
        selc(i,1) = prob(gaze(i,1)) * NEGLECT_FACTOR;
        lazy = true;
    else
        for j = 1 : HEIGHT * WIDTH
            if 1 ~= j
                prob_cum(j) = prob_cum(j-1) + prob_cum(j);
            end
            if target < prob_cum(j)
                gaze(i,1) = j;
                selc(i,1) = prob(j);
                break;
            end
        end
    end
    flag = true;
    for j = 1 : LONG_THRESHOLD - 1
        if (i > LONG_THRESHOLD - 1 && gaze(i-j+1) ~= gaze(i-j)) || lazy
            flag = false;
            break;
        end
    end
    if LONG_THRESHOLD <= i && flag
        dura(i-LONG_THRESHOLD+1:i,1) = 1;
        if ~lazy
            selc(i-LONG_THRESHOLD+1:i,1) = ...
                min(selc(i-LONG_THRESHOLD+1:i,1) * ENHANCE_FACTOR, 1);
        end
    end
end

%% Report
LA = selc(find(dura==1&gaze==sali));
SA = selc(find(dura==0&gaze==sali));
LN = selc(find(dura==1&gaze~=sali));
SN = selc(find(dura==0&gaze~=sali));

count_table = zeros(2,2);
count_table(1,1) = size(LA, 1);
count_table(1,2) = size(SA, 1);
count_table(2,1) = size(LN, 1);
count_table(2,2) = size(SN, 1);

if 3 <= VERBOSE
    fprintf('\tLONG\tSHORT\n');
    fprintf('---------------------\n');
    fprintf('ALERT\t%d\t%d\n', count_table(1,1), count_table(1,2));
    fprintf('NEUTRAL\t%d\t%d\n', count_table(2,1), count_table(2,2));
end
    
recall_table = zeros(2,2);
recall_table(1,1) = mean(LA, 1);
recall_table(1,2) = mean(SA, 1);
recall_table(2,1) = mean(LN, 1);
recall_table(2,2) = mean(SN, 1);

if 3 <= VERBOSE
    fprintf('\tLONG\tSHORT\n');
    fprintf('---------------------\n');
    fprintf('ALERT\t%.4f\t%.4f\n', recall_table(1,1), recall_table(1,2));
    fprintf('NEUTRAL\t%.4f\t%.4f\n', recall_table(2,1), recall_table(2,2));
end
    
%% Visualization
if 3 <= VERBOSE
    bar(recall_table');
    ylabel('Recall Score', 'FontSize', 13);
    Labels = {'Long','Short'};
    set(gca, 'XTick', 1:3, 'XTickLabel', Labels);
    set(gca, 'FontSize', 13);
    box off;
end

%% Data analysis
nA = size(LA, 1) + size(SA, 1);
score_table = count_table .* recall_table;
score_mean = [(sum(score_table(1,:),2)/sum(count_table(1,:), 2));
              (sum(score_table(2,:),2)/sum(count_table(2,:), 2))];
num_saccades = 0;
for i = 2 : LENGTH
    if gaze(i-1) ~= gaze(i)
        num_saccades = num_saccades + 1;
    end
end

%% Indicators
labels = {'Sensitivity', 'Alert Learning', 'Saccadic Cost'};
% long_ratio_on_alert = size(LA, 1) / nA;
sensitivity = nA / size(find(sali~=-1), 1);
alert_lr = score_mean(1) / score_mean(2);
if 2 <= VERBOSE
    fprintf('Alert Score: %.4f, Neutral Score: %.4f\n', ...
        score_mean(1), score_mean(2));
end
saccadic_cost = num_saccades / LENGTH;

if 3 <= VERBOSE
    %fprintf('p(L|A): %.4f\n', long_ratio_on_alert);
    fprintf('%s: %.4f\n', labels{1}, sensitivity);
    fprintf('%s: %.4f\n', labels{2}, alert_lr);
    fprintf('%s: %.4f\n', labels{3}, saccadic_cost);
end

X = [sensitivity; alert_lr; saccadic_cost];

end