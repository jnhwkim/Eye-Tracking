%% Read files
filenames = dir('fix/*.fix');

for i = 1 : size(filenames, 1)
    
    filename = filenames(i).name
    
    [Time,Record,X,Y] = importfile(strcat('fix/', filename));
    fixations = [Time X Y];
    timings = load('info/timings.txt');

    fig0 = figure;

    N = 10;
    skip = 400;
    fixations = fixations(fixations(:,1)<=timings(N * N + skip),:);

    for i = 1 : N * N
        subplot('Position', [mod(i-1,N)/N, 1-1/N-floor((i-1)/N)/N, 1/N, 1/N]);
        time = int2str(timings(i + skip));
        showFixation(time, fixations);
        axis off;
    end

    saveas(fig0, strcat('img/', strrep(filename, '.fix', '.jpg')));
    close(fig0);
end