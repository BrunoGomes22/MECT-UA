function [bestSol, bestObjective, noCycles, bestTime, bestCycle] = MultiStartHillClimbingRandomizedGredy3(nNodes, Links, T, sP, nSP, timeLimit)
    t = tic; % Start the timer
    nFlows = size(T, 1); % Number of flows
    bestObjective = inf; % Initialize best objective to infinity
    noCycles = 0; % Initialize cycle counter
    aux = 0; % Auxiliary variable to calculate average objective
    bestTime = 0;
    bestCycle = 0; 
    while toc(t) < timeLimit
        % Initialize solution using greedy randomized approach
        sol = zeros(1, nFlows);
        ordem = randperm(nFlows); % Randomized order of flows
        for f = ordem
            temp = inf; % Temporary best load
            % Greedy selection of the best path for the flow
            for p = 1:nSP(f)
                sol(f) = p;
                Loads = calculateLinkBand1to1(nNodes, Links, T, sP, sol);
                load = max(max(Loads(:, 3:4)));
                if load < temp
                    temp = load;
                    best_p = p; % Keep track of the best path
                end
            end
            sol(f) = best_p; % Assign the best path to the solution
        end

        % Calculate initial load for the greedy randomized solution
        Loads = calculateLinkBand1to1(nNodes, Links, T, sP, sol);
        load = max(max(Loads(:, 3:4)));

        % Refine solution using Hill Climbing
        [sol, load] = HillClimbing3(nNodes, Links, T, sP, nSP, sol, load);

        % Update best solution and objective
        noCycles = noCycles + 1;
        aux = aux + load;
        if load < bestObjective
            bestSol = sol;
            bestObjective = load;
            bestTime = toc(t);
            bestCycle = noCycles;
        end
    end
end
