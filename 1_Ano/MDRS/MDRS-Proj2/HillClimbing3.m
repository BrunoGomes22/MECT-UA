function [sol, load] = HillClimbing3(nNodes, Links, T, sP, nSP, sol, load)
    nFlows = size(T,1);    

    % If load is not provided, calculate it
    if nargin < 7 || isempty(load)
        Loads = calculateLinkBand1to1(nNodes, Links, T, sP, sol);
        load = max(max(Loads(:, 3:4)));
    end

    % Initialize local best variables
    bestLocalLoad = load;
    bestLocalSol = sol;

    % Hill Climbing Strategy
    improved = true;
    while improved
        improved = false; % Reset improvement flag
        % Test each flow
        for flow = 1:nFlows
            % Test each path of the flow
            for path = 1:nSP(flow)
                if path ~= sol(flow)
                    % Change the path for that flow
                    auxSol = sol;
                    auxSol(flow) = path;
                    % Calculate loads
                    Loads = calculateLinkBand1to1(nNodes, Links, T, sP, auxSol);
                    auxLoad = max(max(Loads(:, 3:4)));

                    % Check if the current load is better than the best local load
                    if auxLoad < bestLocalLoad
                        bestLocalLoad = auxLoad;
                        bestLocalSol = auxSol;
                        improved = true; % An improvement was found
                    end
                end
            end
        end

        % Update global solution and load if improved
        if improved
            load = bestLocalLoad;
            sol = bestLocalSol;
        end
    end
end
