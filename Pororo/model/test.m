addpath('../../SaliencyToolbox/');

path = '../img/animated_gif/cekim/C_1.gif';

[X, map] = imread(path);

idx = 1;
img = ind2rgb(X(:,:,:,idx), map);

salMaps = batchSaliency({img,img});