function [ types, participant_id ] = get_types
%GET_TYPES Summary of this function goes here
%   Detailed explanation goes here

%% Long Fixation Types
[participant_id,L1,L2,L3,L4,L5,L6,L7,L8] = import_types('types_long.csv');
L_types = [L1,L2,L3,L4,L5,L6,L7,L8];

%% Short Fixation Types
[participant_id,S1,S2,S3,S4,S5,S6,S7,S8] = import_types('types_short.csv');
S_types = [S1,S2,S3,S4,S5,S6,S7,S8];

types = zeros(size(L_types, 1), 16); 
%% All Fixation Types
for i = 1 : size(L_types, 1)
    for j = 1 : size(L_types, 2)
        if strcmp(L_types{i,j}, 'Alert')
            types(i,j) = 1;
        else
            types(i,j) = 0;
        end
        types(i,j+8) = str2num(S_types{i,j});
    end
end

%% Clear unused variables
for i = 1 : 8
    clear(strcat('L', int2str(i)));
    clear(strcat('S', int2str(i)));
end

end

