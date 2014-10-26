%% Study on the variation of gaze of two types of long fixation,
%%  one is for alerted sequences and the other is for neutral 
%%  sequences.

function [V, P] = anal_gaze()

%% Path to reference
addpath('../ltm');

scope = 30 : -1 : 3;

%% Generate data
if ~exist('V', 'var') || ~exist('P', 'var')
    if exist('gaze_var.mat', 'file')
        load('gaze_var.mat');
    else
        V = zeros(size(scope, 2), 4);
        P = zeros(size(scope, 2), 1);
        for i = 1 : size(scope, 2)
            w_size = scope(i)
            [V(i, :), P(i)] = get_gaze_var(w_size);
        end
        save('gaze_var.mat', 'V', 'P');
    end
end
        
end

