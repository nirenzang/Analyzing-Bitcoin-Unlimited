addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

global alphaPower gammaRatio maxForkLen DSR cfN reward;
% DSR stands for "double spending reward"
% cfN stands for "confirmation number"

alphaGroup = [0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3];
DSR = 10;
cfN = 4;
maxForkLen = 50;

gammaRatio = 0.5;
RewardResultHalf=[];
for alphaPower = alphaGroup
    if alphaPower <= 0.4
        maxForkLen = 50;
    else
        maxForkLen = 80;
    end
    SolveStrategyOrigin;
    RewardResultHalf = [RewardResultHalf reward];
end

gammaRatio = 1;
RewardResult=[];
for alphaPower = alphaGroup
    if alphaPower <= 0.4
        maxForkLen = 50;
    else
        maxForkLen = 80;
    end
    SolveStrategyOrigin;
    RewardResult = [RewardResult reward];
end