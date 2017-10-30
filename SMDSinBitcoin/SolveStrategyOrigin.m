global alphaPower gammaRatio maxForkLen DSR cfN reward;

global numOfStates;
numOfStates = (maxForkLen*(maxForkLen+1)+maxForkLen)*3+3;
disp(['numOfStates: ' num2str(numOfStates)]);
% a and h can be 0 to maxForkLen, altogether maxForkLen + 1 values
% fork: 0 means irrelevant: match is not feasible, last block is selfish OR
% honest branch is empty
% 1 means relevant: if a>=h now, match is feasible, e.g. last block is honest
% 2 means active (just perfomed a match)
% TODO: in some defense, match is still feasible if the last block is selfish!!!!!
irrelevant = 0; relevant = 1; active = 2;
choices = 4; adopt = 1; override = 2; match = 3; wait = 4;
global P Rs Rh;

P = cell(1,choices);
% Rs is the reward for selfish miner
Rs = cell(1,choices);
% Rh is the reward for honest miners
% Rh = cell(1,choices);
Wrou = cell(1,choices);
for i = 1:choices
    P{i} = sparse(numOfStates, numOfStates);
    Rs{i} = sparse(numOfStates, numOfStates);
    % Rh{i} = sparse(numOfStates, numOfStates);
end

baseState = st2stnumOrigin(0, 1, irrelevant);

% define adopt
P{adopt}(:, st2stnumOrigin(1, 0, irrelevant)) = alphaPower;
P{adopt}(:, st2stnumOrigin(0, 1, irrelevant)) = 1-alphaPower;
for i = 1:numOfStates
    if mod(i, 2000)==0
        disp(['processing state: ' num2str(i)]);
    end
    [a h fork] = stnum2stOrigin(i);
    % Rh{adopt}(:, st2stnumOrigin(1, 0, irrelevant)) = h;
    % Rh{adopt}(:, st2stnumOrigin(0, 1, irrelevant)) = h;
	if h >= cfN
	    DSRcur = DSR*(h-cfN+1);
	else
	    DSRcur = 0;
	end
    % define override
    if a > h
        P{override}(i, st2stnumOrigin(a-h, 0, irrelevant)) = alphaPower;
        P{override}(i, st2stnumOrigin(a-h-1, 1, relevant)) = 1-alphaPower;
        Rs{override}(i, st2stnumOrigin(a-h, 0, irrelevant)) = h+1+DSRcur;
        Rs{override}(i, st2stnumOrigin(a-h-1, 1, relevant)) = h+1+DSRcur;
    else % just for completeness
        P{override}(i, baseState) = 1;
        Rh{override}(i, baseState) = 10000;
    end
    % define wait
    if fork ~= active && a+1 <= maxForkLen && h+1 <= maxForkLen
        P{wait}(i, st2stnumOrigin(a+1, h, irrelevant)) = alphaPower;
		P{wait}(i, st2stnumOrigin(a, h+1, relevant)) = 1-alphaPower;
    elseif fork == active && a > h && h > 0 && a+1 <= maxForkLen && h+1 <= maxForkLen
        P{wait}(i, st2stnumOrigin(a+1, h, active)) = alphaPower;
        P{wait}(i, st2stnumOrigin(a-h, 1, relevant)) = gammaRatio*(1-alphaPower);
        Rs{wait}(i, st2stnumOrigin(a-h, 1, relevant)) = h+DSRcur;
		P{wait}(i, st2stnumOrigin(a, h+1, relevant)) = (1-gammaRatio)*(1-alphaPower);
    else
        P{wait}(i, baseState) = 1;
        % Rh{wait}(i, baseState) = 10000;
    end
    % define match: match if feasible only when the last block is honest
    % and the selfish miner has more blocks before the last block is mined
    if fork == relevant && a >= h && h > 0 && a+1 <= maxForkLen && h+1 <= maxForkLen
        P{match}(i, st2stnumOrigin(a+1, h, active)) = alphaPower;
        P{match}(i, st2stnumOrigin(a-h, 1, relevant)) = gammaRatio*(1-alphaPower);
        Rs{match}(i, st2stnumOrigin(a-h, 1, relevant)) = h+DSRcur;
		P{match}(i, st2stnumOrigin(a, h+1, relevant)) = (1-gammaRatio)*(1-alphaPower);
    else
        P{match}(i, baseState) = 1;
        % Rh{match}(i, baseState) = 10000;
    end
end

disp(mdp_check(P, Rs))

epsilon = 0.000001;


[lowerBoundPolicy reward cpuTime] = mdp_relative_value_iteration(P, Rs, epsilon/8);
disp('expectedReward: ')
format long
disp(reward)
disp('cpuTime')
disp(cpuTime)