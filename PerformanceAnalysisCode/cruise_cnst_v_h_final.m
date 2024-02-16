function [AS] = cruise_cnst_v_h_final(AS,AP,cruise_distance,speed,delta_time,all_tailwind,distance,EngineType,SeaLevelMatrix,MinSFC,n,k,Cd0)

% function for a constant altitude, constant true airspeed cruise
% takes in sfc matrix data from RV7

% INPUTS:
% AS - [time, distance, weight, altitude, airspeed, ground speed, CL, CD, mode]
% AP = [wing_area (ft^2), aspect_ratio, propeller_efficiency]
% cruise_distance - total cruise distance in nautical miles
% speed - cruise speed in knots
% delta_time - time step in seconds
% all_tailwind - weather team matrix
% distance - weather team matrix
% EngineType - engine function input
% SeaLevelMatrix - engine matrix from main script
% MinSFC - engine function input
% n - engine function input

% OUTPUTS
% AS - [time, distance, weight, altitude, airspeed, ground speed, power, sfc, CL, CD, mode]
% time - seconds
% distance - distance in nautical miles
% weight - weight in lbf
% altitude - altitude in feet
% airspeed - TAS in knots
% groundspeed - ground speed in knots
% power - in hp
% sfc - in lb/hr/hp
% Cl - lift coefficient
% Cd - drag coefficient
% mode - flight mode

%Optional Allocation
guessLength = 5000;
x = nan(guessLength,1); 
W = nan(guessLength,1);
v = nan(guessLength,1);
time = nan(guessLength,1);
Cl = nan(guessLength,1);
Cd = nan(guessLength,1);
D = nan(guessLength,1);
P = nan(guessLength,1);

% conversions
ft2meter = 0.3048; % feet to meters
mile2ft = 6076.12; % nautical mile to feet
kgm3_2_slugft3 = 0.00194032; % kg per meter cubed to slug per foot cubed
knots2ftps = 1.68781; % knots to feet per second
knots2fts = @(x) x*1.68780986;

% constants
altitude = AS(end,4);
initial_dist = AS(end,2); % distance in nautical miles
mode_number = 3;
[~,~,~,rho_SI] = atmosisa(altitude*ft2meter); % matlab isa
rho = rho_SI*kgm3_2_slugft3 ; % slug/ft3
S = AP(1); % wing area - square feet
g0 = 32.174; % ft per second squared (assuming gravity is constant with altitude)
[AdjEngineDeck] = ChangeEngineAlt(EngineType, SeaLevelMatrix, MinSFC, altitude, n);

% Euler
i = size(AS,1);    % Sets the starting point of the function at the end of the Airplane State (AS)
% airplane state
x(i) = AS(end,2)*mile2ft; % x in feet
W(i) = AS(end,3);
v(i) = speed*knots2ftps; % velocity in feet per second
time(i) = AS(end,1);
while AS(i,2) < cruise_distance + initial_dist
%     tic
    % wind
    tailwind_fts = knots2fts(windFinder(AS(i,:),all_tailwind,distance)); % [ft/s]

    Cl(i) = (2*W(i))/(rho*S*(v(i))^2);
    Cd(i) = Cd0 + k*(Cl(i)^2); %from drag polar given
    D(i) = 0.5*rho*Cd(i)*S*(v(i))^2; % lbf
    P_shaft = ((D(i)*v(i))/AP(3))/550; % divide by 550 to put into hp
    P(i) = P_shaft*AP(3); % in hp
    [sfc] = EngineSFC(P(i),AdjEngineDeck); % find engine sfc function
    T = D(i); % lbf
    x_dot = v(i) + tailwind_fts; % ft/s
    W_dot = (-sfc*P(i))/3600; % divide by 3600 to get in lbf/s
    v_dot = (T-D(i))/(W(i)/g0); % ft/s2
    x(i+1) = x_dot*delta_time + x(i);
    W(i+1) = W_dot*delta_time + W(i);
    v(i+1) = v_dot*delta_time + v(i);
    time(i+1) = time(i) + delta_time;


    % Update Airplane State
    AS(i+1, 1) = time(i+1);
    AS(i+1, 2) = x(i+1)/mile2ft; % convert feet to nautical miles
    AS(i+1, 3) = W(i+1);
    AS(i+1, 4) = altitude;
    AS(i+1, 5) = v(i+1)/knots2ftps; % converting to knots
    AS(i+1, 6) = x_dot/knots2ftps; % converting to knots
    AS(i+1, 7) = P(i);
    AS(i+1, 8) = sfc;
    AS(i+1, 9) = Cl(i);
    AS(i+1, 10) = Cd(i);
    AS(i+1, 11) = mode_number;

    i = i + 1;

%     toc

end

% Cut off unused allocation
if i < guessLength
    for bruh = i:guessLength
        x(i) = [];   
        W(i) = [];
        v(i) = [];
        time(i) = [];
        Cl(i) = [];
        Cd(i) = [];
        D(i) = [];
        P(i) = [];
    end
end

end