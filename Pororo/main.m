%% Read files
[Time,Record,X,Y] = importfile('data/pororo_s03p01_yrseo.fix');
fixations = [Time X Y];
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
