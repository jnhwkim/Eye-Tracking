%% Example Saliency Map for Matrix Woman in Red
% Diplay the saliency map for the red woman in the movie, Matrix.
addpath('../../SaliencyToolbox');

%% Section 1 Saliency Map for Matrix Woman in Red
% Diplay the saliency map for the red woman in the movie, Matrix.
% img = imread('pororo-harry.png');
% runSaliency(img);
%%
img = initializeImage('avengers.jpg');
defaults = defaultSaliencyParams();
defaults.weights = [1, .5, .5];
defaults.numIter = 6;
[salmap, saliencyData] = makeSaliencyMap(img, defaults);

%% Section 2 Visualization
% Show the saliency map.
imagesc(salmap.data);
set(gca,'xtick',[],'ytick',[])

