clear all
close all
%% 2.a)
load('InputDataProject2.mat')

v = 2e5; %speed of ligh on fiber km/s
k = 6; % k number of shortest paths
tL = 30; % time Limit
anycastNodes = [3, 10];

nNodes = size(Nodes, 1);
nFlows = size(T,1);

%delay converted to ms
D = L / v;
D = D * 1e3;

sP = cell(1,nFlows);
nSP = zeros(1,nFlows);

T_aux = zeros(nFlows,4);

for f = 1:nFlows
    if T(f,1) == 1 || T(f,1) == 2 % unicast
        [shortestPath, totalCost] = kShortestPath(D, T(f,2), T(f,3), k);
        sP{f} = shortestPath;
        nSP(f) = length(totalCost);
        T_aux(f,:) = T(f,2:5);
    elseif T(f,1) == 3 % anycast service
        if ismember(T(f,2),anycastNodes)
            sP{f} = {T(f,2)};
            nSP(f) = 1;
            T_aux(f,:) = T(f,2:5);
            T_aux(f,2) = T(f,2);
        else %comparar totalCosts do shortest paths
            custo = inf;
            T_aux(f,:) = T(f,2:5);
            for i=anycastNodes
                [shortestPath, totalCost] = kShortestPath(D,T(f,2),i,1);
                if totalCost<custo
                    sP{f} = shortestPath;
                    nSP(f) = 1;
                    custo = totalCost;
                    T_aux(f,2) = i;
                end
            end
        end
    end
end

% Multi-Start Hill Climbing Algorithm with Greedy Randomized Start
fprintf('Running Multi-Start Hill Climbing... \n');
tic;
[bestSol, ~, noCycles, bestTime, bestCycle] = MultiStartHillClimbingRandomizedGredy(nNodes, Links, T_aux, sP, nSP, tL);
elapsedTime = toc;

Loads= calculateLinkLoads(nNodes,Links,T_aux,sP,bestSol);
% Determine the worst link load:
worstLinkLoad = max(max(Loads(:,3:4)));

% Round-Trip Delays for all flows
roundTripDelays = zeros(nFlows, 1);
for f = 1:nFlows
    path = sP{f}{bestSol(f)};
    for i = 1:length(path)-1
        roundTripDelays(f) = roundTripDelays(f) + 2 * D(path(i), path(i+1));
    end
end

% Delay by service type
RTT_unicast1 = roundTripDelays(T(:,1) == 1);
RTT_unicast2 = roundTripDelays(T(:,1) == 2);
RTT_anycast = roundTripDelays(T(:,1) == 3);

% Worst and average delay
worstRTT_unicast1 = max(RTT_unicast1);
avgRTT_unicast1 = mean(RTT_unicast1);

worstRTT_unicast2 = max(RTT_unicast2);
avgRTT_unicast2 = mean(RTT_unicast2);

worstRTT_anycast = max(RTT_anycast);
avgRTT_anycast = mean(RTT_anycast);


% Display results
fprintf('Task 2.a Results:\n');
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


clear all
close all

%% 2.b)
load('InputDataProject2.mat')

v = 2e5; % speed of light on fiber km/s
k = 6; % k number of shortest paths
tL = 30; % time Limit
anycastNodes = [1, 6];

nNodes = size(Nodes, 1);
nFlows = size(T,1);

% Delay converted to ms
D = L / v;
D = D * 1e3;

sP = cell(1,nFlows);
nSP = zeros(1,nFlows);

T_aux = zeros(nFlows,4);

for f = 1:nFlows
    if T(f,1) == 1 || T(f,1) == 2
        [shortestPath, totalCost] = kShortestPath(D, T(f,2), T(f,3), k);
        sP{f} = shortestPath;
        nSP(f) = length(totalCost);
        T_aux(f,:) = T(f,2:5);
    elseif T(f,1) == 3 
        if ismember(T(f,2), anycastNodes)
            sP{f} = {T(f,2)};
            nSP(f) = 1;
            T_aux(f,:) = T(f,2:5);
            T_aux(f,2) = T(f,2);
        else 
            custo = inf;
            T_aux(f,:) = T(f,2:5);
            for i = anycastNodes
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), i, 1);
                if totalCost < custo
                    sP{f} = shortestPath;
                    nSP(f) = 1;
                    custo = totalCost;
                    T_aux(f,2) = i;
                end
            end
        end
    end
end

% Multi-Start Hill Climbing Algorithm with Greedy Randomized Start
fprintf('Running Multi-Start Hill Climbing... \n');
tic;
[bestSol, bestObjective, noCycles, bestTime, bestCycle] = MultiStartHillClimbingRandomizedGredy(nNodes, Links, T_aux, sP, nSP, tL);
elapsedTime = toc;

Loads = calculateLinkLoads(nNodes, Links, T_aux, sP, bestSol);

% Determine the worst link load:
worstLinkLoad = max(max(Loads(:,3:4)));

% Round-Trip Delays for all flows
roundTripDelays = zeros(nFlows, 1);
for f = 1:nFlows
    path = sP{f}{bestSol(f)};
    for i = 1:length(path)-1
        roundTripDelays(f) = roundTripDelays(f) + 2 * D(path(i), path(i+1));
    end
end

% Delay by service type
RTT_unicast1 = roundTripDelays(T(:,1) == 1);
RTT_unicast2 = roundTripDelays(T(:,1) == 2);
RTT_anycast = roundTripDelays(T(:,1) == 3);

% Worst and average delay
worstRTT_unicast1 = max(RTT_unicast1);
avgRTT_unicast1 = mean(RTT_unicast1);

worstRTT_unicast2 = max(RTT_unicast2);
avgRTT_unicast2 = mean(RTT_unicast2);

worstRTT_anycast = max(RTT_anycast);
avgRTT_anycast = mean(RTT_anycast);

% Display results
fprintf('Task 2.b Results:\n');
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

clear all
close all

%% 2.c)
load('InputDataProject2.mat')

v = 2e5; % speed of light on fiber km/s
k = 6; % k number of shortest paths
tL = 30; % time Limit
anycastNodes = [4, 12];

nNodes = size(Nodes, 1);
nFlows = size(T,1);

% Delay converted to ms
D = L / v;
D = D * 1e3;

sP = cell(1,nFlows);
nSP = zeros(1,nFlows);

T_aux = zeros(nFlows,4);

for f = 1:nFlows
    if T(f,1) == 1 || T(f,1) == 2
        [shortestPath, totalCost] = kShortestPath(D, T(f,2), T(f,3), k);
        sP{f} = shortestPath;
        nSP(f) = length(totalCost);
        T_aux(f,:) = T(f,2:5);
    elseif T(f,1) == 3 
        if ismember(T(f,2), anycastNodes)
            sP{f} = {T(f,2)};
            nSP(f) = 1;
            T_aux(f,:) = T(f,2:5);
            T_aux(f,2) = T(f,2);
        else 
            custo = inf;
            T_aux(f,:) = T(f,2:5);
            for i = anycastNodes
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), i, 1);
                if totalCost < custo
                    sP{f} = shortestPath;
                    nSP(f) = 1;
                    custo = totalCost;
                    T_aux(f,2) = i;
                end
            end
        end
    end
end

% Multi-Start Hill Climbing Algorithm with Greedy Randomized Start
fprintf('Running Multi-Start Hill Climbing... \n');
tic;
[bestSol, ~, noCycles, bestTime, bestCycle] = MultiStartHillClimbingRandomizedGredy(nNodes, Links, T_aux, sP, nSP, tL);
elapsedTime = toc;

Loads = calculateLinkLoads(nNodes, Links, T_aux, sP, bestSol);

% Determine the worst link load:
worstLinkLoad = max(max(Loads(:,3:4)));

% Round-Trip Delays for all flows
roundTripDelays = zeros(nFlows, 1);
for f = 1:nFlows
    path = sP{f}{bestSol(f)};
    for i = 1:length(path)-1
        roundTripDelays(f) = roundTripDelays(f) + 2 * D(path(i), path(i+1));
    end
end

% Delay by service type
RTT_unicast1 = roundTripDelays(T(:,1) == 1);
RTT_unicast2 = roundTripDelays(T(:,1) == 2);
RTT_anycast = roundTripDelays(T(:,1) == 3);

% Worst and average delay
worstRTT_unicast1 = max(RTT_unicast1);
avgRTT_unicast1 = mean(RTT_unicast1);

worstRTT_unicast2 = max(RTT_unicast2);
avgRTT_unicast2 = mean(RTT_unicast2);

worstRTT_anycast = max(RTT_anycast);
avgRTT_anycast = mean(RTT_anycast);

% Display results
fprintf('Task 2.c Results:\n');
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

clear all
close all

%% 2.d)
load('InputDataProject2.mat')

v = 2e5; % speed of light on fiber km/s
k = 6; % k number of shortest paths
tL = 30; % time Limit
anycastNodes = [5, 14];

nNodes = size(Nodes, 1);
nLinks = size(Links, 1);
nFlows = size(T,1);

% Delay converted to ms
D = L / v;
D = D * 1e3;

sP = cell(1,nFlows);
nSP = zeros(1,nFlows);

T_aux = zeros(nFlows,4);

for f = 1:nFlows
    if T(f,1) == 1 || T(f,1) == 2
        [shortestPath, totalCost] = kShortestPath(D, T(f,2), T(f,3), k);
        sP{f} = shortestPath;
        nSP(f) = length(totalCost);
        T_aux(f,:) = T(f,2:5);
    elseif T(f,1) == 3 
        if ismember(T(f,2), anycastNodes)
            sP{f} = {T(f,2)};
            nSP(f) = 1;
            T_aux(f,:) = T(f,2:5);
            T_aux(f,2) = T(f,2);
        else 
            custo = inf;
            T_aux(f,:) = T(f,2:5);
            for i = anycastNodes
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), i, 1);
                if totalCost < custo
                    sP{f} = shortestPath;
                    nSP(f) = 1;
                    custo = totalCost;
                    T_aux(f,2) = i;
                end
            end
        end
    end
end

% Multi-Start Hill Climbing Algorithm with Greedy Randomized Start
fprintf('Running Multi-Start Hill Climbing... \n');
tic;
[bestSol, bestObjective, noCycles, bestTime, bestCycle] = MultiStartHillClimbingRandomizedGredy(nNodes, Links, T_aux, sP, nSP, tL);
elapsedTime = toc;

Loads = calculateLinkLoads(nNodes, Links, T_aux, sP, bestSol);

% Determine the worst link load:
worstLinkLoad = max(max(Loads(:,3:4)));

% Round-Trip Delays for all flows
roundTripDelays = zeros(nFlows, 1);
for f = 1:nFlows
    path = sP{f}{bestSol(f)};
    for i = 1:length(path)-1
        roundTripDelays(f) = roundTripDelays(f) + 2 * D(path(i), path(i+1));
    end
end

% Delay by service type
RTT_unicast1 = roundTripDelays(T(:,1) == 1);
RTT_unicast2 = roundTripDelays(T(:,1) == 2);
RTT_anycast = roundTripDelays(T(:,1) == 3);

% Worst and average delay
worstRTT_unicast1 = max(RTT_unicast1);
avgRTT_unicast1 = mean(RTT_unicast1);

worstRTT_unicast2 = max(RTT_unicast2);
avgRTT_unicast2 = mean(RTT_unicast2);

worstRTT_anycast = max(RTT_anycast);
avgRTT_anycast = mean(RTT_anycast);

% Display results
fprintf('Task 2.d Results:\n');
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


