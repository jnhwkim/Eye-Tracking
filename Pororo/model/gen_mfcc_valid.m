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
INTERVAL = 4;
WINDOW_SIZE = 2;
SKIP = 0.5;

% Preallocating the target matrix.
DELAY = 99;
STEP  = 10;
FEATURE_NUM = 198;
FEATURE_LEN = 13;
SAMPLING_POINTS = 1 : STEP : (FEATURE_NUM - DELAY);
SAMPLING_NUM = size(SAMPLING_POINTS, 2);
ts = get_valid_ts(); ts = ts(:) / 1000;
X_valid = zeros(size(ts(:), 1) * SAMPLING_NUM, FEATURE_LEN * (1 + DELAY));

for i = 1 : size(ts, 1)
    t = ts(i);
    start_sec = SKIP + t;
    end_sec = start_sec + WINDOW_SIZE;
    speech = audio(1 + round(start_sec * fs) : round(end_sec * fs));

    % Feature extraction (feature vectors as columns)
    [ MFCCs, FBEs, frames ] = ...
        mfcc( speech, fs, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, L );
    
    for j = 1 : SAMPLING_NUM
        k = SAMPLING_POINTS(j);
        mfccs = MFCCs(:, k:k + DELAY);
        X_valid((i - 1) * SAMPLING_NUM + j, :) = mfccs(:);
    end
end

% Feature normalization
X_max = max(X_valid);
X_min = min(X_valid);
X_valid = (X_valid - ones(size(X_valid, 1), 1) * X_min) ./ ...
    (ones(size(X_valid, 1), 1) * (X_max - X_min));

% Save the result as a mat file.
save('data/valid_mfcc.mat', 'X_valid');
   