% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: Sep 25 2014
%
% Get the timestamp list for validation sequences in milliseconds.

%% Preliminary variables.
uidx = get_valid_idx();
type = 'fbes';
DATA = load(sprintf('data/%s/train_%s.mat', type, type));
X_all = DATA.X;
y_all = DATA.y;
if strcmp('fbes', type)
    TRAIN_DATA_SIZE = 1000;
    n = TRAIN_DATA_SIZE;
else
    n = size(X_all, 1);
end
FOLD = 5;

%% Exclude Validation set
z = zeros(n, 1);
chk = zeros(size(X_all, 1), 1);
tag = 1;

for i = 1 : n
    if find(ismember(uidx, i))
        z(i) = -1;
    else
        z(i) = tag;
        tag = mod(tag, FOLD) + 1;
    end
end

if strcmp('fbes', type)
    z0 = z;
    z = zeros(size(X_all, 1), 1);
    DELAY = 40;
    FEATURE_NUM = 398;
    SAMPLING_NUM = 18;
    for i = 1 : TRAIN_DATA_SIZE
        z((i - 1) * SAMPLING_NUM + 1 : i  * SAMPLING_NUM, 1) = ...
            ones(SAMPLING_NUM, 1) * z0(i,1);
    end
end

for i = 1 : FOLD
    test_idx = FOLD+1-i;
    X = X_all(find(z==test_idx),:);
    y = y_all(find(z==test_idx));
    save(sprintf('data/%s/test%d_%s.mat', type, i, type), 'X', 'y');
    X = X_all(find(z~=test_idx & z~=-1),:);
    y = y_all(find(z~=test_idx & z~=-1));
    save(sprintf('data/%s/train%d_%s.mat', type, i, type), 'X', 'y');
    % check code
    chk(find(z==test_idx)) = chk(find(z==test_idx)) + 1;
end

%% Validation assertion.
if strcmp('fbes', type)
    assert(size(chk(chk==0),1) == size(uidx,1) * SAMPLING_NUM);
else
    assert(size(chk(chk==0),1) == size(uidx,1));
end
    