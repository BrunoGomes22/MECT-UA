%% Task 3

clear;
clc;
load('InputDataProject2.mat')

v = 2e5; % speed of light on fiber km/s
k = 12; % number of candidate paths
tL = 60; % time limit in seconds
anycastNodes = [5, 14];

nNodes = size(Nodes, 1);
nLinks = size(Links, 1);
nFlows = size(T, 1);

% delay converted to ms
D = L / v;
D = D * 1e3;

Taux = zeros(nFlows,4);

sP = cell(2, nFlows);
nSP = zeros(1, nFlows);

% compute candidate paths for unicast service s = 1, s = 2 and anycast
for f = 1:nFlows
    if T(f, 1) == 1 % unicast service s = 1
        [shortestPath, totalCost] = kShortestPath(D, T(f, 2), T(f, 3), k);
        sP{1,f} = shortestPath;
        sP{2,f} = {};
        nSP(f) = length(totalCost);
        Taux(f,:) = T(f,2:5);
    elseif T(f, 1) == 2 % unicast service s = 2
        [firstPaths, secondPaths, totalPairCosts] = kShortestPathPairs(D, T(f, 2), T(f, 3), k);
        %sP{f} = [firstPaths; secondPaths];
        sP{1,f} = firstPaths;
        sP{2,f} = secondPaths;
        nSP(f) = length(totalPairCosts);
        Taux(f,:) = T(f,2:5);
    elseif T(f, 1) == 3 % anycast service
        if ismember(T(f,2),anycastNodes)
            sP{1,f} = {T(f,2)};
            sP{2,f} = {};
            nSP(f) = 1;
            Taux(f,:) = T(f,2:5);
            Taux(f,2) = T(f,2);
        else
            custo = inf;
            Taux(f,:) = T(f,2:5);
            for i=anycastNodes
                [shortestPath, totalCost] = kShortestPath(D,T(f,2),i,1);
                if totalCost<custo
                    sP{1,f} = shortestPath;
                    sP{2,f} = {};
                    nSP(f) = 1;
                    custo = totalCost;
                    Taux(f,2) = i;
                end
            end
        end
    end
end

fprintf('Running Multi-Start Hill Climbing... \n');
tic;
[bestSol, bestObjective, noCycles, bestTime, bestCycle] = MultiStartHillClimbingRandomizedGredy3(nNodes, Links, Taux, sP, nSP, tL);
elapsedTime = toc;

% Compute link loads for the best solution
Loads = calculateLinkBand1to1(nNodes, Links, Taux, sP, bestSol);
worstLinkLoad = max(max(Loads(:, 3:4)));

% Compute round-trip delays for all flows
roundTripDelays = zeros(nFlows, 1);
for f = 1:nFlows
    path = sP{1,f}{bestSol(f)}; %compute RTT of working paths
    for i = 1:length(path)-1
        roundTripDelays(f) = roundTripDelays(f) + 2 * D(path(i), path(i+1));
    end
end

% Delay by service type
RTT_unicast1 = roundTripDelays(T(:, 1) == 1);
RTT_unicast2 = roundTripDelays(T(:, 1) == 2);
RTT_anycast = roundTripDelays(T(:, 1) == 3);

% Worst and average delay
worstRTT_unicast1 = max(RTT_unicast1);
avgRTT_unicast1 = mean(RTT_unicast1);

worstRTT_unicast2 = max(RTT_unicast2);
avgRTT_unicast2 = mean(RTT_unicast2);

worstRTT_anycast = max(RTT_anycast);
avgRTT_anycast = mean(RTT_anycast);


fprintf('Unicast Service 1:\n');
fprintf('\tWorst Round-Trip Delay: %.2f ms\n', worstRTT_unicast1);
fprintf('\tAverage Round-Trip Delay: %.2f ms\n', avgRTT_unicast1);
fprintf('Unicast Service 2:\n');
fprintf('\tWorst Round-Trip Delay: %.2f ms\n', worstRTT_unicast2);
fprintf('\tAverage Round-Trip Delay: %.2f ms\n', avgRTT_unicast2);
fprintf('Anycast Service:\n');
fprintf('\tWorst Round-Trip Delay: %.2f ms\n', worstRTT_anycast);
fprintf('\tAverage Round-Trip Delay: %.2f ms\n', avgRTT_anycast);
fprintf('Worst Link Load: %.2f Gbps\n', worstLinkLoad);

fprintf('Performance Metrics:\n');
fprintf('\tTotal Cycles Run: %d\n', noCycles);
fprintf('\tTime for Best Solution: %.2f seconds\n', bestTime);
fprintf('\tCycles for Best Solution: %d\n', bestCycle);
fprintf('\tTotal Time Elapsed: %.2f seconds\n', elapsedTime);
