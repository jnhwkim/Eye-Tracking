
wav_file = ...          % input audio filename
    '/Users/Calvin/Documents/Projects/Pororo/Movies/pororo_3_1.wav';
[ audio, fs ] = audioread(wav_file);

% Sampling conditions
TRAIN_DATA_SIZE = 1000;
INTERVAL = 4;
WINDOW_SIZE = 2;
SKIP = 1;

% Preallocating the target matrix.
X = zeros(TRAIN_DATA_SIZE, 12 * 398);
y = import_label('../img/animated_gif/train_label.txt');

for i = find(y==1)'
    start_sec = SKIP + (i-1) * INTERVAL;
    end_sec = start_sec + WINDOW_SIZE;
    fprintf('%.1f => %.1f\n', start_sec, end_sec);
    speech = audio(1 + start_sec * fs : end_sec * fs);
    
    gong = audioplayer(speech, fs);
    play(gong);
    pause;
end