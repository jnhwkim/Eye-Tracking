%% Study on the variation of gaze of two types of long fixation,
%%  one is for alerted sequences and the other is for neutral 
%%  sequences.

function [V, P] = anal_gaze()

%% Path to reference
addpath('../ltm');
addpath('../model');
addpath('..');

figurestyle(15);

scope = 3 : 30;

%% Generate data
if ~exist('V', 'var') || ~exist('P', 'var')
    if exist('gaze_var.mat', 'file')
        load('gaze_var.mat');
    else
        V = zeros(size(scope, 2), 4);
        P = zeros(size(scope, 2), 1);
        for i = 1 : size(scope, 2)
            w_size = scope(i)
            [V(i, :), P(i)] = gaze_var(w_size);
        end
        save('gaze_var.mat', 'V', 'P');
    end
end

%% Figure
f = figure(1);
set(f, 'Position', [100 300 500 380]);
plot(3:30, P, 'k');
hold on;
plot(get(gca,'xlim'), [0.05 0.05], 'Color', 'b');
xlabel('Window Size (ms)');
ylabel('p-value');
set(get(gca,'ylabel'),'FontSize',18)
set(gca, 'XTick', 3:3:30, 'XTickLabel', 100:100:1000);

% Adjust xlabel y-position
y_offset = 0.04;
xlabel_pos = get(get(gca,'xlabel'),'position');
ylimits = get(gca,'ylim');
xlabel_pos(2) = ylimits(1) - y_offset;
set(get(gca,'xlabel'), 'position', xlabel_pos);
set(get(gca,'xlabel'),'FontSize',18)

figuresave('gaze_var');
        
end

