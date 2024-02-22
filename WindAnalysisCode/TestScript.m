%% Test Script

clc;
clear all
close all

%README:---------------------------------------------------------------
%The following is a test script to help you understand how the two main
%functions are called

%create global variables to span workspaces across initialization and
%get functions (NECESSARY IN MAIN SCRIPT)
global WindX
global WindY
global WindTime
global WindPAlt

global speedU
global speedV

%initialize data, Step 1
initWind()

%get wind components at location and date, Step 2

%   CONVENTION OF INPUTS:
%   -Degrees Long (0-180 deg is eastern hemi, while 0 to -180 is western
%   hemisphere
%   -Degrees Lat (90 to -90 for North to South Poles)
%   -Altitude in feet
%   -Date as string in format "DD-Month Acronym-YYYY"

waypoints = [0, 50;
             60, -50;
             -60,-50;
             -60, 0;];

point_dist = 400;

%C:\Users\antho\AppData\Local\Microsoft\WindowsApps\PythonSoftwareFoundation.Python.3.11_qbz5n2kfra8p0\python.exe

[tail,cross,u,v,distance,point_distance,latitudes,longitudes,unitx,unity] = profileTeamF(waypoints, point_dist, "01-Sep-2023");

%%

longitudes(longitudes > 180) = longitudes(longitudes > 180) -360;
lat_long = [latitudes;longitudes];
figure
geoplot(latitudes, longitudes, ".-")

%% 
figure
plot(unitx)
hold on
plot(unity)












