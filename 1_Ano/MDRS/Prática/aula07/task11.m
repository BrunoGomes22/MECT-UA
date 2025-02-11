%% Task11

clear all
close all
clc

load('InputData2.mat')
nNodes= size(Nodes,1);
nLinks= size(Links,1);
nFlows= size(T,1);

% a)
fprintf("11.a)\n");

% Computing up to k=1 shortest paths for all flows from 1 to nFlows:
k= 1;
sP= cell(1,nFlows);
nSP= zeros(1,nFlows);
for f=1:nFlows
    [shortestPath, totalCost] = kShortestPath(L,T(f,1),T(f,2),k);
    sP{f}= shortestPath;
    nSP(f)= length(totalCost);
end
% sP{f}{i} is the i-th path of flow f
% nSP(f) is the number of paths of flow f

% Compute the link loads using the first (shortest) path of each flow:
sol= ones(1,nFlows);
Loads= calculateLinkLoads(nNodes,Links,T,sP,sol);
% Determine the worst link load:
maxLoad= max(max(Loads(:,3:4)));

addedEnergy = 0;


for i = 1:nLinks
    if (Loads(i,3) + Loads(i,4)) == 0
        addedEnergy = addedEnergy + 1;
    else
        addedEnergy = addedEnergy + 20 + 0.1 * L(Loads(i,1),Loads(i,2));
    end
    
end

fprintf("E = %3.2f    W = %2.2f Gbps\n",addedEnergy,maxLoad);

fprintf("11.b)\n");



