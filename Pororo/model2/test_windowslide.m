% Test if sliding window has a side effect.
for i = 3 : 30
    y = zeros(60, 2);
    for k = 1 : 60
        a = normrnd(1, 1, 50, 1);
        b = normrnd(1, 1.1, 50, 1);
        x = zeros(50-i+1, 2);
        for j = 1 : 50 - i + 1
            x(j,1) = var(a(j:j+i-1,1));
            x(j,2) = var(b(j:j+i-1,1));
        end
        y(k,:) = median([x(:,1), x(:,2)]);
    end
    [h,p] = ttest2(y(:,1),y(:,2));
    fprintf('w_size=%d, p=%.2f\n', i, p);
end