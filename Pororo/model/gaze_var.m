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

m_Avar = median(squeeze(A_var));
m_Nvar = median(squeeze(N_var));

fprintf('Median of variances for Alert = %.2f + %.2f\n', m_Avar(1), m_Avar(2));
fprintf('Median of variances for Neutral = %.2f + %.2f\n', m_Nvar(1), m_Nvar(2));

% Total variance
[h, p] = ttest2(A_var(:,1,1)+A_var(:,1,2), ...
                N_var(:,1,1)+N_var(:,1,2));

fprintf('Statistical Significance,  p = %.4f\n', p);
            
% Ratings
ratings = get_ratings();

% Sum of Variance X, Y
SS = S(:,:,1) + S(:,:,2);

A_Var = squeeze(A_var(:,1,1)+A_var(:,1,2));
N_Var = squeeze(N_var(:,1,1)+N_var(:,1,2));

boxplot([A_Var;N_Var], [ones(19,1);zeros(69,1)])