addpath('..');
addpath('../ltm');

%% Fixation Duration and Alert label.
LF = gen_fix_valid();
load('data/valid_label.mat');
Label = reshape(y, [16 11])';

%%
[participant_id,regtime,...
    L_1,L_2,L_3,L_4,L_5,L_6,L_7,L_8,...
    S_1,S_2,S_3,S_4,S_5,S_6,S_7,S_8] = ...
    import_ratings('../ltm/ratings.csv');
    
L = [L_1,L_2,L_3,L_4,L_5,L_6,L_7,L_8];
S = [S_1,S_2,S_3,S_4,S_5,S_6,S_7,S_8];
SCORE = [L, S];

%% Clear unused variables
clear('participant_id'); clear('regtime');
for i = 1:size(L,2)
    clear(strcat('L_', int2str(i)));
    clear(strcat('S_', int2str(i)));
    if i <= 4
        clear(strcat('C_', int2str(i)));
    end
end

% Serialization
LF_ = LF(:);
SCORE_ = SCORE(:);
Label_ = Label(:);

%% Score distribution
dist0 = SCORE_(Label_==0);
dist1 = SCORE_(Label_==1);

%% MFCC for validation data.
load('data/valid_mfcc.mat');
y_est_all = gen_mfcc_alert({X_valid'});
y_est_all = median(round(reshape(y_est_all{1}, [10, 176])));
y_est = zeros(176, 1); y_est(find(y_est_all>0.5), 1) = 1;

%% Test if
mean(SCORE_(find(LF_>1000&y_est==0)))
mean(SCORE_(find(LF_>1000&y_est==1)))
