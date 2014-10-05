% GEN_MFCC Generate mfcc feature vectors for Pororo training.
%
%   This script is a step by step walk-through of computation of the
%   mel frequency cepstral coefficients (MFCCs) from a speech signal
%   using the MFCC routine.
%
%   See also MFCC, COMPARE.

%   Author: Kamil Wojcicki, September 2011
%   Modified: Jin-Hwa Kim, October 2014


% Clean-up MATLAB's environment
clear all; close all; clc;

% Add mfcc library path
addpath('mfcc/');

% Define variables
Tw = 25;                % analysis frame duration (ms)
Ts = 10;                % analysis frame shift (ms)
alpha = 0.97;           % preemphasis coefficient
M = 20;                 % number of filterbank channels 
C = 12;                 % number of cepstral coefficients
L = 22;                 % cepstral sine lifter parameter
LF = 300;               % lower frequency limit (Hz)
HF = 3700;              % upper frequency limit (Hz)
wav_file = ...          % input audio filename
    '/Users/Calvin/Documents/Projects/Pororo/Movies/pororo_3_1.wav';

% Read speech samples, sampling rate and precision from file
[ audio, fs ] = audioread(wav_file);

% Sampling conditions
TRAIN_DATA_SIZE = 1000;
INTERVAL = 4;
WINDOW_SIZE = 2;
SKIP = 1;

% Preallocating the target matrix.
DELAY = 99;
STEP  = 30;
FEATURE_NUM = 398;
FEATURE_LEN = 13;
SAMPLING_POINTS = 1 : STEP : (FEATURE_NUM - DELAY);
SAMPLING_NUM = size(SAMPLING_POINTS, 2);
X = zeros(TRAIN_DATA_SIZE * SAMPLING_NUM, FEATURE_LEN * (1 + DELAY));
y0 = import_label('../img/animated_gif/train_label.txt');
y = zeros(size(X, 1), 1);

for i = 1 : TRAIN_DATA_SIZE
    start_sec = SKIP + (i-1) * INTERVAL;
    end_sec = start_sec + INTERVAL;
    speech = audio(1 + start_sec * fs : end_sec * fs);

    % Feature extraction (feature vectors as columns)
    [ MFCCs, FBEs, frames ] = ...
        mfcc( speech, fs, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, L );
    
    for j = 1 : SAMPLING_NUM
        k = SAMPLING_POINTS(j);
        mfccs = MFCCs(:, k:k + DELAY);
        X((i - 1) * SAMPLING_NUM + j, :) = mfccs(:);
        y((i - 1) * SAMPLING_NUM + j, :) = y0(i);
    end
end

% Feature normalization
X_max = max(X);
X_min = min(X);
X = (X - ones(size(X, 1), 1) * X_min) ./ ...
    (ones(size(X, 1), 1) * (X_max - X_min));

y = uint32(y);

% Save the result as a mat file.
save('data/mfcc/train_mfcc.mat', 'X', 'y');
    
  