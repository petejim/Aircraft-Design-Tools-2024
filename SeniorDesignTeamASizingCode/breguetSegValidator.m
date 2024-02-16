%% Team A

% Goal is to test the agreement of two different models for the performance
% of our aircraft. Mostly to test the implementation of our new breguet
% solver.

clc; clear;

%% Code

nSeg = 5; % Number of Segments

wRF = [100]; % Reserve fuel weight

eta = [0.8]; % Prop Efficiency

AR = [28]; % Aspect ratio

osw = [0.9]; % Oswald Efficiency

CD0 = [0.02500]; % self explanatory


% Call random segment generator

[bregTypes, dists, velocs, densitys, SFCs, wPayload, WS, EWF, totalDist] = testCaseGen(nSeg);


% Call weightFromSegments for each set of segments

[Result] = weightFromSegments(bregTypes,dists,velocs,densitys,SFCs,wPayload,wRF,WS,EWF,eta,AR,osw,CD0);

disp("Max Takeoff = " + Result(1) + " lbf")
disp("Fuel Weight = " + (Result(1) - (Result(1) * EWF + wPayload + wRF)) + " lbf")

MTOW = Result(1);

fFuel = Result(2:end,1);

disp("Desired range: "+ sum(dists) + " [nm]")


% Call the numerical solver from team F for each set of segments

[range,x,totT,t,avgV] = rangeFromFuelFractions(bregTypes,MTOW,fFuel,dists,velocs,densitys,SFCs,WS,EWF,eta,AR,osw,CD0);

disp("Calculated range: "+ range + " [nm]")

disp("Difference: " + abs(sum(dists) - range) + " [nm]")

timeDays = floor(totT/24);

timeHoursMinusDays = round(totT - timeDays * 24);

disp("Time to complete route: " + timeDays + " days, " + timeHoursMinusDays + " hour(s)")


% Compare fuel consumption

disp("Segement to Total Difference: " + abs(sum(dists) - totalDist) + " [nm]")



% 