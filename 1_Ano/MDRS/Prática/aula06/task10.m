%% Task 10

clear all
close all
clc

load('InputData2.mat')
nNodes= size(Nodes,1);
nLinks= size(Links,1);
nFlows= size(T,1);

MTTR= 24;
CC= 450;
MTBF= (CC*365*24)./L;
A= MTBF./(MTBF + MTTR);
A(isnan(A))= 1; % Matriz A tem as disponibilidades dos arcos
Alog= -log(A);

% a)

fprintf("10.a)\n");

% Computing up to k=1 pairs of link disjoint paths
% for all flows from 1 to nFlows:
k= 1;
sP= cell(2,nFlows);
nSP= zeros(1,nFlows);
av_sum = 0;
% sP{1,f}{i} is the 1st path of the i-th path pair of flow f
% sP{2,f}{i} is the 2nd path of the i-th path pair of flow f
% nSP(f) is the number of path pairs of flow f

for f=1:nFlows
    [shortestPath, totalCost] = kShortestPath(Alog,T(f,1),T(f,2),k);
    sP{1,f}= shortestPath;
    nSP(f)= length(totalCost);
    for i= 1:nSP(f)
        Aaux= Alog;
        path1= sP{1,f}{i};
        for j=2:length(path1)
            Aaux(path1(j),path1(j-1))= inf;
            Aaux(path1(j-1),path1(j))= inf;
        end
        [shortestPath, totalCost] = kShortestPath(Aaux,T(f,1),T(f,2),1);
        if ~isempty(shortestPath)
            sP{2,f}{i}= shortestPath{1};
        end
    end

    % calculate availabilty
    av = 1;
    % iterate through the first element of the path until the penultimate
    for node_idx = 1 : length(sP{1, f}{1}) - 1
        % first node of the link
        nodeA = sP{1, f}{1}(node_idx);
        % second node of the link
        nodeB = sP{1, f}{1}(node_idx + 1);
        % availability of the link between nodeA and nodeB
        av = av * A(nodeA, nodeB); % formula disponibilidade 
    end
    
    av_sum = av_sum + av;
    
    fprintf('Flow %d: Availability = %.7f - Path = %s\n', f, av, num2str(sP{1, f}{1}));

end

% b)

fprintf("10.b)\nAverage availability= %1.7f\n",av_sum/15)

% c)

fprintf("10.c)\n");

% Computing up to k=1 pairs of link disjoint paths
% for all flows from 1 to nFlows:
k= 1;
sP= cell(2,nFlows);
nSP= zeros(1,nFlows);
av_sum = 0;
% sP{1,f}{i} is the 1st path of the i-th path pair of flow f
% sP{2,f}{i} is the 2nd path of the i-th path pair of flow f
% nSP(f) is the number of path pairs of flow f

for f=1:nFlows
    [shortestPath, totalCost] = kShortestPath(Alog,T(f,1),T(f,2),k);
    sP{1,f}= shortestPath;
    nSP(f)= length(totalCost);
    for i= 1:nSP(f)
        Aaux= Alog;
        path1= sP{1,f}{i};
        for j=2:length(path1)
            Aaux(path1(j),path1(j-1))= inf;
            Aaux(path1(j-1),path1(j))= inf;
        end
        [shortestPath, totalCost] = kShortestPath(Aaux,T(f,1),T(f,2),1);
        if ~isempty(shortestPath)
            sP{2,f}{i}= shortestPath{1};
        end
    end

    % calculate availabilty
    av = ones(1,2);
    for idx = 1:2
        if idx == 2 && isempty(sP{2,f})
            break
        end

        % iterate through the first element of the path until the penultimate
        for node_idx = 1 : length(sP{idx, f}{1}) - 1
            % first node of the link
            nodeA = sP{idx, f}{1}(node_idx);
            % second node of the link
            nodeB = sP{idx, f}{1}(node_idx + 1);
            % availability of the link between nodeA and nodeB
            av(idx) = av(idx) * A(nodeA, nodeB); % formula disponibilidade 
        end
    end

    if ~isempty(sP{2,f})
        av(1) = 1 - ((1-av(1)) * (1-av(2)));
    end
    
    av_sum = av_sum + av(1);

    
    fprintf('Flow %d: Availability = %.7f -\tPath1 = %s\n', f, av(1), num2str(sP{1, f}{1}));
    if ~isempty((sP{2, f}))
        fprintf('\t\t\t\t\t\t\t\t\tPath2 = %s\n', num2str(sP{2, f}{1}));
    else
        fprintf('\t\t\t\t\t\t\t\t\tPath2 = \n');
    end
    

end

% d)

fprintf("10.b)\nAverage availability= %1.7f\n",av_sum/nFlows);

% e)

fprintf("10.e)\n");

% Computing the bandwidth capacity required on each link using the
% first path pair of each flow with 1+1 protection:
sol= ones(1,nFlows);
Loads= calculateLinkBand1plus1(nNodes,Links,T,sP,sol);
% Determine the worst bandwidth required among all links:
maxLoad= max(max(Loads(:,3:4)));
% Determine the total bandwidth required in all links:
TotalBand= sum(sum(Loads(:,3:4)));

fprintf("Worst bandwidth capacity = %2.1f Gbps\n",maxLoad);
fprintf("Total bandwidth capacity on all links = %3.1f Gbps\n",TotalBand);

for i = 1:length(Loads)
    fprintf("{%2d-%2d}: %6.2f %6.2f\n", Loads(i,1),Loads(i,2),Loads(i,3),Loads(i,4));

end

fprintf("10.f)\n");

% Computing the bandwidth capacity required on each link using the
% first path pair of each flow with 1:1 protection:
sol= ones(1,nFlows);
Loads= calculateLinkBand1to1(nNodes,Links,T,sP,sol);
% Determine the worst bandwidth required among all links:
maxLoad= max(max(Loads(:,3:4)));
% Determine the total bandwidth required in all links:
TotalBand= sum(sum(Loads(:,3:4)));

fprintf("Worst bandwidth capacity = %2.1f Gbps\n",maxLoad);
fprintf("Total bandwidth capacity on all links = %3.1f Gbps\n",TotalBand);

for i = 1:length(Loads)
    fprintf("{%2d-%2d}: %6.2f %6.2f\n", Loads(i,1),Loads(i,2),Loads(i,3),Loads(i,4));

end