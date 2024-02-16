function [Cl,Cd,x,W,v,P,time,SR] = cruise_cnst_v_h(Wi,altitude,cruise_distance,speed,delta_T,eta,delta_time)

% function for a constant altitude, constant velocity cruise
% takes in sfc matrix data from RV7

% INPUTS:
% Wi - initial weight in lbf or lbm*(ft/s2)
% altitude - cruise altitude in feet
% cruise_distance - total cruise distance in nautical miles
% speed - cruise speed in knots
% eta - propeller efficiency
% delta_T - off standard temperature difference in Fahrenheit
% delta_time - time step in seconds

% OUTPUTS
% Cl - lift coefficient
% Cd - drag coefficient
% x - distance in nautical miles
% W - weight in lbf
% v - velocity in knots
% P - power in hp
% time - seconds
% SR - specific range in nautical mile/lbs (positive)

% load data
load("O360_SFC.mat")
load("O360MAXhp.mat")

% conversions
ft2meter = 0.3048; % feet to meters
Pa2inHg = 0.0002953; % pascal to inches mercury
mile2ft = 6076.12; % nautical mile to feet
kgm3_2_slugft3 = 0.00194032; % kg per meter cubed to slug per foot cubed
knots2ftps = 1.68781; % knots to feet per second

% constants
[T_isa_SI,~,~,rho_SI] = atmosisa(altitude*ft2meter); % matlab isa
T_isa = (T_isa_SI - 273.15)*(9/5)+32; % Kelvin to Fahrenheit
Temp = T_isa + delta_T; % Fahrenheit
rho = rho_SI*kgm3_2_slugft3 ; % slug/ft3
S = 121; % wing area - square feet
g0 = 32.174; % ft per second squared (assuming gravity is constant with altitude)

% initialize state vector
x(1) = 0;
W(1) = Wi;
v(1) = speed*knots2ftps; % velocity in feet per second
time(1) = 0;

% Euler
i = 1;
while x < cruise_distance*mile2ft
    Cl(i) = (2*W(i))/(rho*S*(v(i))^2);
    Cd(i) = 0.024292 + (1.6647e-9)*Cl(i) + 0.071696*(Cl(i)^2); %from drag polar given
    D(i) = 0.5*rho*Cd(i)*S*(v(i))^2; % lbf
    P_shaft = ((D(i)*v(i))/eta)/550; % divide by 550 to put into hp
    P(i) = P_shaft*eta; % in hp
    percent_power(i) = (P_shaft/MAXhp(round(altitude/100)))*100;
    sfc = SFC(round(altitude/100),round(percent_power(i)));
    T = D(i);
    x_dot = v(i); % ft/s
    W_dot = (-sfc*P(i))/3600; % divide by 3600 to get in lbf/s
    v_dot = (T-D(i))/(W(i)/g0); % ft/s2
    x(i+1) = x_dot*delta_time + x(i);
    W(i+1) = W_dot*delta_time + W(i);
    v(i+1) = v_dot*delta_time + v(i);
    time(i+1) = time(i) + delta_time;
    SR(i) = -(x_dot/mile2ft)/W_dot;
    i = i + 1;
end

v = v/knots2ftps; % convert velocity vector back to knots
x = x/mile2ft; % convert feet to nautical miles
SR(i) = SR(i-1); % get an extra SR so every output vector is the same size

end