clc; close all; clear;

% Aircraft Performance MAIN 

% Perfromance script to integrate:
% > Aircraft Configuration/Engine Selection 
% > Route
% > Weather: Wing vectors along route
% > Flight profile

addpath(genpath("..\"))

Aircrafts =[    
%     "T1_Baseline_Aircraft.txt";
        "T1_3Fuse_Simple.txt";
    ];

Missions = [    
%                 "T1_CC-C.txt";
%                 "T1_Climb-C.txt";
%                 "T1_Climb-CC-C.txt";
                "T1_C8000.txt";
                ];

all_results = cell(length(Aircrafts),length(Missions));
all_results_table = cell(length(Aircrafts),length(Missions));
all_results_cases = strings(size(all_results));


for aircraft_case = 1:length(Aircrafts)
    aircraft_filename = Aircrafts(aircraft_case);
for mission_case = 1:length(Missions)
    sector_filename = Missions(mission_case);
    all_results_cases(aircraft_case,mission_case) = aircraft_filename + " w/ " + sector_filename;

%% Aircraft Configuration
aircraft_info = readlines(aircraft_filename);
disp("-------------------------------------------------------------------------")
disp("Aircraft Parameters:  " + aircraft_filename)
Wto = str2double(aircraft_info(3)); % Takeoff Weight
AP = [str2double(aircraft_info(9)),str2double(aircraft_info(11)),str2double(aircraft_info(13))]; % AP = [wing area (ft^2),AR, Eta]
k = str2double(aircraft_info(5)); % Induced Drag Constant
CD0 = str2double(aircraft_info(7)); % Parasitic Drag
Wf = str2double(aircraft_info(31)); % Fuel Weight [lbf]

%% Engine Selection
MinSFC = str2double(aircraft_info(17)); 
MaxBHP = str2double(aircraft_info(19));
EngineType = aircraft_info(23);
n = str2double(aircraft_info(21));
service_ceiling = str2double(aircraft_info(25));
n_engine = str2double(aircraft_info(27));
[SeaLevelEngine] = BuildEngineDeck(EngineType, MinSFC, MaxBHP, n);
SeaLevelEngine(:,1) = SeaLevelEngine(:,1)*n_engine;

%% Route and Weather
% Import Flight Profile from text file
disp("Mission Parameters:   " + sector_filename)
disp(" ")
route = readlines(sector_filename); %%%
point_dist = str2double(route(2));
n_control = str2double(route(4));
alt_airport = str2double(route(6));
dates = route(8:17);
control_point_cells = cellfun(@(x) split(x, ','), route(19:19+n_control-1,1), 'UniformOutput', false);
control_points_latlong = nan(n_control,2);
for i = 1:length(control_point_cells)
    for j = 1:2
        control_points_latlong(i,j) = str2double(control_point_cells{i}{j});
    end
end
sectors_cells = cellfun(@(x) split(x, ','), route(19+n_control+1:end,1), 'UniformOutput', false);
sectors = nan(length(sectors_cells));
for i = 1:length(sectors_cells)
    for j = 1:8
        sectors(i,j) = str2double(sectors_cells{i}{j});
    end
end


% Sector Table Label
sectors_column_labels = {'FlightType', 'Altitude1 [ft]', 'Altitude2 [ft]', 'TAS [knots]',	'VertSpeed', 'Distance [NM]', 'timestep [sec]', 'Optimal_Cl'};
sectors_table = array2table(sectors, 'VariableNames', sectors_column_labels);


%% Weather Initialization
global WindX
global WindY
global WindTime
global WindPAlt
global speedU
global speedV 
tic
initWind() 
inital_weather_data = toc;

control_points_longlat(:,1) = control_points_latlong(:,2);
control_points_longlat(:,2) = control_points_latlong(:,1);
% Define the number of days of data you want to store
numArrays = length(dates);
% Initialize a cell array to store all the tail wing data arrays
all_tailwind = cell(1, numArrays);
all_crosswind= cell(1, numArrays);  

tic
% for i = 1:length(dates)
%     [all_tailwind{i},all_crosswind{i},u,v,distance,point_distance,latitudes,longitudes,unitx,unity] = profileTeamFNoPy(control_points_longlat, point_dist, dates(i));
%     disp("Weather Data for Day " + i + " Collected")
% end
% lat_long = [latitudes',longitudes'];

load("Dec1-Dec10_tailwind.mat")
load("Dec1-Dec10_crosswind.mat")
% load("Zero_Tailwind.mat")
% load("Zero_Crosswind.mat")

load("SouthHem_Team1_100NM_distance.mat")

weather_matrix_creation_time = toc;

%% Flight Profile
% Aircraft State Vector:
% AS = [time(s), distance(nmi), weight(lb), altitude(ft), TAS(knots), ground speed (knots), Power, SFC Cl, Cd, mode]
AS(1,:) = zeros(1,11);
AS(1,3) = Wto;
sizeSEC = size(sectors);

disp(" ")
tic
for i = 1:sizeSEC(1)
% Flight Sector Analysis
    % 1: Full Throttle Climb
    if sectors(i,1) == 1
        disp("Start of Full Throttle Climb:         " + size(AS,1) + " iteration")
        sizeAS = size(AS);
        j = sizeAS(1);
        [time,x,W,alt,P,v,x_dot,sfc,CL,CD] = best_climb_v2(AS(j,3),sectors(i,2),sectors(i,3),AP(3),0,sectors(i,7),EngineType,SeaLevelEngine,MinSFC,service_ceiling,n,AP(1),k,CD0);
        newAS = [max(AS(:,1))+time',max(AS(:,2))+x',W',alt',v',x_dot',P',sfc',CL',CD',sectors(i)*ones(length(time),1)];
        AS = [AS;newAS];
    % 2: Level Change Climb/Descent
    elseif sectors(i,1) == 2
        disp("Start of Constant Rate Climb:         " + size(AS,1) + " iteration")
        sizeAS = size(AS);
        j = sizeAS(1);
        [time,x,W,P,alt,v,x_dot,sfc,CL,CD] = NavLvlChange(AS(j,3),sectors(i,4),sectors(i,2),sectors(i,3),AP(3),0,sectors(i,7),sectors(i,5),EngineType,SeaLevelEngine,MinSFC,service_ceiling,n,AP(1),k,CD0);
        newAS = [max(AS(:,1))+time',max(AS(:,2))+x',W',alt',v',x_dot',P',sfc',CL',CD',sectors(i)*ones(length(time),1)];
        AS = [AS;newAS];
    % 3: Cruise, constant alt, constant TAS
    elseif sectors(i,1) == 3
        disp("Start of Const Alt. & Vel Cruise:     " + size(AS,1) + " iteration")
        disp("      Cruise Altitude: " + AS(end,4) + " ft")
        [AS] = cruise_cnst_v_h_final(AS,AP,sectors(i,6),sectors(i,4),sectors(i,7),all_tailwind,distance,EngineType,SeaLevelEngine,MinSFC,service_ceiling,n,k,CD0);
        
    % 4: Cruise, constant Cl, constant TAS
    elseif sectors(i,1) == 4
        disp("Start of Cruise Climb:                " + size(AS,1) + " iteration")
        CL = sectors(i,8);
        if CL == 0
% AS [ time(sec), distance(nm), weight(lbf), altitude(ft), airspeed(knots), ground speed(knots), power(hp), sfc, CL, CD, mode_#]
            altitude = AS(end,4);   % [ft]
            weight = AS(end,3);     % [lbf]
            S = AP(1);              % [ft^2]
            velocity = sectors(i,4) * 1.6878098571;   % [ft/s]
            density = stdAtmosphere_imperial(altitude,0);   % [slugs/ft^3]
            CL = 2 * weight / (density * velocity^2 * S);
        elseif CL == 1
            CL = sqrt(CD0/k);
            disp("      Max L/D CL calculated to be: " + CL)
        else
            disp("Input 0 CL for automatic CL determination or 1 for max L/D CL")
        end
        CD = CD0 + k*(CL^2);
        [AS] = cruise_cnst_CL_v2(sectors(i,7), AP, AS,EngineType,SeaLevelEngine,MinSFC,service_ceiling,n,all_tailwind,distance,sectors(i,4),sectors(i,6),CL,CD);

    else
        error('Input Valid Sector Type (1-4)')
    end
end
flight_mode_runtime = toc;

% Create a readable table for the output matrix AS
column_labels = {'Time [sec]','Distance [NM]', 'Weight [lbf]', 'Altitude [ft]', 'Airspeed [knots]', 'Ground Speed [knots]', 'Power [hp]', 'SFC', 'CL', 'CD', 'Mode #'};
AS_table = array2table(AS, 'VariableNames', column_labels);

%% plotting

figure
plot(AS(:,2),AS(:,4))
title('Altitude')
xlabel('dist (nmi)')
ylabel('alt (ft)')

% figure
% plot(AS(:,2),AS(:,3))
% title('weight')
% xlabel('dist (nmi)')
% ylabel('total weight (lbs)')
% 
figure
plot(AS(:,2),AS(:,7))
title('Power')
xlabel('dist (nmi)')
ylabel('power (hp)')
% 
% figure
% hold on

% plot(AS(2782:end,2),AS(2782:end,5),LineWidth=1.5)
% plot(AS(2782:end,2),AS(2782:end,6),LineWidth=1.1, Color=[0.722 0.027 0.027])
% yl1 = yline(groundspeedAVG,"--",LineWidth=1.2);
% yl1.Color = [0.722 0.027 0.027];
% xlabel('Distance (nautical miles)')
% ylabel('Speed (knots)')
% xlim([0,AS(end,2)])

%% Times
% disp("----------Times----------")
% disp("Loading Weather Data Files Took:  " + inital_weather_data + " seconds")
% disp("Creating the Weather Matrix Took: " + weather_matrix_creation_time + " seconds")
% disp("Simulation of All Flight Modes Took: " + flight_mode_runtime + ' seconds')

%% Quick Maths
day4 = all_tailwind{4};
day4_cross = all_crosswind{4};
for i = 1:4
%     average_tailwind_start(i,1) = mean(day6(i,1:145));
%     average_tailwind_end(i,1) = mean(day6(i,145:end));
    average_tailwind_day4(i,1) = mean(day4(i,:));
    average_crosswind_day4(i,1) = mean(day4_cross(i,:));
end

disp(" ")
disp("-----------Results------------")
disp("Flew " + AS(end,2) + " NM")
%
% disp("Average Cruise CL: " + mean(AS(###:end,9)))
% disp("Average Cruise Power: " + mean(AS(###:end,7)))
groundspeedAVG = mean(AS(2782:end,6));
disp("Average Groundspeed: " + groundspeedAVG + " knots")
fuel_consumed = (AS(1,3)-AS(end,3));
disp("Fuel Consumed: " + fuel_consumed + " lbf | Fuel Left: " + (Wf - fuel_consumed) + "lbf")
disp("Mission Duration: " + AS(end,1)/60 + " minutes or " + AS(end,1)/3600 + " hours or " + AS(end,1)/3600/24 + ' days')

all_results{aircraft_case, mission_case} = AS;
all_results_table{aircraft_case, mission_case} = AS_table;
clear AS;
clear AP;

end
end
%% Tom Foolery
% Make a Zero Wind Matrix

% Iterate through each cell element in the copied cell array
% for i = 1:numel(all_tailwind)
%     % Check if the element is a numeric array
%     if isnumeric(all_tailwind{i})
%         % Replace all the values with zeros
%         all_tailwind{i}(:) = 0;
%         all_crosswind{i}(:) = 0;
%     end
% end

