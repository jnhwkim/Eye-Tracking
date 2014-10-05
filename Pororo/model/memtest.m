%% Memory Test

% Load grayscaled training data (size =1000).
load('data/gray/train_gray.mat');
X = (X - min(min(X))) / (max(max(X))-min(min(X)));
X1 = X;
y1 = y;
load('data/saliency/train_saliency.mat');
X = (X - min(min(X))) / (max(max(X))-min(min(X)));
X = X .* X1;
y = y1;

% Window sliding (window size = 1000 sec
[X1,y1] = timeslice(X, y, 374, 2, 2);

% Export as leveldb repository.
export_leveldb(X1, y1, 17, size(X1,2)/17, 'gs', false);

[X2, y2] = make_evenly(X1, y1);

% Export as leveldb repository.
export_leveldb(X2, y2, 17, size(X1,2)/17, 'gs_even', false);

% Export as leveldb repository.
X_test0 = X2(find(y2==0),:);
y_test0 = y2(find(y2==0),:);
export_leveldb(X_test0, y_test0, 17, size(X1,2)/17, 'gs_test0', false);

X_test1 = X2(find(y2==1),:);
y_test1 = y2(find(y2==1),:);
export_leveldb(X_test1, y_test1, 17, size(X1,2)/17, 'gs_test1', false);