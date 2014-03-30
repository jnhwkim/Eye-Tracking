%% Read files
[Time,Record,Normalized_X,Normalized_Y,X,Y] = importfile('fixation.out');
fixations = [Time Normalized_X Normalized_Y];
timings = load('timings.txt');

figure;
N = 10;
fixations = fixations(fixations(:,1)<=timings(N * N),:);

for i = 1 : N * N
    subplot('Position', [mod(i-1,N)/N, 1-1/N-floor((i-1)/N)/N, 1/N, 1/N]);
    time = int2str(timings(i));
    showFixation(time, fixations);
    axis off;
end
