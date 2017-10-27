clear

addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

global alphaPower gammaRatio maxForkLen DSR GDP;
% DSR stands for "double spending reward"
% GDP stands for "geometry distribution parameter"

alphaPower = 0.3;
gammaRatio = 0.5;
maxForkLen = 160;
DSR = 2;
GDP = 1/6;

global numOfStates;
numOfStates = ((maxForkLen*2)*(maxForkLen+1)+maxForkLen)*3+3;
disp(['numOfStates: ' num2str(numOfStates)]);
% a and h can be 0 to maxForkLen, altogether maxForkLen + 1 values
% fork: 0 means irrelevant: match is not feasible, last block is selfish OR
% honest branch is empty
% 1 means relevant: if a>=h now, match is feasible, e.g. last block is honest
% 2 means active (just perfomed a match)
% TODO: in some defense, match is still feasible if the last block is selfish!!!!!
irrelevant = 0; relevant = 1; active = 2;
choices = 4; adopt = 1; override = 2; match = 3; wait = 4;
global rou Wrou lowerBoundRou;
global P Rs Rh;

P = cell(1,choices);
% Rs is the reward for selfish miner
Rs = cell(1,choices);
% Rh is the reward for honest miners
Rh = cell(1,choices);
Wrou = cell(1,choices);
for i = 1:choices
    P{i} = sparse(numOfStates, numOfStates);
    Rs{i} = sparse(numOfStates, numOfStates);
    Rh{i} = sparse(numOfStates, numOfStates);
    Wrou{i} = sparse(numOfStates, numOfStates);
end

for i = 1:numOfStates
    if mod(i, 10000)==0
        disp(['processing state: ' num2str(i)]);
    end
    [a h fork acceptance] = stnum2stOrigin(i);
    j = st2stnumOrigin(a, h, fork, acceptance);
    if i~=j
        disp(['i=' num2str(i)]);
    end
end