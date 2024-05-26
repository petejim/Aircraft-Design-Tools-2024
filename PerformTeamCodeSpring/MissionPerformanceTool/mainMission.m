%% Description

% This script calls the simulateMission function to simulate the performance
% of an aircraft. This is designed for an around the world aircraft. It relies on
% tools created by the Aircraft Design class of 2024.

%%

%% Code

clear; close all; clc;

% Path to weather team code
addpath("../../WindAnalysisCode/");
addpath("AtmosphereFuncs/");
addpath("ODEs/");
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
dragPolarPath = "DragPolars/aethon_5_10.xlsx"; % Path to the drag polar
engineDeckPath = "EngineData/CD135_SL.mat"; % Path to the engine deck
delT = 1; % Simulation time step [s]

% Load in aircraft parameters
thePlane = DC_AirplaneClassV2(WTO, S, AR, osw, CD0, k, eta_p, dCL_dAoA, alpha0);

% Set drag polar
thePlane.setDragPolar(dragPolarPath);

% Load in propulsion data/model
thePlane.setEngine(engineDeckPath);

% Set time
thePlane.delT = delT;

%% Route initialization

route.startDate = "01-Dec-2023";
route.numDays = 10; % This is the maximum number of days the mission will run for
route.controlPointsLatLong = ...
[-21.45, -48.24;
-26.2225, 28.0092;
-31.9986, 115.5203;
-34.46389, 172.8703;
-30.000, -149.0000;
-27.161, -109.4308;
-58.6833, -64.933;
-21.45, -48.24];
route.setWeatherDist = 100; % nm Distance between requested weather points

% Load in the route data (coordinates, distance, airport elevation)

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

% Event 1: Takeoff
events{1}.name = 'Takeoff';
events{1}.planeConfig = @takeoffConfig;
events{1}.ode = @takeoffFunc;
events{1}.startCondition = @takeoffStart;
events{1}.endCondition = @takeoffEnd;
events{1}.expended = false; % This is a flag to indicate if the event has been used

% Event 2: Full power climb
events{2}.name = 'Full power climb';
events{2}.planeConfig = @bestClimbConfig;
events{2}.ode = @bestClimb;
events{2}.startCondition = @bestClimbStart;
events{2}.endCondition = @bestClimbEnd;
events{2}.expended = false;

%% Data Storage

% Set state variables to store (these should be the same as the fields in
% the aircraft object)
fieldsToStore = {'time', 'x', 'y', 'Vx', 'Vy', 'Ax', 'Ay'};


%% Simulate

simulateMission(thePlane, route, events, fieldsToStore);






