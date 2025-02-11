clear all
close all
clc

load('InputDataProject2.mat')
nNodes= size(Nodes,1);
nLinks= size(Links,1);
nFlows= size(T,1);

% a)
% anycast services are provided by network nodes 3 and 10
fprintf("1.a)\n");

anycastNodes = [3 10];
D = L/2e5;

Taux = zeros(nFlows,4);

% Computing up to k=1 shortest paths for all flows from 1 to nFlows:
k= 1;
sP= cell(1,nFlows);
nSP= zeros(1,nFlows);
for f=1:nFlows
    if T(f,1) == 1 || T(f,1) == 2  % unicast service
        [shortestPath, totalCost] = kShortestPath(D,T(f,2),T(f,3),k);
        sP{f}= shortestPath;
        nSP(f)= length(totalCost);
        Taux(f,:) = T(f,2:5);
    elseif T(f,1) == 3 % anycast service
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

for f = 1:nFlows
    path = sP{f}{1};
    for i = 1:length(path)-1
        rttDelays(f) = rttDelays(f) + 2 * D(path(i), path(i+1));
    end
end

RTT_unicast1 = rttDelays(T(:,1) == 1);
RTT_unicast2 = rttDelays(T(:,1) == 2);

RTT_anycast = rttDelays(T(:,1) == 3);

worstRTT_unicast1 = max(RTT_unicast1);
avgRTT_unicast1 = mean(RTT_unicast1);

worstRTT_unicast2 = max(RTT_unicast2);
avgRTT_unicast2 = mean(RTT_unicast2);

worstRTT_anycast = max(RTT_anycast);
avgRTT_anycast = mean(RTT_anycast);

fprintf("Service unicast 1:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",worstRTT_unicast1*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",avgRTT_unicast1*1000);

fprintf("Service unicast 2:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",worstRTT_unicast2*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",avgRTT_unicast2*1000);

fprintf("Service anycast:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",worstRTT_anycast*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",avgRTT_anycast*1000);


% b)
fprintf("1.b)\n");
% Compute the link loads using the first (shortest) path of each flow:
sol= ones(1,nFlows);
Loads= calculateLinkLoads(nNodes,Links,Taux,sP,sol);
% Determine the worst link load:
maxLoad= max(max(Loads(:,3:4)));

fprintf("Worst link load = %.2f Gbps\n",maxLoad);

for i = 1:nLinks
    fprintf('{%-2d - %-2d}        %8.2f %8.2f\n', Loads(i,1), Loads(i,2), Loads(i,3), Loads(i,4));
end

%c)
fprintf("1.c)\n");

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
        if T(f,1) == 1 || T(f,1) == 2  % unicast service
            [shortestPath, totalCost] = kShortestPath(D,T(f,2),T(f,3),k);
            sP{f}= shortestPath;
            nSP(f)= length(totalCost);
            Taux(f,:) = T(f,2:5);
        elseif T(f,1) == 3 % anycast service
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


fprintf("Selected Anycast Nodes: %d %d\n", bestAnycastNodes(1),bestAnycastNodes(2));

% compute the round-trip delays for the best combination
sP= cell(1,nFlows);
nSP= zeros(1,nFlows);
for f=1:nFlows
    if T(f,1) == 1 || T(f,1) == 2  % unicast service
        [shortestPath, totalCost] = kShortestPath(D,T(f,2),T(f,3),k);
        sP{f}= shortestPath;
        nSP(f)= length(totalCost);
        Taux(f,:) = T(f,2:5);
    elseif T(f,1) == 3 % anycast service
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
RTT_unicast1 = rttDelays(T(:,1) == 1);
RTT_unicast2 = rttDelays(T(:,1) == 2);

RTT_anycast = rttDelays(T(:,1) == 3);

worstRTT_unicast1 = max(RTT_unicast1);
avgRTT_unicast1 = mean(RTT_unicast1);

worstRTT_unicast2 = max(RTT_unicast2);
avgRTT_unicast2 = mean(RTT_unicast2);

worstRTT_anycast = max(RTT_anycast);
avgRTT_anycast = mean(RTT_anycast);

fprintf("Service unicast 1:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",worstRTT_unicast1*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",avgRTT_unicast1*1000);

fprintf("Service unicast 2:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",worstRTT_unicast2*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",avgRTT_unicast2*1000);

fprintf("Service anycast:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",worstRTT_anycast*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",avgRTT_anycast*1000);

fprintf("Worst link load = %.2f Gbps\n",minWorstLinkLoad);

%d)
fprintf("1.d)\n");

minWorstRTT_anycast = inf;
bestAnycastNodes = [];

Taux = zeros(nFlows,4);

for c = 1:nCombinations
    anycastNodes = nodeCombinations(c,:);
    sP= cell(1,nFlows);
    nSP= zeros(1,nFlows);
    for f=1:nFlows
        if T(f,1) == 1 || T(f,1) == 2  % unicast service
            [shortestPath, totalCost] = kShortestPath(D,T(f,2),T(f,3),k);
            sP{f}= shortestPath;
            nSP(f)= length(totalCost);
            Taux(f,:) = T(f,2:5);
        elseif T(f,1) == 3 % anycast service
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

    RTT_unicast1 = rttDelays(T(:, 1) == 1);
    RTT_unicast2 = rttDelays(T(:, 1) == 2);
    RTT_anycast = rttDelays(T(:, 1) == 3);

    worstRTT_anycast = max(RTT_anycast);

    if worstRTT_anycast < minWorstRTT_anycast
        minWorstRTT_anycast = worstRTT_anycast;
        bestAnycastNodes = anycastNodes;
        bestRTT_unicast1 = RTT_unicast1;
        bestRTT_unicast2 = RTT_unicast2;
        bestRTT_anycast = RTT_anycast;

        %compute link loads
        sol= ones(1,nFlows);
        Loads= calculateLinkLoads(nNodes,Links,Taux,sP,sol);
        maxLoad= max(max(Loads(:,3:4)));


    end

end

fprintf('Selected Anycast Nodes: %d %d\n', bestAnycastNodes(1), bestAnycastNodes(2));

fprintf("Service unicast 1:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",max(bestRTT_unicast1)*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",mean(bestRTT_unicast1)*1000);

fprintf("Service unicast 2:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",max(bestRTT_unicast2)*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",mean(bestRTT_unicast2)*1000);

fprintf("Service anycast:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",minWorstRTT_anycast*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",mean(bestRTT_anycast)*1000);

fprintf("Worst link load = %.2f Gbps\n",maxLoad);


%e)
fprintf("1.e)\n");

minAvgRTT_anycast = inf;
bestAnycastNodes = [];

Taux = zeros(nFlows,4);

for c = 1:nCombinations
    anycastNodes = nodeCombinations(c,:);
    sP= cell(1,nFlows);
    nSP= zeros(1,nFlows);
    for f=1:nFlows
        if T(f,1) == 1 || T(f,1) == 2  % unicast service
            [shortestPath, totalCost] = kShortestPath(D,T(f,2),T(f,3),k);
            sP{f}= shortestPath;
            nSP(f)= length(totalCost);
            Taux(f,:) = T(f,2:5);
        elseif T(f,1) == 3 % anycast service
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

    RTT_unicast1 = rttDelays(T(:, 1) == 1);
    RTT_unicast2 = rttDelays(T(:, 1) == 2);
    RTT_anycast = rttDelays(T(:, 1) == 3);

    avgRTT_anycast = mean(RTT_anycast);

    if avgRTT_anycast < minAvgRTT_anycast
        minAvgRTT_anycast = avgRTT_anycast;
        bestAnycastNodes = anycastNodes;
        bestRTT_unicast1 = RTT_unicast1;
        bestRTT_unicast2 = RTT_unicast2;
        bestRTT_anycast = RTT_anycast;

        %compute link loads
        sol= ones(1,nFlows);
        Loads= calculateLinkLoads(nNodes,Links,Taux,sP,sol);
        maxLoad= max(max(Loads(:,3:4)));

    end

end

fprintf('Selected Anycast Nodes: %d %d\n', bestAnycastNodes(1), bestAnycastNodes(2));

fprintf("Service unicast 1:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",max(bestRTT_unicast1)*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",mean(bestRTT_unicast1)*1000);

fprintf("Service unicast 2:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",max(bestRTT_unicast2)*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",mean(bestRTT_unicast2)*1000);

fprintf("Service anycast:\n")
fprintf("\tWorst round-trip delay  = %.2f ms\n",max(bestRTT_anycast)*1000);
fprintf("\tAverage round-trip delay  = %.2f ms\n",minAvgRTT_anycast*1000);

fprintf("Worst link load = %.2f Gbps\n",maxLoad);

