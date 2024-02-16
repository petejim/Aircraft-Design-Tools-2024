function [Result] = weightFromSegments(bregTypes,dists,veloTAS,vWind,...
    altitudes,SFCs,wPayload,wRF,WS,EWF,eta,AR,osw,CD0)
%% INPUTS

% bregTypes = column vector of flag for breguet solution type   [0,1,or2]
% dists     = column vector of segment lengths                  [nm]
% veloTAS   = column vector of initial segment TAS              [KTAS]
% vWind     = column vector of average wind projected on plane 
%             heading vector                                    [kts]
% altitudes = column vector of altitude at the start of segment [ft]
% SFCs      = column vector of average SFC over segment         [lbf/hr/hp]
% wPayload  = payload weight                                    [lbf]
% wRF       = reserve fuel weight                               [lbf]
% WS        = wing loading of plane                             [lbf/ft^2]
% EWF       = empty weight fraction                             [unitless]
% eta       = propeller efficiency                              [unitless]
% AR        = aspect ratio of plane                             [unitless]
% osw       = oswald efficiency of plane                        [unitless]
% CD0       = zero lift drag coefficient                        [unitless]


%% Features

% Will calculate airplane weight based on idealized segments

% should return average speed or time eventually

% Eventually might give the altitude profile corresponding to chosen route




%% Code

% Density conversion
densitys = densFromAlt(altitudes);

%% Fuel fraction guess
wInitGuess = 10000;

initGuess = [wInitGuess;zeros(length(dists),1)];

distPrprtn = dists ./ sum(dists) .* (wInitGuess - wPayload - wRF) ./ wInitGuess;

fuelFractGuess = zeros(length(dists),1);

fuelFractGuess(1,1) = distPrprtn(1);

for i = 2:length(fuelFractGuess)

    fuelFractGuess(i,1) = distPrprtn(i) / (prod(1 - fuelFractGuess(1:i)));

end

initGuess(2:end) = fuelFractGuess;

%% Root finder

% Initialize the functions with the known values
breguetSysFSolve = @(inputs) breguetSys(inputs,bregTypes,dists,veloTAS,vWind,densitys,SFCs,wPayload,wRF,WS,EWF,eta,AR,osw,CD0);

% use fsolve to find roots, MTOW;f1;f2;f3

solutionFound = "false";

i = 1;

options = optimoptions("fsolve","Display","none");

while solutionFound == "false"

    [Result,fval,flag] = fsolve(breguetSysFSolve,initGuess,options); %,options

    if flag > 0 && abs(fval(1)) < 0.0001

        solutionFound = "true";

    else

        i = i + 1;

        if mod(i,2) == 0 && ((wInitGuess - i * 500) > 0)

            initGuess(1,1) = wInitGuess - i * 500;

        elseif ((wInitGuess - i * 500) > 0)

            initGuess(1,1) = wInitGuess + (i - 1) * 500;

        else

            initGuess(1,1) = wInitGuess + (i + 1) * 500 - 500;

            i = i + 1;

        end

    end

    if i > 50

        Result = Result * nan;

        break

    end

end

end

