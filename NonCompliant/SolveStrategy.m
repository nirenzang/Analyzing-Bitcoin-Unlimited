global numOfStates numOfStatesP1P2;
global AD maxSG alpha gamma beta rou DSR;
choices = 2; on1 = 1; on2 = 2;
clear P Rs Rh Wrou
P = cell(1,choices);
% Rs is the "reward" for the attacker, namely # orphaned honest blocks
Rs = cell(1,choices);
% Rh is the reward for honest miners, namely # main chain honest blocks
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
Rh{on1}(base, base) = beta+gamma;
Rs{on1}(base, base) = alpha;
P{on2}(base, base) = 1-alpha;
Rh{on2}(base, base) = 1;
P{on2}(base, st2stnum(0, 1, 0, 1, 0)) = alpha;
if numOfStates == numOfStatesP1P2
    baseP2 = st2stnum(0, 0, 0, 0, maxSG);
else
    baseP2 = base;
end

alphaInAB = alpha/(alpha+beta);
betaInAB = beta/(alpha+beta);
alphaInAG = alpha/(alpha+gamma);
gammaInAG = gamma/(alpha+gamma);

for i = 2:(mid2Until(AD)+1) % process states in Phase 1
    if mod(i, 2000)==0
        disp(['processing state: ' num2str(i)]);
    end
    [l1, l2, a1, a2, remain] = stnum2st(i);
    % when the next block is found on chain 1
    if l1 == l2 % chain 2 is orphaned
        P{on1}(i, base) = alpha+beta;
        Rh{on1}(i, base) = alphaInAB*(l1-a1)+betaInAB*(l1+1-a1);
        Rs{on1}(i, base) = alphaInAB*(a1+1)+betaInAB*a1;
        P{on2}(i, base) = beta;
        Rh{on2}(i, base) = l1+1-a1;
        Rs{on2}(i, base) = a1;
    else % chain 2 is not orphaned
        P{on1}(i, st2stnum(l1+1, l2, a1, a2, 0)) = beta;
        P{on1}(i, st2stnum(l1+1, l2, a1+1, a2, 0)) = alpha;
        P{on2}(i, st2stnum(l1+1, l2, a1, a2, 0)) = beta;
    end
    % when the next block is found on chain 2
    if l2 == AD % about to enter Phase 2, chain 1 is orphaned
        if P{on1}(i, baseP2) == 0 % have phase 2
            P{on1}(i, baseP2) = gamma;
            Rh{on1}(i, baseP2) = l2+1-a2;
            Rs{on1}(i, baseP2) = a2+DSR;
            P{on2}(i, baseP2) = alpha+gamma;
            Rh{on2}(i, baseP2) = alphaInAG*(l2-a2)+gammaInAG*(l2+1-a2);
            Rs{on2}(i, baseP2) = alphaInAG*(a2+1)+gammaInAG*a2+DSR;
        else % no phase 2
            Rh{on1}(i, baseP2) = P{on1}(i, baseP2)*Rh{on1}(i, baseP2)+ gamma*(l2+1-a2);
            Rs{on1}(i, baseP2) = P{on1}(i, baseP2)*Rs{on1}(i, baseP2)+ gamma*a2;
            P{on1}(i, baseP2) = P{on1}(i, baseP2)+gamma;
            Rh{on2}(i, baseP2) = P{on2}(i, baseP2)*Rh{on2}(i, baseP2)+alpha*(l2-a2)+gamma*(l2+1-a2);
            Rs{on2}(i, baseP2) = P{on2}(i, baseP2)*Rs{on2}(i, baseP2)+alpha*(a2+1)+gamma*a2;
            P{on2}(i, baseP2) = P{on2}(i, baseP2)+alpha+gamma;
        end
    else
        P{on1}(i, st2stnum(l1, l2+1, a1, a2, 0)) = gamma;
        P{on2}(i, st2stnum(l1, l2+1, a1, a2, 0)) = gamma;
        P{on2}(i, st2stnum(l1, l2+1, a1, a2+1, 0)) = alpha;
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
            Rh{on1}(i, st2stnum(0, 0, 0, 0, remain-1)) = beta+gamma;
            Rs{on1}(i, st2stnum(0, 0, 0, 0, remain-1)) = alpha;
            P{on2}(i, st2stnum(0, 0, 0, 0, remain-1)) = 1-alpha;
            Rh{on2}(i, st2stnum(0, 0, 0, 0, remain-1)) = 1;
            P{on2}(i, st2stnum(0, 1, 0, 1, remain)) = alpha;
        else
            % when the next block is found on chain 1
            if l1 == l2 % chain 2 is orphaned
                newState = st2stnum(0, 0, 0, 0, remain-l1-1);
                P{on1}(i, newState) = alpha+gamma;
                Rh{on1}(i, newState) = alphaInAG*(l1-a1)+gammaInAG*(l1+1-a1);
                Rs{on1}(i, newState) = alphaInAG*(a1+1)+gammaInAG*a1;
                P{on2}(i, newState) = gamma;
                Rh{on2}(i, newState) = l1+1-a1;
                Rs{on2}(i, newState) = a1;
            else % chain 2 is not orphaned
                P{on1}(i, st2stnum(l1+1, l2, a1, a2, remain)) = gamma;
                P{on1}(i, st2stnum(l1+1, l2, a1+1, a2, remain)) = alpha;
                P{on2}(i, st2stnum(l1+1, l2, a1, a2, remain)) = gamma;
            end
            % when the next block is found on chain 2
            if l2 == AD % about to enter Phase 3 -> Phase 1, chain 1 is orphaned
                if P{on1}(i, base) ~= 0
                    Rh{on1}(i, base) = Rh{on1}(i, base)*P{on1}(i, base)+(l2+1-a2)*beta;
                    Rs{on1}(i, base) = Rs{on1}(i, base)*P{on1}(i, base)+a2*beta+DSR;
                    P{on1}(i, base) = P{on1}(i, base)+beta;
                else
                    Rh{on1}(i, base) = l2+1-a2;
                    Rs{on1}(i, base) = a2+DSR;
                    P{on1}(i, base) = beta;
                end
                if P{on2}(i, base) ~= 0
                    Rh{on2}(i, base) = Rh{on2}(i, base)*P{on2}(i, base)+alpha*(l2-a2)+beta*(l2+1-a2);
                    Rs{on2}(i, base) = Rs{on2}(i, base)*P{on2}(i, base)+alpha*(a2+1)+beta*a2+DSR;
                    P{on2}(i, base) = P{on2}(i, base)+alpha+beta;
                else
                    Rh{on2}(i, base) = alphaInAB*(l2-a2)+betaInAB*(l2+1-a2);
                    Rs{on2}(i, base) = alphaInAB*(a2+1)+betaInAB*a2+DSR;
                    P{on2}(i, base) = alpha+beta;
                end
            else
                P{on1}(i, st2stnum(l1, l2+1, a1, a2, remain)) = beta;
                P{on2}(i, st2stnum(l1, l2+1, a1, a2, remain)) = beta;
                P{on2}(i, st2stnum(l1, l2+1, a1, a2+1, remain)) = alpha;
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
[policy, rou, cpuTime] = mdp_relative_value_iteration(P, Rs, epsilon/8);
% lowRou = 0; highRou = 1;
% while(highRou - lowRou > epsilon/8)
%     rou = (highRou + lowRou) / 2;
%     for i = 1:choices
%         Wrou{i} = (1-rou).*Rs{i} - rou.*Rh{i};
%     end
%     [policy, reward, cpuTime] = mdp_relative_value_iteration(P, Wrou, epsilon/8);
%     if(reward > 0)
%         lowRou = rou;
%     else
%         highRou = rou;
%     end
% end
disp('Reward: ')
format long
disp(rou)