%% Study on variation of gaze of two tpyes of long fixation,
%%  one is for alerted sequences and the other is for neutral 
%%  sequences.

%% Path to reference
addpath('../ltm');

%% Get the duration of fixation and variance of gaze points.
[LF, S] = gen_fix_valid();

%% Long Fixation Types
[participant_id,L1,L2,L3,L4,L5,L6,L7,L8] = import_types('types_long.csv');
types = [L1,L2,L3,L4,L5,L6,L7,L8];

%% Classify the variances
variance_types = {[],[]};
for i = 1 : size(types, 1)
    for j = 1 : size(types, 2)
        if strcmp(types{i,j}, 'Alert')
            variance_types{1} = [variance_types{1}; S(i,j,:)];
        else
            variance_types{2} = [variance_types{2}; S(i,j,:)];
        end
    end
end

%% Results
A_var = variance_types{1};
N_var = variance_types{2};

median(A_var)
median(N_var)

% Total variance
[h, p] = ttest2(A_var(:,1,1)+A_var(:,1,2), ...
                N_var(:,1,1)+N_var(:,1,2))