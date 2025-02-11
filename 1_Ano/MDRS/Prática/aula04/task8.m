%% Task 8

% a)

clear all
close all
clc

load('InputData.mat')
nNodes= size(Nodes,1);
nLinks= size(Links,1);
nFlows= size(T,1);

fprintf("8.a)\n");

for f = 1:8
    % Computing k=1 shortest paths for flows f= 1:8:
    k= 1;
    [shortestPath, totalCost] = kShortestPath(L,T(f,1),T(f,2),k);
    fprintf('Flow %d (%d -> %d): length = %d, Path = %s\n',f,T(f,1),T(f,2),totalCost,num2str(shortestPath{1}));
end

% b)
fprintf("8.b)\n");

% Computing up to k=6 shortest paths for all flows from 1 to nFlows:
k= 6;
sP= cell(1,nFlows);
nSP= zeros(1,nFlows);
for f=1:nFlows
    [shortestPath, totalCost] = kShortestPath(L,T(f,1),T(f,2),k);
    sP{f}= shortestPath;
    nSP(f)= length(totalCost);
end
% sP{f}{i} is the i-th path of flow f
% nSP(f) is the number of paths of flow f

% Visualizing all paths of flow 
sol= ones(1,nFlows);
Loads= calculateLinkLoads(nNodes,Links,T,sP,sol);
% Determine the worst link load:
maxLoad= max(max(Loads(:,3:4)));

fprintf('Worst link load = %1.2f\n',maxLoad);

for i = 1:length(Links)

    fprintf("{%d-%d}: %1.2f %1.2f\n",Loads(i,1),Loads(i,2),Loads(i,3),Loads(i,4))

end

% c)
fprintf("8.c)\n");

% Computing up to k=4 shortest paths for flow 1
k= 4;
f = 1;
[shortestPath, totalCost] = kShortestPath(L,T(f,1),T(f,2),k);

for i= 1:length(shortestPath)

    fprintf("Path %d = %s (length = %d)\n",i,num2str(shortestPath{i}),totalCost(i));
end

% d)
fprintf("8.d)\n");

% OPTIMIZATION ALGORITHM:
%   - based on random strategy
%   - with all candidate routing paths
%   - with time limit of 5 seconds
timeLimit= 5;
k= inf;
sP= cell(1,nFlows);
nSP= zeros(1,nFlows);
for f=1:nFlows
    [shortestPath, totalCost] = kShortestPath(L,T(f,1),T(f,2),k);
    sP{f}= shortestPath;
    nSP(f)= length(totalCost);
end
[bestSol,bestLoad,noCycles,avObjective] = RandomAlgorithm(nNodes,Links,T,sP,nSP,timeLimit);

%Output of routing solution:
fprintf('\nRouting paths of the solution:\n')
for f= 1:nFlows
    selectedPath= bestSol(f);
    fprintf('Flow %d - Path %d:  %s\n',f,selectedPath,num2str(sP{f}{selectedPath}));
end
bestLoads= calculateLinkLoads(nNodes,Links,T,sP,bestSol);
%Output of link loads of the routing solution:
fprintf('Worst link load of the best solution = %.2f\n',bestLoad);
fprintf('Link loads of the best solution:\n')
for i= 1:nLinks
    fprintf('{%d-%d}:\t%.2f\t%.2f\n',bestLoads(i,1),bestLoads(i,2),bestLoads(i,3),bestLoads(i,4))
end
%Output of performace values:
fprintf('No. of generated solutions = %d\n',noCycles);
fprintf('Avg. worst link load among all solutions= %.2f\n',avObjective);

%e)
fprintf("8.e)\n")

% OPTIMIZATION ALGORITHM:
%   - based on random strategy
%   - with 6 candidate routing paths
%   - with time limit of 5 seconds
timeLimit= 5;
k= 6;
sP= cell(1,nFlows);
nSP= zeros(1,nFlows);
for f=1:nFlows
    [shortestPath, totalCost] = kShortestPath(L,T(f,1),T(f,2),k);
    sP{f}= shortestPath;
    nSP(f)= length(totalCost);
end
[bestSol,bestLoad,noCycles,avObjective] = RandomAlgorithm(nNodes,Links,T,sP,nSP,timeLimit);

%Output of routing solution:
fprintf('\nRouting paths of the solution:\n')
for f= 1:nFlows
    selectedPath= bestSol(f);
    fprintf('Flow %d - Path %d:  %s\n',f,selectedPath,num2str(sP{f}{selectedPath}));
end
bestLoads= calculateLinkLoads(nNodes,Links,T,sP,bestSol);
%Output of link loads of the routing solution:
fprintf('Worst link load of the best solution = %.2f\n',bestLoad);
fprintf('Link loads of the best solution:\n')
for i= 1:nLinks
    fprintf('{%d-%d}:\t%.2f\t%.2f\n',bestLoads(i,1),bestLoads(i,2),bestLoads(i,3),bestLoads(i,4))
end
%Output of performace values:
fprintf('No. of generated solutions = %d\n',noCycles);
fprintf('Avg. worst link load among all solutions= %.2f\n',avObjective);

%g)
fprintf("8.g)\n")

% OPTIMIZATION ALGORITHM:
%   - based on random strategy
%   - with all candidate routing paths
%   - with time limit of 5 seconds
timeLimit= 5;
k= inf;
sP= cell(1,nFlows);
nSP= zeros(1,nFlows);
for f=1:nFlows
    [shortestPath, totalCost] = kShortestPath(L,T(f,1),T(f,2),k);
    sP{f}= shortestPath;
    nSP(f)= length(totalCost);
end
[bestSol,bestLoad,noCycles,avObjective] = GreedyRandomizedStrategy(nNodes,Links,T,sP,nSP,timeLimit);

%Output of routing solution:
fprintf('\nRouting paths of the solution:\n')
for f= 1:nFlows
    selectedPath= bestSol(f);
    fprintf('Flow %d - Path %d:  %s\n',f,selectedPath,num2str(sP{f}{selectedPath}));
end
bestLoads= calculateLinkLoads(nNodes,Links,T,sP,bestSol);
%Output of link loads of the routing solution:
fprintf('Worst link load of the best solution = %.2f\n',bestLoad);
fprintf('Link loads of the best solution:\n')
for i= 1:nLinks
    fprintf('{%d-%d}:\t%.2f\t%.2f\n',bestLoads(i,1),bestLoads(i,2),bestLoads(i,3),bestLoads(i,4))
end
%Output of performace values:
fprintf('No. of generated solutions = %d\n',noCycles);
fprintf('Avg. worst link load among all solutions= %.2f\n',avObjective);

% h)

fprintf("8.h)\n")

% OPTIMIZATION ALGORITHM:
%   - based on random strategy
%   - with all candidate routing paths
%   - with time limit of 5 seconds
timeLimit= 5;
k= 6;
sP= cell(1,nFlows);
nSP= zeros(1,nFlows);
for f=1:nFlows
    [shortestPath, totalCost] = kShortestPath(L,T(f,1),T(f,2),k);
    sP{f}= shortestPath;
    nSP(f)= length(totalCost);
end
[bestSol,bestLoad,noCycles,avObjective] = GreedyRandomizedStrategy(nNodes,Links,T,sP,nSP,timeLimit);

%Output of routing solution:
fprintf('\nRouting paths of the solution:\n')
for f= 1:nFlows
    selectedPath= bestSol(f);
    fprintf('Flow %d - Path %d:  %s\n',f,selectedPath,num2str(sP{f}{selectedPath}));
end
bestLoads= calculateLinkLoads(nNodes,Links,T,sP,bestSol);
%Output of link loads of the routing solution:
fprintf('Worst link load of the best solution = %.2f\n',bestLoad);
fprintf('Link loads of the best solution:\n')
for i= 1:nLinks
    fprintf('{%d-%d}:\t%.2f\t%.2f\n',bestLoads(i,1),bestLoads(i,2),bestLoads(i,3),bestLoads(i,4))
end
%Output of performace values:
fprintf('No. of generated solutions = %d\n',noCycles);
fprintf('Avg. worst link load among all solutions= %.2f\n',avObjective);