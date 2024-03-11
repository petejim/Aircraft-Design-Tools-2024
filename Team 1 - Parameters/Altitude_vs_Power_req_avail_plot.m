close all; clear; clc;

% Aircrafts =[    
% %     "T1_Baseline_Aircraft.txt";
% %         "T1_3Fuse_Simple.txt";
% %     "T1_TwinFuse_Aircraft.txt";
% %     "T1_3Fuse_Pressure.txt";
%     "T1_3Fuse_Pressure_3view.txt";
% %     "T1_New_Baseline_Aircraft.txt"
%     "T1_3Fuse_Pressure_Current_Climb.txt"
%     ];
% 
% Missions = [    
% %                 "T1_CC-C.txt";
% %                 "T1_Climb-C.txt";
% %                 "T1_Climb-CC-C.txt";
% %                 "T1_C8000.txt";
% %                 "T1_CC-C25000.txt";
%                 "T1_CC-C27000.txt"
% %                 "T1_CC-C27000_Amazon.txt"
%                 "T1_Climb-10000.txt";
%                 ];

% with weather

load("climb_cruise_AS.mat")
climb_AS = all_results{2,2};
climb_AS(1,:) = [];
cruise_AS = all_results{1,1};
cruise_AS(1:3,:) = [];

load("max_powers.mat")

max_power_climb = all_max_powers{2,2};
max_power_climb(1,:) = [];
max_power_cruise = all_max_powers{1,1};
max_power_cruise(1,:) = [];
max_power = [max_power_climb;max_power_cruise];

AS = [climb_AS; cruise_AS];

load("cruise_AS_146KTAS.mat")
cruise_AS_146KTAS = all_results{1,1};
cruise_AS_146KTAS(1:3,:) = [];
shaft_power_146KTAS = cruise_AS_146KTAS(:,7);
altitude_146KTAS = cruise_AS_146KTAS(:,4);

MATLAB_blue = [ 0    0.4470    0.7410];
MATLAB_orange = [0.8500    0.3250    0.0980];
MATLAB_yellow = [ 0.9290    0.6940    0.1250];
MATLAB_red = [ 0.6350    0.0780    0.1840];

shaft_power = AS(:,7);
altitude = AS(:,4);

figure_height = 700;
figure_ratio = 3/5;
figure_width = figure_height*figure_ratio;
Graphic_Resolution = 300;

f = figure("Name","Altitude vs. Power Required & Available");
f.Position = [100 100 figure_height figure_width];
plot(shaft_power, altitude,".")
hold on
plot(shaft_power_146KTAS, altitude_146KTAS, ".",'Color', MATLAB_orange)
plot(max_power(:,2), max_power(:,1),"--", 'Color', MATLAB_red, LineWidth=1.25)
plot(shaft_power, altitude, ":", 'Color', MATLAB_blue)
ylabel("Altitudes [ft]")
xlabel("Shaft Power [hp]")
legend("Power Required @120KTAS", "Power Required @146KTAS", "Power Available")
ylim([2000,27500])
yticks(0:5000:27500);
ax = gca;
ax.YAxis.Exponent = 0;
set(gca,'FontSize', 12, 'FontName', "Calibri")
exportgraphics(f,'altitude vs power.png','Resolution', Graphic_Resolution)


