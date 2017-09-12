global numOfStates numOfStatesP1P2;
global AD maxSG alpha gamma beta result;
choices = 3; on1 = 1; on2 = 2; wait = 3;
clear P Rs Rh Wrou
P = cell(1,choices);
% Rs is the "reward" for the attacker, namely # orphaned honest blocks
Rs = cell(1,choices);
% Rh is the "cost" of the attacker, namely # of blocks mined by the attacker
Rh = cell(1,choices);
Wrou = cell(1,choices);
for i = 1:choices
    P{i} = sparse(numOfStates, numOfStates);
    Rs{i} = sparse(numOfStates, numOfStates);
    Rh{i} = sparse(numOfStates, numOfStates);
    Wrou{i} = sparse(numOfStates, numOfStates);
end

base = st2stnum(0, 0, 0, 0, 0);
P{on1}(base, base) = 1;
Rh{on1}(base, base) = alpha;
P{on2}(base, base) = 1-alpha;
P{on2}(base, st2stnum(0, 1, 0, 1, 0)) = alpha;
Rh{on2}(base, st2stnum(0, 1, 0, 1, 0)) = 1;
P{wait}(base, base) = 1;
if numOfStates == numOfStatesP1P2
    baseP2 = st2stnum(0, 0, 0, 0, maxSG);
else
    baseP2 = base;
end

alphaInAB = alpha/(alpha+beta);
betaInAB = beta/(alpha+beta);
alphaInAG = alpha/(alpha+gamma);
gammaInAG = gamma/(alpha+gamma);
betaInBG = beta/(beta+gamma);
gammaInBG = gamma/(beta+gamma);

for i = 2:(mid2Until(AD)+1) % process states in Phase 1
    if mod(i, 2000)==0
        disp(['processing state: ' num2str(i)]);
    end
    [l1, l2, a1, a2, remain] = stnum2st(i);
    % when the next block is found on chain 1
    if l1 == l2 % chain 2 is orphaned
        P{on1}(i, base) = alpha+beta;
        Rh{on1}(i, base) = alphaInAB;
        Rs{on1}(i, base) = l2-a2;
        P{on2}(i, base) = beta;
        Rs{on2}(i, base) = l2-a2;
        P{wait}(i, base) = betaInBG;
        Rs{wait}(i, base) = l2-a2;
    else % chain 2 is not orphaned
        P{on1}(i, st2stnum(l1+1, l2, a1, a2, 0)) = beta;
        P{wait}(i, st2stnum(l1+1, l2, a1, a2, 0)) = betaInBG;
        P{on1}(i, st2stnum(l1+1, l2, a1+1, a2, 0)) = alpha;
        Rh{on1}(i, st2stnum(l1+1, l2, a1+1, a2, 0)) = 1;
        P{on2}(i, st2stnum(l1+1, l2, a1, a2, 0)) = beta;
    end
    % when the next block is found on chain 2
    if l2 == AD % about to enter Phase 2, chain 1 is orphaned
        if P{on1}(i, baseP2) == 0 % have phase 2
            P{on1}(i, baseP2) = gamma;
            Rs{on1}(i, baseP2) = l1-a1;
            P{wait}(i, baseP2) = gammaInBG;
            Rs{wait}(i, baseP2) = l1-a1;
            P{on2}(i, baseP2) = alpha+gamma;
            Rh{on2}(i, baseP2) = alphaInAG;
            Rs{on2}(i, baseP2) = l1-a1;
        else % no phase 2
            Rh{on1}(i, baseP2) = P{on1}(i, baseP2)*Rh{on1}(i, baseP2);
            Rs{on1}(i, baseP2) = P{on1}(i, baseP2)*Rs{on1}(i, baseP2)+ gamma*(l1-a1);
            P{on1}(i, baseP2) = P{on1}(i, baseP2)+gamma;
            Rs{wait}(i, baseP2) = P{wait}(i, baseP2)*Rs{wait}(i, baseP2)+ gammaInBG*(l1-a1);
            P{wait}(i, baseP2) = P{wait}(i, baseP2)+gammaInBG;
            Rh{on2}(i, baseP2) = P{on2}(i, baseP2)*Rh{on2}(i, baseP2)+alpha;
            Rs{on2}(i, baseP2) = P{on2}(i, baseP2)*Rs{on2}(i, baseP2)+(alpha+gamma)*(l1-a1);
            P{on2}(i, baseP2) = P{on2}(i, baseP2)+alpha+gamma;
        end
    else
        P{on1}(i, st2stnum(l1, l2+1, a1, a2, 0)) = gamma;
        P{wait}(i, st2stnum(l1, l2+1, a1, a2, 0)) = gammaInBG;
        P{on2}(i, st2stnum(l1, l2+1, a1, a2, 0)) = gamma;
        P{on2}(i, st2stnum(l1, l2+1, a1, a2+1, 0)) = alpha;
        Rh{on2}(i, st2stnum(l1, l2+1, a1, a2+1, 0)) = 1;
    end
end

if numOfStates == numOfStatesP1P2
    for i = (mid2Until(AD)+2):numOfStatesP1P2 % process states in P2
        if mod(i, 2000)==0
            disp(['processing state: ' num2str(i)]);
        end
        [l1, l2, a1, a2, remain] = stnum2st(i);
        if l2 == 0 % before the blockchain is forked
            P{on1}(i, st2stnum(0, 0, 0, 0, remain-1)) = 1;
            Rh{on1}(i, st2stnum(0, 0, 0, 0, remain-1)) = alpha;
            P{wait}(i, st2stnum(0, 0, 0, 0, remain-1)) = 1;
            P{on2}(i, st2stnum(0, 0, 0, 0, remain-1)) = 1-alpha;
            P{on2}(i, st2stnum(0, 1, 0, 1, remain)) = alpha;
            Rh{on2}(i, st2stnum(0, 1, 0, 1, remain)) = 1;
        else
            % when the next block is found on chain 1
            if l1 == l2 % chain 2 is orphaned
                newState = st2stnum(0, 0, 0, 0, remain-l1-1);
                P{on1}(i, newState) = alpha+gamma;
                Rh{on1}(i, newState) = alphaInAG;
                Rs{on1}(i, newState) = l2-a2;
                P{on2}(i, newState) = gamma;
                Rs{on2}(i, newState) = l2-a2;
                P{wait}(i, newState) = gammaInBG;
                Rs{wait}(i, newState) = l2-a2;
            else % chain 2 is not orphaned
                P{on1}(i, st2stnum(l1+1, l2, a1, a2, remain)) = gamma;
                P{on1}(i, st2stnum(l1+1, l2, a1+1, a2, remain)) = alpha;
                Rh{on1}(i, st2stnum(l1+1, l2, a1+1, a2, remain)) = 1;
                P{on2}(i, st2stnum(l1+1, l2, a1, a2, remain)) = gamma;
                P{wait}(i, st2stnum(l1+1, l2, a1, a2, remain)) = gammaInBG;
            end
            % when the next block is found on chain 2
            if l2 == AD % about to enter Phase 3 -> Phase 1, chain 1 is orphaned
                if P{on1}(i, base) ~= 0
                    Rh{on1}(i, base) = Rh{on1}(i, base)*P{on1}(i, base);
                    Rs{on1}(i, base) = Rs{on1}(i, base)*P{on1}(i, base)+beta*(l1-a1);
                    P{on1}(i, base) = P{on1}(i, base)+beta;
                else
                    Rs{on1}(i, base) = l1-a1;
                    P{on1}(i, base) = beta;
                end
                if P{wait}(i, base) ~= 0
                    Rs{wait}(i, base) = Rs{wait}(i, base)*P{wait}(i, base)+betaInBG*(l1-a1);
                    P{wait}(i, base) = P{wait}(i, base)+betaInBG;
                else
                    Rs{wait}(i, base) = l1-a1;
                    P{wait}(i, base) = betaInBG;
                end
                if P{on2}(i, base) ~= 0
                    Rh{on2}(i, base) = Rh{on2}(i, base)*P{on2}(i, base)+alpha;
                    Rs{on2}(i, base) = Rs{on2}(i, base)*P{on2}(i, base)+(alpha+beta)*(l1-a1);
                    P{on2}(i, base) = P{on2}(i, base)+alpha+beta;
                else
                    Rh{on2}(i, base) = alphaInAB;
                    Rs{on2}(i, base) = l1-a1;
                    P{on2}(i, base) = alpha+beta;
                end
            else
                P{on1}(i, st2stnum(l1, l2+1, a1, a2, remain)) = beta;
                P{on2}(i, st2stnum(l1, l2+1, a1, a2, remain)) = beta;
                P{wait}(i, st2stnum(l1, l2+1, a1, a2, remain)) = betaInBG;
                P{on2}(i, st2stnum(l1, l2+1, a1, a2+1, remain)) = alpha;
                Rh{on2}(i, st2stnum(l1, l2+1, a1, a2+1, remain)) = 1;
            end
        end
    end
end

for i=1:choices
    sumP2 = sum(P{i},2);
    for j=1:numOfStates
        if sumP2(j) < 0.99 || sumP2(j)>1.01
            disp(['action=' num2str(i) ' state=' num2str(j) ' sum=' num2str(sumP2(j))]);
            [l1, l2, a1, a2, remain] = stnum2st(j);
            disp(['l1=' num2str(l1) ' l2=' num2str(l2) ' a1=' num2str(a1)...
                ' a2=' num2str(a2) ' remain=' num2str(remain)]);
            break
        end
    end
end

disp(mdp_check(P, Rs))
epsilon = 0.0001;
lowRou = 0; highRou = 1;
while(highRou - lowRou > epsilon/8)
    rou = (highRou + lowRou) / 2;
    for i = 1:choices
        Wrou{i} = (1-rou).*Rs{i} - rou.*Rh{i};
    end
    [policy, reward, cpuTime] = mdp_relative_value_iteration(P, Wrou, epsilon/8);
    if(reward > 0)
        lowRou = rou;
    else
        highRou = rou;
    end
end
disp('Reward: ')
format long
result = 1.0/(1.0/rou-1);
disp(result)