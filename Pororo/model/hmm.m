%%%%%% Example of Training/Testing a 2d-mixture of 2 gaussians driven by
%%%%%% HMM

%%
addpath('em_ghmm');
load('data/train1_saliency.mat');

m = 374;

X0 = X(find(y==0), :);
y0 = y(find(y==0));
X1 = X(find(y==1), :);
y1 = y(find(y==1));

Ztrain0 = zeros(m, 21 * size(X0, 1));
Ztrain1 = zeros(m, 21 * size(X1, 1));

for i = 1 : size(X0, 1)
    Ztrain0(:, (i - 1) * size(X0, 2) / m + 1 : i * size(X0, 2) / m) = ...
        reshape(X0(i, :), [m, size(X0, 2) / m]);
end
for i = 1 : size(X1, 1)
    Ztrain1(:, (i - 1) * size(X1, 2) / m + 1 : i * size(X1, 2) / m) = ...
        reshape(X1(i, :), [m, size(X1, 2) / m]);
end

load('data/test1_saliency.mat');

X0 = X(find(y==0), :);
y0 = y(find(y==0));
X1 = X(find(y==1), :);
y1 = y(find(y==1));

Ztest0 = zeros(m, 21 * size(X0, 1));
Ztest1 = zeros(m, 21 * size(X1, 1));

for i = 1 : size(X0, 1)
    Ztest0(:, (i - 1) * size(X0, 2) / m + 1 : i * size(X0, 2) / m) = ...
        reshape(X0(1, :), [m, size(X0, 2) / m]);
end
for i = 1 : size(X1, 1)
    Ztest1(:, (i - 1) * size(X1, 2) / m + 1 : i * size(X1, 2) / m) = ...
        reshape(X1(1, :), [m, size(X1, 2) / m]);
end

d                                   = 2;

L                                   = 1;
R                                   = 1;
Ntrain                              = 14070;
Ntest                               = 3507;
options.nb_ite                      = 30;

%%%%% initial parameters %%%%

PI0                                 = rand(d , 1 , R);
sumPI                               = sum(PI0);
PI0                                 = PI0./sumPI(ones(d , 1) , : , :);

A0                                  = rand(d , d , R);
sumA                                = sum(A0);
A0                                  = A0./sumA(ones(d , 1) , : , :);

M0                                  = randn(m , 1 , d , R);
S0                                  = randn(m , m , d , R);

%%%%% EM algorithm %%%%

[logl0 , PIest0 , Aest0 , Mest0 , Sest0] = em_ghmm(Ztrain0 , PI0 , A0 , M0 , S0 , options);
[logl1 , PIest1 , Aest1 , Mest1 , Sest1] = em_ghmm(Ztrain1 , PI0 , A0 , M0 , S0 , options);

Ltest_est0                           = likelihood_mvgm(Ztest0 , Mest0 , Sest0);
Ltest_est1                           = likelihood_mvgm(Ztest0 , Mest1 , Sest1);

%%

[x , y]                             = ndellipse(M , S);
[xest , yest]                       = ndellipse(Mest , Sest);

Ltrain_est                          = likelihood_mvgm(Ztrain , Mest , Sest);
Xtrain_est                          = forward_backward(PIest , Aest , Ltrain_est);
Xtrain_est                          = Xtrain_est - 1;

ind1                                = (Xtrain_est == 0);
ind2                                = (Xtrain_est == 1);

Err_train                           = min(sum(Xtrain ~= Xtrain_est , 2)/Ntrain , sum(Xtrain ~= ~Xtrain_est , 2)/Ntrain);

figure(1) ,
h                                   = plot(Ztrain(1 , ind1) , Ztrain(2 , ind1) , 'k+' , Ztrain(1 , ind2) , Ztrain(2 , ind2) , 'g+' , x , y , 'b' , xest  , yest ,'r', 'linewidth' , 2);
legend([h(1) ; h(3:m:end)] , 'Train data' , 'True'  , 'Estimated' , 'location' , 'best')
title(sprintf('Train data, Error rate = %4.2f%%' , Err_train*100))

%%%%% Test data  %%%%


[Ztest , Xtest]                     = sample_ghmm(Ntest , PI , A , M , S , L);
Xtest                               = Xtest - 1;


Ltest_est                           = likelihood_mvgm(Ztest , Mest , Sest);
Xtest_est                           = forward_backward(PIest , Aest , Ltest_est);
Xtest_est                           = Xtest_est - 1;


ind1                                = (Xtest_est == 0);
ind2                                = (Xtest_est == 1);

Err_test                            = min(sum(Xtest ~= Xtest_est , 2)/Ntest , sum(Xtest ~= ~Xtest_est , 2)/Ntest);

figure(2),
h                                   = plot(Ztest(1 , ind1) , Ztest(2 , ind1) , 'k+' , Ztest(1 , ind2) , Ztest(2 , ind2) , 'g+' , x , y , 'b' , xest  , yest ,'r', 'linewidth' , 2);
legend([h(1) ; h(3:m:end)] , 'Test data' , 'True'  , 'Estimated' , 'location' , 'best')
title(sprintf('Test data, Error rate = %4.2f%%' , Err_test*100))