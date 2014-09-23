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

% Sample Code
% 
%      %% Statistical significance of each category.
%      noc = size(elements, 1);
%      p_values = zeros(noc,1);
%      for i = 1:noc
%         a = elements{i};
%         b = [];
%         for j = 1:noc
%             if j ~= i
%                 b = [b; elements{j}];
%             end
%         end
%         diff = mean(a) - mean(b);
%         
%     	[h,p,dist] = sigdiff(L_vec, size(a,1), diff, 1000);
%         p_values(i) = p;
%      end
%      p_values