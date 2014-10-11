%% Simple Active Long Fixation Modeling
VERBOSE = 7;

%% Series of Saliency Maps
WIDTH = 2;
HEIGHT = 2;
LENGTH = 100000;
LONG_THRESHOLD = 5;
LAZY_ON_NEUTRAL = 0.1;
LAZYNESS = true;
ENHANCE_FACTOR = 1.5;
NEGLECT_FACTOR = 0.01;
ALERT_THRESHOLD = 0.05;
salmap = rand(LENGTH, WIDTH, HEIGHT);

%% Smoothing
ITER = 5;
for iter = 1 : ITER
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

if 8 <= VERBOSE 
    plot(squeeze(salmap(1:100,1,:)));
    plot(squeeze(salmap(1:100,2,:)));
end

%% Gaze Simulation
gaze = zeros(LENGTH, 1);
sali = zeros(LENGTH, 1);
dura = zeros(LENGTH, 1);
selc = zeros(LENGTH, 1);

for i = 1 : LENGTH
    prob = salmap(i,:,:); prob = prob(:);
    target = rand(1);
    sali(i) = find(prob==max(prob));
    if prob(sali(i)) < ALERT_THRESHOLD + mean(prob(find(prob~=max(prob))))
        sali(i) = -1;
    end
    if LAZYNESS && 1 < i && rand(1) < LAZY_ON_NEUTRAL && sali(i-1) ~= gaze(i-1) 
        gaze(i,1) = gaze(i-1,1);
        selc(i,1) = prob(gaze(i,1)) * NEGLECT_FACTOR;
    else
        for j = 1 : HEIGHT * WIDTH
            if 1 ~= j
                prob(j) = prob(j-1) + prob(j);
            end
            if target < prob(j)
                gaze(i,1) = j;
                selc(i,1) = prob(j);
                break;
            end
        end
    end
    flag = true;
    for j = 1 : LONG_THRESHOLD - 1
        if i > LONG_THRESHOLD - 1 && gaze(i-j+1) ~= gaze(i-j)
            flag = false;
            break;
        end
    end
    if LONG_THRESHOLD <= i && flag
        dura(i-LONG_THRESHOLD+1:i,1) = 1;
        selc(i,1) = min(selc(i,1) * ENHANCE_FACTOR, 1);
    end
end

%% Report
count_table = zeros(2,2);
count_table(1,1) = size(find(dura==1&gaze==sali), 1);
count_table(1,2) = size(find(dura==0&gaze==sali), 1);
count_table(2,1) = size(find(dura==1&gaze~=sali), 1);
count_table(2,2) = size(find(dura==0&gaze~=sali), 1);

fprintf('\tLONG\tSHORT\n');
fprintf('---------------------\n');
fprintf('ALERT\t%d\t%d\n', count_table(1,1), count_table(1,2));
fprintf('NEUTRAL\t%d\t%d\n', count_table(2,1), count_table(2,2));

recall_table = zeros(2,2);
LA = selc(find(dura==1&gaze==sali));
SA = selc(find(dura==0&gaze==sali));
LN = selc(find(dura==1&gaze~=sali));
SN = selc(find(dura==0&gaze~=sali));
recall_table(1,1) = mean(LA, 1);
recall_table(1,2) = mean(SA, 1);
recall_table(2,1) = mean(LN, 1);
recall_table(2,2) = mean(SN, 1);

fprintf('\tLONG\tSHORT\n');
fprintf('---------------------\n');
fprintf('ALERT\t%.4f\t%.4f\n', recall_table(1,1), recall_table(1,2));
fprintf('NEUTRAL\t%.4f\t%.4f\n', recall_table(2,1), recall_table(2,2));

%% Visualization
bar(recall_table');
ylabel('Recall Score', 'FontSize', 13);
Labels = {'Long','Short'};
set(gca, 'XTick', 1:3, 'XTickLabel', Labels);
set(gca, 'FontSize', 13);
box off;

[h, p] = ttest2(0.5+LA/5, 0.5+LN/5);
fprintf('p = %.4f\n', p);
[h, p] = ttest2(0.5+SA/5, 0.5+SN/5);
fprintf('p = %.4f\n', p);