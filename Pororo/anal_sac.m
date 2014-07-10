%% Read files
filenames = dir('data/*.tsv');
saccade_all = [];
No = size(filenames, 1);
IS_RAW = false;
INDIVIDUAL = true;
if(IS_RAW)
    w = 1280; h = 960;
else
    w = 1.0; h = 1.0;
end

%% Preprocessing
for i = 1 : No

    filename = filenames(i).name;
    filename_split = strsplit(filename,'.');
    N = ceil(sqrt(No));

    disp(sprintf('%d: %s', i, filename));

    warning('off','MATLAB:iofun:UnsupportedEncoding');
    [   RecordingTimestamp, ...
        FixationIndex, ...
        SaccadeIndex, ...
        GazeEventType, ...
        GazeEventDuration, ...
        FixationPointXADCSpx, FixationPointYADCSpx, ...
        GazePointXADCSpx, GazePointYADCSpx, ...
        FixationPointXMCSpx, FixationPointYMCSpx, ...
        GazePointXMCSpx, GazePointYMCSpx    ] = ...
            import_data(strcat('data/', filename));

    if(IS_RAW)
        saccade_raw = [SaccadeIndex GazePointXADCSpx GazePointYADCSpx];
    else
        saccade_raw = [SaccadeIndex GazePointXMCSpx GazePointYMCSpx];
    end
    
    saccade_raw = saccade_raw(~isnan(saccade_raw(:,1)),:);

    %% Saccde Vector Analyses
    % get all the saccade vector
    saccade_source = saccade_raw(1:end-1,:);
    saccade_target = [saccade_raw(2:end,:) saccade_source(:,2:end)];
    saccade_source = [saccade_source zeros(size(saccade_source)-[0 1])];
    saccade_vector_tmp = saccade_target - saccade_source;
    % saccade_vector is [zero vec_x vec_y orgin_x orgin_y].
    % except for the different moments(rows whose first column value is one.),
    % the missing rows and outside of the media screen.
    saccade_vector = saccade_vector_tmp(saccade_vector_tmp(:,1)==0,:);
    saccade_vector = saccade_vector(~isnan(saccade_vector(:,2)),:);
    
    % scope defined as [u_min,u_max; v_min,v_max; x_min,x_max; y_min,y_max];
    scope = [-w, w; -h, h; 0, w; 0, h];
    for j = 1 : size(scope, 1)
        saccade_vector = saccade_vector( ...
                         saccade_vector(:,j+1)>scope(j,1),:);
        saccade_vector = saccade_vector( ...
                         saccade_vector(:,j+1)<scope(j,2),:);
    end
    
    x = saccade_vector(:,4); y = saccade_vector(:,5);
    u = saccade_vector(:,2); v = saccade_vector(:,3);
        
    angle_in_radian = angle(complex(u,v));
    angle_in_degree = angle_in_radian * 180 / pi;
    
    % Change the negative angles to the equivalent possitive ones.
    neg_idx = angle_in_degree < 0;
    angle_in_degree(neg_idx) = angle_in_degree(neg_idx) + 360;
        
    saccade_all = [saccade_all; saccade_vector, angle_in_degree];

    if INDIVIDUAL
        %% Saccade Vectors
        figure(1);
        subplot('Position', [mod(i-1,N)/N, 1-1/N-floor((i-1)/N)/N, 1/N, 1/N]);
        screenshot_filename = strcat('raw/',filename_split{1},'.jpg');
        screenshot = imread(screenshot_filename);

        hold on;
        if(IS_RAW) 
            imshow(screenshot); 
            quiver(x,y,u,-v); % image coordinates
        else
            quiver(x,-y+h,u,-v); % vertical inverted coordinates
        end
        axis([0 w 0 h]);
        title(sprintf('median = [%.3f %.3f]', median(x), median(y)));
        hold off;

        %% Saccade Lengths
        figure(2);
        subplot('Position', [mod(i-1,N)/N, 1-1/N-floor((i-1)/N)/N, 1/N, 1/N]);
        quiver(zeros(size(x)),zeros(size(y)),u,-v);
        axis([-w w -h h]);
        
        %% Angle Distribution
        hg = hist(angle_in_degree, 360);
        figure(3);
        %subplot('Position', [mod(i-1,N)/N, 1-1/N-floor((i-1)/N)/N, 1/N, 1/N]);
        subplot(N,N,i);
        plot(hg);
        axis([0 360 0 max(hg)]);
    end    
end

x = saccade_all(:,4); y = saccade_all(:,5); 
u = saccade_all(:,2); v = saccade_all(:,3);

%% Marginal Saccade Lengths
figure(4);
quiver(zeros(size(x)),zeros(size(y)),u,-v);
axis([-w w -h h]);

%% Marginal Saccade Vectors
figure(5);
quiver(x,-y+h,u,-v);
axis([0 w 0 h]);

drawnow();

%% Margianl Angle Distribution
angle_in_degree = saccade_all(:,6);
h = hist(angle_in_degree, 360);
figure(6);
plot(h);
axis([0 360 0 max(h)]);