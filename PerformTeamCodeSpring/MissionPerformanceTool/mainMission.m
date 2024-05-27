%% Description

% This script calls the simulateMission function to simulate the performance
% of an aircraft. This is designed for an around the world aircraft. It relies on
% tools created by the Aircraft Design class of 2024.

%% Notes to danilo

% You disbled wind through multiplication by zero

%% Code

clear; close all; clc;

% Path to weather team code
addpath("../../WindAnalysisCode/");
addpath("AtmosphereFuncs/");
addpath("ODEs/");
addpath("ConfigFuncs/");
addpath("EngineData/");
addpath("VladoTakeoffData/")
%% Generate the aircraft object

WTO = 9077; % [lb] Maximum takeoff weight
S = 313; % [ft^2] Wing area
AR = 27; % Aspect ratio
osw = 0.95; % Oswald efficiency factor
CD0 = 0.02; % Zero lift drag coefficient
k = 1/(pi * osw * AR); % Lift induced drag factor
eta_p = 0.8; % Propeller efficiency
dCL_dAoA = 0.1; % Change in lift coefficient with respect to angle of attack
alpha0 = 0; % Zero lift angle of attack
dragPolarPath = "DragPolars/oldDragPolar.xlsx"; % Path to the drag polar
engineDeckPath = "EngineData/CD135_SL_double.mat"; % Path to the engine deck
engineDeckPathSingle = "EngineData/CD135_SL.mat"; % Path to single engine deck
tStep = 60; % Simulation time step [s] (Sim seems to be able to converge at 60s interval)
initAlt = 2500; % Initial altitude [ft]
levelOutAlt = 19990; % Altitude to level out at [ft]
designFuelWeight = 5123; % Design fuel weight [lb]
reserveFuelWeight = 150; % Reserve fuel weight [lb]

% Load in aircraft parameters
thePlane = DC_AirplaneClassV2(WTO, S, AR, osw, CD0, k, eta_p, dCL_dAoA, alpha0);

% Set drag polar
thePlane.setDragPolar(dragPolarPath);

% Load in propulsion data/model
thePlane.setEngine(engineDeckPath);
thePlane.engCount = 2;
% thePlane.CL = 0;
% thePlane.CD = 0;

% Set time
thePlane.tStep = tStep;

% Set temp offset
thePlane.deltaT = 0;

% Set initial altitude
thePlane.y = initAlt;

%% Route initialization

route.startDate = "01-Dec-2023";
route.numDays = 10; % This is the maximum number of days the mission will run for




%% Old Points

% route.controlPointsLatLong = ...
% [-21.45, -48.24;
% -26.2225, 28.0092;
% -31.9986, 115.5203;
% -34.46389, 172.8703;
% -30.000, -149.0000;
% -27.161, -109.4308;
% -58.6833, -64.933;
% -21.45, -48.24];

%% Anthony Points

route.controlPointsLatLong = [...
    -21.45, -48.24;
    -33.92,  18.59;
    -32.00, 115.52;
    -34.46, 172.87;
    -17.55,-149.62;
    -27.16,-109.43;
    -53.02, -70.72;
    -21.45, -48.24];

route.setWeatherDist = 100; % nm Distance between requested weather points
route.distance = 20290; % [NM]

%%%%%%%%%%%%%%%%%% CAUTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You must change this file name if you use a different route or starting
% date
route.windDataFile = "2023-12-01-10days.mat"; % Name for the wind data file


%% Set up the events

% Events are changes to the plane object that occur at specific points in
% the mission. These are non-continuous changes to the plane object. They 
% can also change the ode that is being solved. Events end when another
% event starts. However, the changes to the plane object are not undone.
% Another event can undo the changes made by a previous event.

% Import the basic events
[altitudeEvent, distanceEvent] = basicEvents();

% Define the events

% Structure array of events
events = struct([]);

% % Event 1: Takeoff
% events{1}.name = 'Takeoff';
% events{1}.planeConfig = @takeoffConfig;
% events{1}.ode = @takeoffFunc;
% events{1}.startCondition = @takeoffStart;
% events{1}.endCondition = @takeoffEnd;
% events{1}.expended = false; % This is a flag to indicate if the event has been used
% events{1}.repeat = false; % This is a flag to indicate if the event can be repeated

% % Event 2: Full power climb
% events{2}.name = 'Full power climb';
% events{2}.planeConfig = @bestClimbConfig;
% events{2}.ode = @bestClimb;
% events{2}.startCondition = @bestClimbStart;
% events{2}.endCondition = @bestClimbEnd;
% events{2}.expended = false;

% Event 1: constant altitude cruise
events{1}.name = 'Cruise';
events{1}.planeConfig = false;
% TODO: This should be anonymous function with the desired speed coded in
events{1}.ode = @(obj) constVConstAltCruise(obj, 95.5); % [KTAS]
events{1}.startCondition = @(obj) obj.y >= levelOutAlt; % [ft]
events{1}.expended = false;
events{1}.repeat = false;
events{1}.active = false;

% Event 2: End
events{2}.name = 'End';
events{2}.planeConfig = false;
events{2}.ode = false;
events{2}.startCondition = @(plane) plane.x >= 6076.11 * route.distance;
events{2}.expended = false;
events{2}.repeat = false;
events{2}.eventTerminal = true;
events{2}.active = false;

% Event 3: Cruise Climb
events{3}.name = 'Cruise Climb';
events{3}.planeConfig = @cruiseClimbConfig;
events{3}.ode = @(obj) cruiseClimb(obj, false, 95.5); % [KTAS]
events{3}.startCondition = @(x) true;
events{3}.expended = false;
events{3}.repeat = false;
events{3}.active = false;

% Event: Engine Switch
events{4}.name = 'OneEngine';
events{4}.planeConfig = @(obj) changeEngine(obj, engineDeckPathSingle, 1);
events{4}.ode = false;
% If the engine power used is less than 40% of two, use one
events{4}.startCondition = @(obj) powerSwitch(obj, 45, 1);
events{4}.expended = false;
events{4}.repeat = false;
events{4}.active = false;

% Event: Fuel Out
events{5}.name = 'FuelOut';
events{5}.planeConfig = false;
events{5}.ode = false;
events{5}.startCondition = @(obj) obj.W <= WTO - designFuelWeight; % Design fuel weight
events{5}.expended = false;
events{5}.repeat = false;
events{5}.active = false;
events{5}.eventTerminal = true;


%% Data Storage

% Set state variables to store (these should be the same as the fields in
% the aircraft object)
fieldsToStore = {'time', 'x', 'y', 'Vx', 'Vy', 'W', 'CL', 'CD', 'TAS', ...
    'tailwind', 'crosswind', 'SFC', 'engPowAvail', 'engPowUsed', 'drag'};


%% Simulate









datatable = simulateMission(thePlane, route, events, fieldsToStore);











%% Plots and results

W = table2array(datatable(2:end-1,"W"));
CL = table2array(datatable(2:end-1,"CL"));
CD = table2array(datatable(2:end-1,"CD"));
L_D = CL./CD;
x = missionConversions(table2array(datatable(2:end-1,"x")), "ftToNM");
TAS = missionConversions(table2array(datatable(2:end-1,"TAS")), "ft_sTokt");
tailwind = table2array(datatable(2:end-1,"tailwind"));
crosswind = table2array(datatable(2:end-1,"crosswind"));
Vx = missionConversions(table2array(datatable(2:end-1,"Vx")), "ft_sTokt");
y = table2array(datatable(2:end-1,"y"));
SFC = table2array(datatable(2:end-1,"SFC"));
powerAvail = table2array(datatable(2:end-1,"engPowAvail"));
powerUsed = table2array(datatable(2:end-1,"engPowUsed"));

fprintf('Fuel Consumed: %.2f lb\n', W(1) - W(end));

fprintf('Fuel Remaining: %.2f lb with %.2f lb reserve fuel\n', W(end) - (WTO - designFuelWeight), reserveFuelWeight);

%Print distance travelled
fprintf('Distance Travelled: %.2f NM\n', x(end));

plot(table2array(datatable(2:end-1,"x")),table2array(datatable(2:end-1,"CL")))




% Calculate shaft power needed with L/D, weight, and TAS
P_shaft_calc = missionConversions(W ./ L_D .* missionConversions(TAS, "ktToft_s") ./ eta_p, "lb_ft_sTohp");

figure
% Plot L/D vs x
plot(x,L_D)
xlabel("Distance [NM]")
ylabel("L/D")
title("L/D vs Distance")

figure
% Plot TAS and Vx vs x
plot(x,TAS)
hold on
plot(x,Vx)
xlabel("Distance [NM]")
ylabel("Speed [kts]")
title("Speed vs Distance")

figure
% Plot tailwind and crosswind vs x
plot(x,tailwind)
hold on
plot(x,crosswind)
xlabel("Distance [NM]")
ylabel("Wind [kts]")
title("Wind vs Distance")
legend("Tailwind","Crosswind")

figure
% Plot altitude vs x
plot(x,y)
xlabel("Distance [NM]")
ylabel("Altitude [ft]")
title("Altitude vs Distance")

figure
% plot SFC vs x
plot(x,SFC)
xlabel("Distance [NM]")
ylabel("SFC [lb/hr/hp]")
title("SFC vs Distance")

figure
% plot power avail and power used vs x
plot(x,powerAvail)
hold on
plot(x,powerUsed)
plot(x,P_shaft_calc)
xlabel("Distance [NM]")
ylabel("Power [ft-lb/s]")
title("Power vs Distance")
legend("Power Available","Power Used","Calc Shaft Power")
% legend("Power Available","Calc Shaft Power")
ylim([0,270])








% Print average CL/CD, Vx, tailwind, and crosswind, SFC

disp("Average CL/CD: " + extractAverageFromTable(datatable(2:end-1,:), "CL") / extractAverageFromTable(datatable(2:end-1,:), "CD"))
disp("Average Vx: " + missionConversions(extractAverageFromTable(datatable(2:end-1,:), "Vx"), "ft_sTokt"))
disp("Average Tailwind: " + extractAverageFromTable(datatable(2:end-1,:), "tailwind"))
disp("Average Crosswind: " + extractAverageFromTable(datatable(2:end-1,:), "crosswind"))
disp("Average SFC: " + extractAverageFromTable(datatable(2:end-1,:), "SFC"))
disp("Average TAS: " + missionConversions(extractAverageFromTable(datatable(2:end-1,:), "TAS"), "ft_sTokt"))



function [avgVal] = extractAverageFromTable(datatable, field)
    % This function extracts the average value of a field from a table
    % Inputs:
    % datatable: the table to extract the data from
    % field: the field to extract the average from
    % Outputs:
    
    allVals = table2array(datatable(:,field));
    leftVals = allVals(1:end-1);
    rightVals = allVals(2:end);

    % Get distance between each point
    dist = table2array(datatable(2:end,"x")) - table2array(datatable(1:end-1,"x"));

    % Calculate the average
    avgVal = sum((leftVals + rightVals) ./ 2 .* dist) / sum(dist);
end


function [] = changeEngine(plane, path, numEngine)

    plane.setEngine(path);

    plane.engCount = numEngine;

end

function [val] = powerSwitch(plane, percent, flag)

    % Function evaluates true if the power is greater (flag 0) or less (flag 1) than a given
    % percentage (0-100) of the total power

    if isempty(plane.engPowAvail) || isempty(plane.engPowUsed)
        val = false;
        return
    end

    switch flag
        case 0
            val = plane.engPowUsed/plane.engPowAvail > percent/100;
        case 1
            val = plane.engPowUsed/plane.engPowAvail < percent/100;
    end

end