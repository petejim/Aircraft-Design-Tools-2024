% Justin Bradford
% AERO 444 - Performance Assignment

clc
close all
clear

%% Constant velocity constant altitude cruise


Wi = 1800; % initial weight in lbf or lbm*(ft/s2)
altitude = 5000; % cruise altitude in feet
cruise_distance = 800; % total cruise distance in nautical miles
speed = 125; % cruise speed in knots
delta_T = 0; % off standard temperature difference in Fahrenheit
delta_time = 5; % time step in seconds
eta = 0.8; % propeller efficiency
[Cl1,Cd1,x1,W1,v1,P1,time1,SR1] = cruise_cnst_v_h(Wi,altitude,cruise_distance,speed,delta_T,eta,delta_time);


figure
plot(time1/60,v1,LineWidth=1.5)
xlabel('Time [min]')
ylabel('Velocity [knots]')

figure
plot(time1(1:length(P1))/60,P1,LineWidth=1.5)
xlabel('Time [min]')
ylabel('Power [hp]')


%% Constant power constant altitude cruise


Wi = 1800; % initial weight in lbf or lbm*(ft/s2)
altitude = 5000; % cruise altitude in feet
cruise_distance = 300; % total cruise distance in nautical miles
initial_speed = 125; % cruise speed in knots
delta_T = 0; % off standard temperature difference in Fahrenheit
delta_time = 5; % time step in seconds
eta = 0.8; % propeller efficiency
percent_P = 70; % horsepower
[Cl2,Cd2,x2,W2,v2,time2,SR2] = cruise_cnst_P_h(Wi,altitude,cruise_distance,initial_speed,percent_P,delta_T,eta,delta_time);


figure
plot(time2/60,v2,LineWidth=1.5)
xlabel('Time [min]')
ylabel('Velocity [knots]')



