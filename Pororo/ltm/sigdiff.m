function [h,p,dist] = sigdiff(data, m, diff, samplings)
    count = 0;
    dist = zeros(samplings,1);
    for i = 1:samplings
        shaked = data(randsample(data, size(data, 1)));
        pick_m = shaked(1:m);
        pick_n = shaked(m+1:end);
        dist(i) = mean(pick_m) - mean(pick_n);
        % Notice that the sampling distribution of the difference is 
        % possible to be skewed.
        if dist(i) > diff
            count = count + 1;
        end
    end
    p = count / samplings;
    if p < 0.05
        h = 1;
    else
        h = 0;
    end
end