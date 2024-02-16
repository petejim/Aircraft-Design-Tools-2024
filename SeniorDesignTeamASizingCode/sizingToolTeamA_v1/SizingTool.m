%% SIZING TOOL
% TEAM A: William Ho, Danilo Carrasco, Bonna H

clc; clear; close all;
addpath CarpetPlotFuncsModded/

%% MISSION PROFILE INPUTS

cruisealt = 9000; % Cruise Altitude (in feet)
takeoffalt = 2303; % Takeoff Altitude (in feet)
cruisev = 120; % Cruise Speed (in KTAS)
runway_length = 14000; % Runway Length (in feet)
dh_dt = 25/60; % Climb Rate to Avoid Terrain (in ft/s)
W_pl = 600; % Payload Weight (in lbs)
Range = 20650; % Range (in nm)

%% PERFORMANCE INPUTS

LD = 23; % Lift to Drag Ratio
SFC = .35; % Specific-Fuel Consumption
EWF = .24; % Empty Weight Fraction
Clmax = 1.5; % Maximum Lift Coefficient
CD0 = .017; % Parasitic Drag Coefficient
eta = 0.8; % Propeller Efficiency

%% PLOT FORMATTING

% Carpet Plot Ranges
LDmin = 20; % Min L/D line
LDmax = 30; % Max L/D line
SFCmin = .3; % Min SFC line
SFCmax = .425; % Max SFC line
EWFmin = .20; % Min EWF line
EWFmax = .30; % Max EWF line

% Plot Y-Axis Scales
carpetscale = 30000; % Carpet Plot Scale
constraintscale = .07; % Constraint Diagram Scale

%% FUNCTIONS 

% CARPET PLOT FUNCTION
[W_toval, W_eval, W_fval] = carpetPlotFunction(carpetscale,LD,SFC,EWF,eta, ...
    LDmin,LDmax,SFCmin,SFCmax,EWFmin,EWFmax,W_pl,Range);

% CONSTRAINT DIAGRAM FUNCTION
[W_S,W_P,P_W] = constraintDiagramFunction(constraintscale,cruisealt, ...
    takeoffalt,cruisev,runway_length,dh_dt,LD,Clmax,CD0,eta);

% DISPLAY FUNCTION
displayResults()
