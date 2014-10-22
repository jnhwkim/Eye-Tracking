function [ ratings ] = get_ratings()
%GET_RATINGS get ratings as matrix.
%   Get ratings as matrix.

[participant_id,regtime,...
        L_1,L_2,L_3,L_4,L_5,L_6,L_7,L_8,...
        S_1,S_2,S_3,S_4,S_5,S_6,S_7,S_8,...
        C_1,C_2,C_3,C_4] = import_ratings('ratings.csv');
    
L = [L_1,L_2,L_3,L_4,L_5,L_6,L_7,L_8];
S = [S_1,S_2,S_3,S_4,S_5,S_6,S_7,S_8];

ratings = [L, S];

end

