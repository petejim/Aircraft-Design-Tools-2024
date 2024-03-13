clc; close all; clear;

% Aircraft Performance MAIN 

% Perfromance script to integrate:
% > Aircraft Configuration/Engine Selection 
% > Route
% > Weather: Wing vectors along route
% > Flight profile

addpath(genpath("../"))

Aircrafts =[    
%     "T1_Baseline_Aircraft.txt";
%         "T1_3Fuse_Simple.txt";
%     "T1_TwinFuse_Aircraft.txt";
%     "T1_3Fuse_Pressure.txt";
%     "T1_3Fuse_Pressure_3view.txt";
%     "T1_New_Baseline_Aircraft.txt"
%     "T1_3Fuse_Pressure_Current_Climb.txt"
    "T2_DR4_Configuration.txt";
    ];

Missions = [    
%                 "T1_CC-C.txt";
%                 "T1_Climb-C.txt";
%                 "T1_Climb-CC-C.txt";
%                 "T1_C8000.txt";
%                 "T1_CC-C25000.txt";
%                 "T1_CC-C27500_120KTAS.txt";
%                 "T1_CC-C27000_Amazon.txt"
%                 "T1_Climb-10000.txt";
%                 "T1_CC-C27500_146KTAS.txt";
%                 "T2_CC-C11000_120KTAS.txt";
                "T2_CC-C25000_120KTAS.txt"
                ];

all_results = cell(length(Aircrafts),length(Missions));
all_results_table = cell(length(Aircrafts),length(Missions));
all_max_powers = cell(length(Aircrafts),length(Missions));
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

k = str2double(aircraft_info(5)); % Induced Drag Constant
CD0 = str2double(aircraft_info(7)); % Parasitic Drag
Wf = str2double(aircraft_info(31)); % Fuel Weight [lbf]
AP = [str2double(aircraft_info(9)),str2double(aircraft_info(11)),str2double(aircraft_info(13)), k, CD0]; % AP = [wing area (ft^2),AR, Eta, k, CD0]
%% Engine Selection
MinSFC = str2double(aircraft_info(17)); 
MaxBHP = str2double(aircraft_info(19));
EngineType = aircraft_info(23);
n = str2double(aircraft_info(21));
service_ceiling = str2double(aircraft_info(25));
n_engine = str2double(aircraft_info(27));
[SeaLevelEngine] = BuildEngineDeck(EngineType, MinSFC, MaxBHP, n);
SeaLevelEngine(:,1) = SeaLevelEngine(:,1)*n_engine;
SeaLevelEngine(:,1) = SeaLevelEngine(:,1)-2;        % Power Loss to Compressor

engine_info = struct;
engine_info.min_SFC = MinSFC;
engine_info.max_BHP = MaxBHP;
engine_info.engine_type = EngineType;
engine_info.resolution = n;
engine_info.service_ceiling = service_ceiling;
engine_info.num_engines = n_engine;
engine_info.sea_level_engine = SeaLevelEngine;

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
for sector_num = 1:length(control_point_cells)
    for j = 1:2
        control_points_latlong(sector_num,j) = str2double(control_point_cells{sector_num}{j});
    end
end
sectors_cells = cellfun(@(x) split(x, ','), route(19+n_control+1:end,1), 'UniformOutput', false);
sectors = nan(length(sectors_cells));
for sector_num = 1:length(sectors_cells)
    for j = 1:8
        sectors(sector_num,j) = str2double(sectors_cells{sector_num}{j});
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
%     disp("Weather Data for " + dates(i) + " Collected")
% end
% lat_long = [latitudes',longitudes'];

load("T2_Dec1-Dec10_all_tailwind.mat")
load("T2_Dec1-Dec10_all_crosswind.mat")
disp("Weather from Dec 1 - Dec 10 on T2 Southern Westerlies Route")
load("T2_Southern_Westerlies_Distances_100NM.mat")

% 
% load("Dec1-Dec10_tailwind.mat")
% load("Dec1-Dec10_crosswind.mat")
% disp("Weather from Dec 1 - Dec 10 on T1 Southern Westerlies Route")
% load("SouthHem_Team1_100NM_distance.mat")

% load("Zero_Tailwind.mat")
% load("Zero_Crosswind.mat")
% disp("No Wind Assumed")
% load("SouthHem_Team1_100NM_distance.mat")

weather_matrix_creation_time = toc;

%% Flight Profile
% Aircraft State Vector:
% AS = [time(s), distance(nmi), weight(lb), altitude(ft), TAS(knots), ground speed (knots), Power, SFC Cl, Cd, mode]
AS(1,:) = zeros(1,11);
AS(1,3) = Wto;
sizeSEC = size(sectors);

disp(" ")
tic
for sector_num = 1:sizeSEC(1)
% Flight Sector Analysis
    % 1: Full Throttle Climb
    if sectors(sector_num,1) == 1
        disp("Start of Full Throttle Climb:         " + size(AS,1) + " iteration")
        sizeAS = size(AS);
        j = sizeAS(1);
        [time,x,W,alt,P,v,x_dot,sfc,CL,CD] = best_climb_v2(AS(j,3),sectors(sector_num,2),sectors(sector_num,3),AP(3),0,sectors(sector_num,7),EngineType,SeaLevelEngine,MinSFC,service_ceiling,n,AP(1),k,CD0);
        newAS = [max(AS(:,1))+time',max(AS(:,2))+x',W',alt',v',x_dot',P',sfc',CL',CD',sectors(sector_num)*ones(length(time),1)];
        AS = [AS;newAS];
    % 2: Level Change Climb/Descent
    elseif sectors(sector_num,1) == 2
        disp("Start of Constant Rate Climb:         " + size(AS,1) + " iteration")
        sizeAS = size(AS);
        j = sizeAS(1);
        [time,x,W,P,alt,v,x_dot,sfc,CL,CD] = NavLvlChange(AS(j,3),sectors(sector_num,4),sectors(sector_num,2),sectors(sector_num,3),AP(3),0,sectors(sector_num,7),sectors(sector_num,5),EngineType,SeaLevelEngine,MinSFC,service_ceiling,n,AP(1),k,CD0);
        newAS = [max(AS(:,1))+time',max(AS(:,2))+x',W',alt',v',x_dot',P',sfc',CL',CD',sectors(sector_num)*ones(length(time),1)];
        AS = [AS;newAS];
    % 3: Cruise, constant alt, constant TAS
    elseif sectors(sector_num,1) == 3
        cruise_start = size(AS,1);
        disp("Start of Const Alt. & Vel Cruise:     " + size(AS,1) + " iteration")
        disp("      Cruise Altitude: " + AS(end,4) + " ft")
        [AS] = cruise_cnst_v_h_final(AS,AP,sectors(sector_num,6),sectors(sector_num,4),sectors(sector_num,7),all_tailwind,distance,EngineType,SeaLevelEngine,MinSFC,service_ceiling,n,k,CD0);
        cruise_end = size(AS,1);
    % 4: Cruise, constant Cl, constant TAS
    elseif sectors(sector_num,1) == 4
        cruiseClimb_start = size(AS,1);
        disp("Start of Cruise Climb:                " + size(AS,1) + " iteration")
        [AS] = cruise_climb(sectors, sector_num, AP, AS, engine_info, all_tailwind, distance);
        cruiseClimb_end = size(AS,1);
    else
        error('Input Valid Sector Type (1-4)')
    end
end
flight_mode_runtime = toc;

% Create a readable table for the output matrix AS
column_labels = {'Time [sec]','Distance [NM]', 'Weight [lbf]', 'Altitude [ft]', 'Airspeed [knots]', 'Ground Speed [knots]', 'Power [hp]', 'SFC', 'CL', 'CD', 'Mode #'};
AS_table = array2table(AS, 'VariableNames', column_labels);
groundspeedAVG = mean(AS(2782:end,6));
LD = AS(:,9)./AS(:,10);


max_shaft_power_available = nan(length(AS),2);      %   [altitude (ft), max_shaft_power (hp)] shaft_power is before propeller efficiency
altitudes = AS(:,4);
for sector_num = 1:length(AS)
    altitude_max = max(ChangeEngineAlt(EngineType, SeaLevelEngine, MinSFC, AS(sector_num,4), service_ceiling, n));
    max_shaft_power_available(sector_num,1) = altitude_max(1,1);
end
all_max_powers{aircraft_case, mission_case} = max_shaft_power_available;

power_output = AS(:,7);
percent_power = power_output./max_shaft_power_available;

distance_traveled_nm = AS(:,2);


%% plotting

figure
plot(AS(:,2),AS(:,4))
title({"Aircraft Case:" + aircraft_case + " Mission Case:" + mission_case;'Altitude'})
xlabel('dist (nmi)')
ylabel('alt (ft)')

% figure
% plot(AS(:,2),AS(:,3))
% title('weight')
% xlabel('dist (nmi)')
% ylabel('total weight (lbs)')
% 
% figure
% plot(AS(:,2),AS(:,7),"r")
% title({"Aircraft Case:" + aircraft_case + " Mission Case:" + mission_case;'Power'})
% xlabel('dist (nmi)')
% ylabel('power (hp)')
% ylim([0,250])

% figure
% plot(AS(:,7), altitudes,"r")
% hold on
% plot(max_shaft_power_available(:,2),max_shaft_power_available(:,1),"b--", LineWidth=1.25)
% title({"Aircraft Case:" + aircraft_case + " Mission Case:" + mission_case;'Power Required & Available'})
% xlabel('Shaft Power, [HP]')
% ylabel('Altitude, [ft]')
% xlim([0,350])   
% ylim([8000, max(altitudes)])

figure("Name","Percent Power")
hold on
title({"Aircraft Case:" + aircraft_case + " Mission Case:" + mission_case;'Percent Power during Flight'})
plot(distance_traveled_nm, percent_power, "r")
ylim([0.5 1.1])
grid on

% % 
% figure
% hold on
% title({"Aircraft Case:" + aircraft_case + " Mission Case:" + mission_case; "Constant Altitude & Airspeed Cruise"})
% plot(AS(cruise_start:cruise_end,2), AS(cruise_start:cruise_end,5),LineWidth=1.5)
% plot(AS(cruise_start:cruise_end,2), AS(cruise_start:cruise_end,6),LineWidth=1.1, Color=[0.722 0.027 0.027])
% yl1 = yline(groundspeedAVG,"--",LineWidth=1.2);
% yl1.Color = [0.722 0.027 0.027];
% xlabel('Distance (nautical miles)')
% ylabel('Speed (knots)')
% xlim([0,AS(end,2)])

figure
plot(AS(:,2),LD)
title({"Aircraft Case:" + aircraft_case + " Mission Case:" + mission_case;'L/D'})
xlabel("Distance [NM]")
ylabel("L/D")
ylim([17.5 35])

% figure
% plot(AS(:,2),AS(:,3))
% title({"Aircraft Case:" + aircraft_case + " Mission Case:" + mission_case;'Weight'})
% xlabel("Distance [NM]")
% ylabel("Weight [lbf]")

% figure
% plot(AS(:,2),AS(:,8))
% title({"Aircraft Case:" + aircraft_case + " Mission Case:" + mission_case;'SFC'})
% xlabel("Distance [NM]")
% ylabel("SFC")
% ylim([.34, .41])

%% Times
% disp("----------Times----------")
% disp("Loading Weather Data Files Took:  " + inital_weather_data + " seconds")
% disp("Creating the Weather Matrix Took: " + weather_matrix_creation_time + " seconds")
% disp("Simulation of All Flight Modes Took: " + flight_mode_runtime + ' seconds')

%% Quick Maths
% day4 = all_tailwind{4};
% day4_cross = all_crosswind{4};
% for i = 1:4
% %     average_tailwind_start(i,1) = mean(day6(i,1:145));
% %     average_tailwind_end(i,1) = mean(day6(i,145:end));
%     average_tailwind_day4(i,1) = mean(day4(i,:));
%     average_crosswind_day4(i,1) = mean(day4_cross(i,:));
% end

disp(" ")
disp("-----------Results------------")
disp("Flew " + AS(end,2) + " NM")
%
% disp("Average Cruise CL: " + mean(AS(###:end,9)))
% disp("Average Cruise Power: " + mean(AS(###:end,7)))
disp("Average Groundspeed: " + groundspeedAVG + " knots")
fuel_consumed = (AS(1,3)-AS(end,3));
disp("Fuel Consumed: " + fuel_consumed + " lbf | Fuel Left: " + (Wf - fuel_consumed) + "lbf")
disp("Mission Duration: " + AS(end,1)/60 + " minutes or " + AS(end,1)/3600 + " hours or " + AS(end,1)/3600/24 + ' days')

try
    disp("SFC")
    cruise_sfc = mean(AS(cruise_start:cruise_end,8));
    disp("Average SFC During Cruise: " + cruise_sfc)
%     cruise_power = mean(AS(cruise_start:cruise_end,7));
%     bruh = cruise_sfc * cruise_power* AS(end,1)/3600;
%     disp(bruh)
    cruiseClimb_sfc = mean(AS(cruiseClimb_start:cruiseClimb_end,8));
    disp("Average SFC During Cruise Climb: " + cruiseClimb_sfc)
%     average_sfc = mean(AS(:,8));
%     average_power = mean(AS(:,7));
%     disp(AS(end,1)/3600 * average_power * average_sfc)
catch
end
try
    disp("L/D")
    cruise_LD = mean(AS(cruise_start:cruise_end,9))/mean(AS(cruise_start:cruise_end,10));
    disp("Average L/D During Cruise: " + cruise_LD)
    cruiseClimb_LD = mean(AS(cruiseClimb_start:cruiseClimb_end,9))/mean(AS(cruiseClimb_start:cruiseClimb_end,10));
    disp("Average L/D During Cruise Climb: " + cruiseClimb_LD)
catch
end

all_results{aircraft_case, mission_case} = AS;
all_results_table{aircraft_case, mission_case} = AS_table;
clear AS;
clear AP;
clear cruiseClimb_end cruiseClimb_start;
clear cruise_end cruise_start;
end
end
%% Tom Foolery
% Make a Zero Wind Matrix

% Iterate through each cell element in the copied cell array
% for sector_num = 1:numel(all_tailwind)
%     % Check if the element is a numeric array
%     if isnumeric(all_tailwind{sector_num})
%         % Replace all the values with zeros
%         all_tailwind{sector_num}(:) = 0;
%         all_crosswind{sector_num}(:) = 0;
%     end
% end