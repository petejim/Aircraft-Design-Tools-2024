function [resVect] = breguetSys(solvVect,bregTypes,dists,veloTAS,winds,...
    densitys,SFCs,wPayload,wRF,WS,EWF,eta,AR,osw,CD0)
%% Description
% Is the function that fsolve attempts to find the roots

%% Code

MTOW = solvVect(1,1);

fFuel = solvVect(2:end,1);

weight = zeros(length(bregTypes),1);

CL1 = zeros(length(bregTypes),1);

LD1 = zeros(length(bregTypes),1);

resVect(1,1) = (MTOW * prod(1-fFuel(1:end)) - wPayload - wRF) / MTOW - EWF;

% induced drag coefficient 
k = 1 / (pi * osw * AR);

LDmax = sqrt(CD0/k)/(2*CD0);

S = MTOW / WS;

for i = 1:length(fFuel)+1

    % You might be able to think of a way to vectorize this
    if i == 1
        weight(i,1) = MTOW;
    else
        weight(i,1) = MTOW * prod((1-fFuel(1:(i-1))));
    end

end

for i = 1:length(fFuel)

    updWS = weight(i)/S;
    % Evaluate initial LD and CL using wing loading
    [CL1(i,1),LD1(i,1)] = find_LD_and_CL(veloTAS(i),densitys(i),...
        updWS,AR,osw,CD0);

    if bregTypes(i) == 0
        
        % time in hours
        tSeg = 2 * LD1(i) * eta * 550 * (weight(i+1)^(-1/2) - ...
                weight(i)^(-1/2)) / (SFCs(i) * ...
                (2/(densitys(i) * S * CL1(i)))^(1/2));

        % Constant altitude and L/D solution (plus additional distance due
        % to wind) 
        resVect(i+1,1) = 1980000 / 6076.11549 * LD1(i) * eta ...
            / SFCs(i) * log(1/(1-fFuel(i))) + winds(i) * tSeg - dists(i);

    elseif bregTypes(i) == 1
        
        % Constant velocity and L/D solution (same eq as previous)
        resVect(i+1,1) = 1980000 / 6076.11549 * LD1(i) * eta ...
            / SFCs(i) * log(1/(1-fFuel(i))) + dists(i) * ...
            (winds(i)/(veloTAS(i) + winds(i)) - 1);

    elseif bregTypes(i) == 2

        % Constant velocity and altitude solution ( check atan if
        % there is an error)
        resVect(i+1,1) = 2 * LDmax * 1980000 / 6076.11549 * eta / ...
            SFCs(i) * atan(LD1(i) * fFuel(i) / (2 * LDmax * (1 - ...
            k * CL1(i) * LD1(i) * fFuel(i)))) + dists(i) * ...
            (winds(i)/(veloTAS(i) + winds(i)) - 1);

    else

        error("Invalid breguet solution type flag")

    end

end