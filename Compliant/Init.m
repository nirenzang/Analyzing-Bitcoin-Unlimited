addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');
clear

global AD maxSG numOfStates numOfStatesP1P2 alpha beta gamma rou;
AD = 5;
maxSG = 144;
% Initialize some parameters for the state space
global mid2Until;
% when l2==i (i!=0), a1, a2, l1 are encoded as [0, mid2Range(i)]
mid2Range = zeros(12);
for i = 1:12
    mid2Range(i) = (i^2+3*i)/2*i+i-1;
end
% [0, mid2Until(i)] counts how many states until l2=i
% 0: l2=0;
% 1 to mid2Range(1)+1: l2=1, mid2Until(1)=mid2Range(1)+1
% mid2Until(1)+1 to mid2Until(1)+1+mid2Range(2): l2=2,
%      mid2Until(2)=mid2Until(1)+1+mid2Range(2)...
% [mid2Until(i-1)+1, mid2Until(i)] means l2 = i
mid2Until = zeros(12);
mid2Until(1)=mid2Range(1)+1;
for i = 2:12
    mid2Until(i) = mid2Until(i-1)+mid2Range(i)+1;
end
numOfStatesP1 = mid2Until(AD)+1;
numOfStatesP1P2 = maxSG*(mid2Until(AD)+1)+mid2Until(AD)+1;
% delete phase 3 for the moment!
% % states 1 to numOfStatesP1P2 represents P1 and P2, numOfStatesP1P2+1 to 
% % numOfStatesP1P2+maxSG represents P3
% numOfStates = numOfStatesP1P2+maxSG;
% Alert!!!! AD in this program is actually AD-1 in BU protocol!

alphav = [0.01 0.025 0.05 0.1 0.15 0.2 0.25];
ratiov = [4 3 2 1.5 1 2.0/3 0.5 1.0/3 0.25];

numOfStates = numOfStatesP1P2;
alpha = 0.2; beta = 0.8/3; gamma = 1.6/3;
SolveStrategy;

% numOfStates = numOfStatesP1;
% setting1Results = zeros(7, 9);
% for ratioI = 1:9
%     for alphaI = 1:7
%         disp(['setting1, numOfStates: ' num2str(numOfStates)...
%             ' AD: ' num2str(AD+1) ' maxSG: ' num2str(maxSG)]);
%         alpha = alphav(alphaI);
%         beta = (1-alpha)/(1+ratiov(ratioI))*ratiov(ratioI);
%         gamma = 1-alpha-beta;
%         if alpha > beta || alpha > gamma
%             continue
%         end
%         disp(['AttackerMiningPower: ' num2str(alpha) ' smallEBMiner Bob: '...
%             num2str(beta) ' bigEBMiner Carol: ' num2str(gamma)]);
%         SolveStrategy;
%         setting1Results(alphaI, ratioI) = rou;
%     end
% end
% 
% numOfStates = numOfStatesP1P2;
% setting2Results = zeros(7, 9);
% for ratioI = 1:9
%     for alphaI = 1:7
%         disp(['setting2, numOfStates: ' num2str(numOfStates)...
%             ' AD: ' num2str(AD+1) ' maxSG: ' num2str(maxSG)]);
%         alpha = alphav(alphaI);
%         beta = (1-alpha)/(1+ratiov(ratioI))*ratiov(ratioI);
%         gamma = 1-alpha-beta;
%         if alpha > beta || alpha > gamma
%             continue
%         end
%         disp(['AttackerMiningPower: ' num2str(alpha) ' smallEBMiner Bob: '...
%             num2str(beta) ' bigEBMiner Carol: ' num2str(gamma)]);
%         SolveStrategy;
%         setting2Results(alphaI, ratioI) = rou;
%     end
% end