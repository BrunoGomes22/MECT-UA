%% Task 12

clear all
close all
clc

load('InputData3.mat')
nNodes= size(Nodes,1);
nLinks= size(Links,1);
nFlows= size(T,1);

% a)
% anycast services are provided by network nodes 3 and 5
fprintf("12.a)\n");

anycastNodes = [3 5];
D = L/2e5;

Taux = zeros(nFlows,4);

% Computing up to k=1 shortest paths for all flows from 1 to nFlows:
k= 1;
sP= cell(1,nFlows);
nSP= zeros(1,nFlows);
for f=1:nFlows
    if T(f,1) == 1 % unicast service
        [shortestPath, totalCost] = kShortestPath(D,T(f,2),T(f,3),k);
        sP{f}= shortestPath;
        nSP(f)= length(totalCost);
        Taux(f,:) = T(f,2:5);
    elseif T(f,1) == 2 % anycast service
        if ismember(T(f,2),anycastNodes)
            sP{f} = {T(f,2)};
            nSP(f) = 1;
            Taux(f,:) = T(f,2:5);
            Taux(f,2) = T(f,2);
        else %comparar totalCosts do shortest paths
            custo = inf;
            Taux(f,:) = T(f,2:5);
            for i=anycastNodes
                [shortestPath, totalCost] = kShortestPath(D,T(f,2),i,k);
                if totalCost<custo
                    sP{f} = shortestPath;
                    nSP(f) = 1;
                    custo = totalCost;
                    Taux(f,2) = i;
                end
            end
        end
    end
end


fprintf("Anycast nodes= %d %d\n",anycastNodes(1),anycastNodes(2));

rttDelays = zeros(nFlows,1);

for f = 1:nFlows
    path = sP{f}{1};
    for i = 1:length(path)-1
        rttDelays(f) = rttDelays(f) + 2 * D(path(i), path(i+1));
    end
end

RTT_unicast = rttDelays(T(:,1) == 1);
RTT_anycast = rttDelays(T(:,1) == 2);

worstRTT_unicast = max(RTT_unicast);
avgRTT_unicast = mean(RTT_unicast);

worstRTT_anycast = max(RTT_anycast);
avgRTT_anycast = mean(RTT_anycast);

fprintf("Worst round-trip delay (unicast service) = %.2f ms\n",worstRTT_unicast*1000);
fprintf("Average round-trip delay (unicast service) = %.2f ms\n",avgRTT_unicast*1000);
fprintf("Worst round-trip delay (anycast service) = %.2f ms\n",worstRTT_anycast*1000);
fprintf("Average round-trip delay (anycast service) = %.2f ms\n",avgRTT_anycast*1000);


% b)
fprintf("12.b)\n");
% Compute the link loads using the first (shortest) path of each flow:
sol= ones(1,nFlows);
Loads= calculateLinkLoads(nNodes,Links,Taux,sP,sol);
% Determine the worst link load:
maxLoad= max(max(Loads(:,3:4)));

fprintf("Anycast nodes= %d %d\n",anycastNodes(1),anycastNodes(2));
fprintf("Worst link load = %.2f Gbps\n",maxLoad);

for i = 1:nLinks
    fprintf('{%-2d - %-2d}        %8.2f %8.2f\n', Loads(i,1), Loads(i,2), Loads(i,3), Loads(i,4));
end

%c)
fprintf("12.c)\n");

% generate all possible combinations of two nodes
nodeCombinations = nchoosek(1:nNodes, 2);
nCombinations = size(nodeCombinations, 1);

% initialize variables to track the best combination
bestAnycastNodes = [];
minWorstLinkLoad = inf;

Taux = zeros(nFlows,4);

% computing up to k=1 shortest paths for all flows from 1 to nFlows:
k= 1;

for c = 1:nCombinations
    anycastNodes = nodeCombinations(c,:);
    sP= cell(1,nFlows);
    nSP= zeros(1,nFlows);
    for f=1:nFlows
        if T(f,1) == 1 % unicast service
            [shortestPath, totalCost] = kShortestPath(D,T(f,2),T(f,3),k);
            sP{f}= shortestPath;
            nSP(f)= length(totalCost);
            Taux(f,:) = T(f,2:5);
        elseif T(f,1) == 2 % anycast service
            if ismember(T(f,2),anycastNodes)
                sP{f} = {T(f,2)};
                nSP(f) = 1;
                Taux(f,:) = T(f,2:5);
                Taux(f,2) = T(f,2);
            else %comparar totalCosts do shortest paths
                custo = inf;
                Taux(f,:) = T(f,2:5);
                for i=anycastNodes
                    [shortestPath, totalCost] = kShortestPath(D,T(f,2),i,k);
                    if totalCost<custo
                        sP{f} = shortestPath;
                        nSP(f) = 1;
                        custo = totalCost;
                        Taux(f,2) = i;
                    end
                end
            end
        end
    end
    
    %compute link loads
    sol= ones(1,nFlows);
    Loads= calculateLinkLoads(nNodes,Links,Taux,sP,sol);
    worstLinkLoad= max(max(Loads(:,3:4)));
    
    %update the best anycast node combination
    if worstLinkLoad < minWorstLinkLoad 
        minWorstLinkLoad = worstLinkLoad;
        bestAnycastNodes = anycastNodes;
    end

end


% compute the round-trip delays for the best combination
sP= cell(1,nFlows);
nSP= zeros(1,nFlows);
for f=1:nFlows
    if T(f,1) == 1 % unicast service
        [shortestPath, totalCost] = kShortestPath(D,T(f,2),T(f,3),k);
        sP{f}= shortestPath;
        nSP(f)= length(totalCost);
        Taux(f,:) = T(f,2:5);
    elseif T(f,1) == 2 % anycast service
        if ismember(T(f,2),bestAnycastNodes)
            sP{f} = {T(f,2)};
            nSP(f) = 1;
            Taux(f,:) = T(f,2:5);
            Taux(f,2) = T(f,2);
        else %comparar totalCosts do shortest paths
            custo = inf;
            Taux(f,:) = T(f,2:5);
            for i=bestAnycastNodes
                [shortestPath, totalCost] = kShortestPath(D,T(f,2),i,k);
                if totalCost<custo
                    sP{f} = shortestPath;
                    nSP(f) = 1;
                    custo = totalCost;
                    Taux(f,2) = i;
                end
            end
        end
    end
end

rttDelays = zeros(nFlows,1);
% calculate rtt delays
for f = 1:nFlows
    path = sP{f}{1};
    for i = 1:length(path)-1
        rttDelays(f) = rttDelays(f) + 2 * D(path(i), path(i+1));
    end
end
%delay service by type
RTT_unicast = rttDelays(T(:,1) == 1);
RTT_anycast = rttDelays(T(:,1) == 2);

worstRTT_unicast = max(RTT_unicast);
avgRTT_unicast = mean(RTT_unicast);

worstRTT_anycast = max(RTT_anycast);
avgRTT_anycast = mean(RTT_anycast);

fprintf("Best Anycast Nodes: %d %d\n", bestAnycastNodes(1),bestAnycastNodes(2));
fprintf("Worst link load = %.2f Gbps\n",minWorstLinkLoad);

fprintf("Worst round-trip delay (unicast service)  = %.2f ms\n",worstRTT_unicast*1000);
fprintf("Average round-trip delay (unicast service)  = %.2f ms\n",avgRTT_unicast*1000);

fprintf("Worst round-trip delay (anycast service)  = %.2f ms\n",worstRTT_anycast*1000);
fprintf("Average round-trip delay (anycast service)  = %.2f ms\n",avgRTT_anycast*1000);


% d)
fprintf("12.d)\n");

% initialize variables to track the best combination
bestAnycastNodes = [];
minWorstRTT_anycast = inf;

Taux = zeros(nFlows,4);

% computing up to k=1 shortest paths for all flows from 1 to nFlows:
k= 1;

for c = 1:nCombinations
    anycastNodes = nodeCombinations(c,:);
    sP= cell(1,nFlows);
    nSP= zeros(1,nFlows);
    for f=1:nFlows
        if T(f,1) == 1 % unicast service
            [shortestPath, totalCost] = kShortestPath(D,T(f,2),T(f,3),k);
            sP{f}= shortestPath;
            nSP(f)= length(totalCost);
            Taux(f,:) = T(f,2:5);
        elseif T(f,1) == 2 % anycast service
            if ismember(T(f,2),anycastNodes)
                sP{f} = {T(f,2)};
                nSP(f) = 1;
                Taux(f,:) = T(f,2:5);
                Taux(f,2) = T(f,2);
            else %comparar totalCosts do shortest paths
                custo = inf;
                Taux(f,:) = T(f,2:5);
                for i=anycastNodes
                    [shortestPath, totalCost] = kShortestPath(D,T(f,2),i,k);
                    if totalCost<custo
                        sP{f} = shortestPath;
                        nSP(f) = 1;
                        custo = totalCost;
                        Taux(f,2) = i;
                    end
                end
            end
        end
    end
    
    rttDelays = zeros(nFlows,1);
    % calculate rtt delays
    for f = 1:nFlows
        path = sP{f}{1};
        for i = 1:length(path)-1
            rttDelays(f) = rttDelays(f) + 2 * D(path(i), path(i+1));
        end
    end
    %delay service by type
    RTT_unicast = rttDelays(T(:,1) == 1);
    RTT_anycast = rttDelays(T(:,1) == 2);

    worstRTT_unicast = max(RTT_unicast);
    avgRTT_unicast = mean(RTT_unicast);

    worstRTT_anycast = max(RTT_anycast);
    avgRTT_anycast = mean(RTT_anycast);
    
    if worstRTT_anycast < minWorstRTT_anycast
        bestAnycastNodes = anycastNodes;

        minWorstRTT_anycast = worstRTT_anycast;
        minAvgRTT_anycast = avgRTT_anycast;
        minWorstRTT_unicast = worstRTT_unicast;
        minAvgRTT_unicast = avgRTT_unicast;

        %compute link loads
        sol= ones(1,nFlows);
        Loads= calculateLinkLoads(nNodes,Links,Taux,sP,sol);
        worstLinkLoad= max(max(Loads(:,3:4)));
    end
end


fprintf("Best Anycast Nodes: %d %d\n", bestAnycastNodes(1),bestAnycastNodes(2));
fprintf("Worst link load = %.2f Gbps\n",worstLinkLoad);

fprintf("Worst round-trip delay (unicast service)  = %.2f ms\n",minWorstRTT_unicast*1000);
fprintf("Average round-trip delay (unicast service)  = %.2f ms\n",minAvgRTT_unicast*1000);

fprintf("Worst round-trip delay (anycast service)  = %.2f ms\n",minWorstRTT_anycast*1000);
fprintf("Average round-trip delay (anycast service)  = %.2f ms\n",minAvgRTT_anycast*1000);