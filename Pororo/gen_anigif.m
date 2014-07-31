% Copyright (C) 2014 Jin-Hwa Kim
%
% Author: Jin-Hwa Kim (jhkim@bi.snu.ac.kr)
% Created: July 31 2014
%
% Generate the animated-gif file for the frames variable,
% which is from the script, get_interval_frame.
% (Height * Width * ColorSpace * NumberOfFrames)

function gen_anigif(frames, fps, filename, preprocessor)
% preprocessor does, for example, 
% imresize(squeeze(frames(:,:,:,k)), 0.5);

    % Some variables
    NUM_COLOR = size(frames, 3);
    NUM_FRAMES = size(frames, 4);

    if nargin < 4
        % It shows how we should define the argument.
        preprocessor = inline('imresize(im, 0.5)');
    end

    %% Colormap for the animated-gif
    %% It extracts the appropriate colormap across all frames.
    %% If we omit this procedure, it would result an awakard colored result.
    for k = 1 : NUM_FRAMES
        im = preprocessor(squeeze(frames(:,:,:,k)));
        if ~exist('HEIGHT', 'var')
            HEIGHT = size(im, 1);
            WIDTH = size(im, 2);
        end
        if ~exist('imcat', 'var')
            imcat = uint8(zeros(HEIGHT * NUM_FRAMES, WIDTH, NUM_COLOR));
        end
        imcat((HEIGHT * (k - 1) + 1):HEIGHT * k, :, :) = im;
    end
    [imind, cm] = rgb2ind(imcat, 256, 'nodither');

    %% Making the frames for animation 
    imout = uint8(zeros(HEIGHT, WIDTH, 1, NUM_FRAMES));
    for k = 1 : NUM_FRAMES
        im = preprocessor(squeeze(frames(:,:,:,k)));
        imout(:,:,1,k) = rgb2ind(im, cm,'nodither');
    end

    imwrite(imout, cm, filename, 'DelayTime', 1.0/fps, 'LoopCount', inf);

end