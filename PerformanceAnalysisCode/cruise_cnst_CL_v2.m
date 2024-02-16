% Cruise Climb Simulation
% By. Peter Kim

% Function for a constant CL, constant airspeed cruise (aka cruise climb) simulation
% Requires the drag polar or the value of CL

function [AS] = cruise_cnst_CL_v2(dt_sec, AP, AS, EngineType, SeaLevelEngine, MinSFC, n, all_tailwind, distance, v_cruise_knots, distance_target_nm, CL_cruise, CD_cruise)
% AS [ time(sec), distance(nm), weight(lbf), altitude(ft), airspeed(knots), ground speed(knots), power(hp), sfc, CL, CD, mode]
% AP [ ]
% SeaLevelMatrix - baseline engine performance produced by engine model
% all_tailwind - cell containing all tailwind data
% distance - matrix produced by the weather function that has the cumulative distnace traveled per path point
% v_cruise_knots
% distance_target_nm
% CL_cruise
% CD_cruise

mode_number = 4;

% Make sure that the plane "catches up" and TODO

%Optional Allocation
guessLength = 10000;
mass = nan(guessLength,1); 
density = nan(guessLength,1);           % density
D = nan(guessLength,1);
thrust_required = nan(guessLength,1);
power_required = nan(guessLength,1);
power_required_hp = nan(guessLength,1);
path_angle = nan(guessLength,1);
tailwind_fts = nan(guessLength,1);
power_shaft = nan(guessLength,1);
power_output = nan(guessLength,1);
dv = nan(guessLength,1);
dx = nan(guessLength,1);
dy = nan(guessLength,1);
dW = nan(guessLength,1);
t = nan(guessLength,1);
airspeed_fts = nan(guessLength,1);
groundspeed_fts = nan(guessLength,1);
x = nan(guessLength,1);
y = nan(guessLength,1);
W = nan(guessLength,1);
sfc = nan(guessLength,1);
fuel_consumption = nan(guessLength,1);

% Conversions
nm2ft = @(x) x*6076.11549;
ft2nm = @(x) x/6076.11549;
knots2fts = @(x) x*1.68780986;
fts2knots = @(x) x/1.68780986;

% Time Step
dt = dt_sec;

% Take in Airplane State
    % AS [ 1 time, 2 distance, 3 weight, 4 altitude, 5 airspeed, 6 ground speed, 7 power(hp), 8 sfc, 9 CL, 10 CD, 11 mode]
t(1) = AS(end,1);               % [sec]
x(1) = nm2ft(AS(end,2));        % [ft]
W(1) = AS(end,3);               % Starting weight [lbf]
y(1) = AS(end, 4);              % Starting Altitude [ft]
    density(1) = stdAtmosphere_imperial(y(1),0);
airspeed_fts(1) = knots2fts(AS(end, 5));   % [ft/s]

% Aircraft Parameters
S = AP(1);      % Wing Area [ft^2]
eta = AP(3);    % Propeller Efficiency 


%% Mission Parameters
    % Target Cruise Velocity
v_cruise_fts = knots2fts(v_cruise_knots);      % [ft/s]
    % CL & CD
CL = CL_cruise;
CD = CD_cruise; 
    % Mission Distance
distance_target_ft = nm2ft(distance_target_nm);   % Distance to travel [ft]

i = 1;
i_AS = size(AS,1);                 % Sets the starting point of the function at the end of the Airplane State (AS)
while x(i) <= x(1)+distance_target_ft
    % House Keeping
    mass(i) = W(i)/32.2;            % [lbm]power 

    % Weather
    tailwind_fts(i) = knots2fts(windFinder(AS(i_AS,:),all_tailwind,distance));                % [ft/s]
    groundspeed_fts(i) = v_cruise_fts + tailwind_fts(i);                      % [ft/s]

    % Density Climb    
    density(i+1) = 2*W(i) / (S * CL * v_cruise_fts^2);                        % [slugs/ft^3]          
        % nextdensity [slug/ft^3] needed for the plane to be in cruise
    y(i+1) = equivalent_std_density_alt_finder(density(i+1));   % next altitude [ft], 
    

    % Solving for Power Required
    dy(i) = y(i+1) - y(i);              % if there is no density change (weight change), this should be zero
    airspeed_fts(i) = v_cruise_fts;                                   % [ft/s]
    path_angle(i) = atan2(dy(i),airspeed_fts(i));                     % [rad]
    D(i) = 0.5 * density(i) * v_cruise_fts^2 * S * CD;      % [lbf]
    thrust_required(i) = W(i)*sin(path_angle(i)) + D(i);    % [lbf]

    power_required(i) = thrust_required(i) * v_cruise_fts;      % [lbf * ft/s]
    power_required_hp(i) = power_required(i)/550;           % [hp]
    % find required shaft power
    power_shaft(i) = (power_required_hp(i)/eta);            % [hp]
    
    % Solving for Power Output and SFC
    [AdjEngineDeck] = ChangeEngineAlt(EngineType, SeaLevelEngine, MinSFC, y(i), n);   % y(i) because we are solving for power needed NOW to solve for power needed to get to next state
    solve = abs(AdjEngineDeck(:,1) - power_shaft(i));
    [~,I] = min(solve);
    power_output(i) = AdjEngineDeck(I,1);
    sfc(i) = AdjEngineDeck(I,2);
    
    % Fuel Consumption
    fuel_consumption(i) = sfc(i) * power_output(i)/3600;                % lbf/sec
    
    % Update Derivative
    dv(i) = (power_required_hp(i) - power_output(i))/mass(i)/airspeed_fts(i);  % [ft/s^2] should be zero most of the time as the power output is adjusted to be close to the power 
    dx(i) = groundspeed_fts(i);                                     % [ft/s]
    dW(i) = -fuel_consumption(i);                                   % [lbf]
    
    % Update State
    t(i+1) = dt+t(i);
    x(i+1) = dx(i)*dt + x(i);   %[ft]      
    W(i+1) = dW(i)*dt + W(i);
    
    % Update Airplane State
    % AS [ 1 time, 2 distance, 3 weight, 4 altitude, 5 airspeed, 6 ground speed, 7 power(hp), 8 sfc, 9 CL, 10 CD, 11 mode]
    AS(i_AS+1, 1) = t(i+1);
    AS(i_AS+1, 2) = ft2nm(x(i+1));     % [NM]
    AS(i_AS+1, 3) = W(i+1);
    AS(i_AS+1, 4) = y(i+1);
    AS(i_AS+1, 5) = fts2knots(v_cruise_fts);
    AS(i_AS+1, 6) = fts2knots(groundspeed_fts(i));    % [knots]
    AS(i_AS+1, 7) = power_output(i);  %[hp]
    AS(i_AS+1, 8) = sfc(i);
    AS(i_AS+1, 9) = CL;
    AS(i_AS+1,10) = CD;
    AS(i_AS+1,11) = mode_number;

%     if length(AS) > 4176
%         disp(length(AS))
%         disp(AS(i_AS+1))
%         disp("The drag calculated is: " + D(i))
%         disp("The climb component of thrust required is: " + W(i)*sin(path_angle(i)))
%     end

    % Checkpoints
    if sfc(i) < 0
        disp("Negative SFC")
    elseif dx(i) < 0
        disp("Plane is moving backwards")
    elseif abs(dW(i)) >= 2 
        disp("Plane is changing weight too fast")
%     elseif (v(i)-20) >= v_cruise_fts
%         disp("Plane is going too fast")
%     elseif y(i) >= maxCeiling
%         disp("Plane is too high")
    end
        %   Altitdue
    if dy(i) > 1000
        disp("A jump in altitude of " +  dy(i) + "ft was made")
    elseif dy(i) < -1000
        disp("A dive in altitude of " +  dy(i) + "ft was made")
    end
    %   Power 
%     disp("bruh")
    i = i + 1;
    i_AS = i_AS + 1;

end

% Cut off unused allocation
% if i < guessLength
%     for bruh = i:guessLength
%         density(i) = [];           % density
%         D(i) = [];
%         thrust_required(i) = [];
%         power_required(i) = [];
%         power_required_hp(i) = [];
%         path_angle(i) = [];
%         tailwind(i) = [];
%         max_power(i) = [];
%         power_shaft(i) = [];
%         percent_power(i) = [];
%         power_output(i) = [];
%         dv(i) = [];
%         dx(i) = [];
%         dy(i) = [];
%         dW(i) = [];
%         t(i) = [];
%         v(i) = [];
%         x(i) = [];
%         y(i) = [];
%         W(i) = [];
%         sfc(i) = [];
%         fuel_consumption(i) = [];
% 
%     end
% end

%% Results and Plots
% % Results
% times_run = i-1;
% disp("Done!")
% fuel_consumed = W(1)-W(times_run);
% t_hr = t/3600;
% distance_climbed = y(times_run) - y(1);
% avg_sfc = sum(sfc(1:times_run,1)/times_run);
% disp("Fuel Consumed: " + fuel_consumed + " lb")
% disp("Time Elasped: " + t_hr(end) + " hrs")
% disp("Average SFC: " + avg_sfc)
% disp("Climbed: " + distance_climbed + " ft")
% end

% figure("Name", "Altitude vs. Time")
% plot(t_hr,y,":","LineWidth",3)
% title("Altitude vs. Time")
% xlabel("Time [hr]")
% ylabel("Altitude [ft]")
% ax = gca;
% ax.YAxis.Exponent = 0;
% 
% figure("Name", "Altitude vs. Weight")
% plot(t_hr,W,":","LineWidth",3)
% title("Altitude vs. Weight")
% xlabel("Time [hr]")
% ylabel("Weight [lbf]")
% ax = gca;
% ax.YAxis.Exponent = 0;
% ylim([0, W(1)])

%% Code to make the function work with RV7 data

% Setting Cruise Speed
% v_cruise = knots2fts(133);                  % Target velocity for the aircraft

% Aerodynamic Coefficients
% k = 0.071696;       % pi*AR*e
% CD0 = 0.024292;     % Parasitic Drag for the aircraft
% CL_bestLD = sqrt(CD0/k);   % CL for best CL/CD for the aircraft
% CD_bestLD = 2*CD0;         % CD for best CL/CD for the aircraft

% maxCeiling = 15000;             % [ft] Maximum Altitude
% lowest_power_percentage = 60;   % Arbitary lowest throttle percentage

% max_power = nan(guessLength,1);
% percent_power = nan(guessLength,1);


% FOR LOOP
    % Calling in engine data
    % engine0360_max_horsepowers = load("O360MAXhp.mat");
    % engine0360_sfc = load("O360_SFC.mat");
    % MAXhp = engine0360_max_horsepowers.MAXhp;
    % SFC = engine0360_sfc.SFC;
            % find sfc according to the altitude and percent power
    % sfc(i) = SFC(round(y(i)/100),round(percent_power(i)));

%     max_power(i) = MAXhp(round(y(i)/100));                  % [hp] finds the maximum power available from engine at altitude
%     if power_shaft(i) > max_power(i) % the two powers here are in different units
%         warning("Power required to cruise is greater than the maximum power available!")
%         power_shaft(i) = max_power(i);
%     end
%     % find new throttle percent according to power required
%         % TODO: define a new MAXhp with the engine model
%     percent_power(i) = round(power_shaft(i)/max_power(i)*100);          % whole number percentage
%     if isnan(percent_power(i))
%         percent_power(i) = lowest_power_percentage;
%         disp("Minimum Power Reached on iteration "+i)
%     elseif percent_power(i) < lowest_power_percentage
%         percent_power(i) = lowest_power_percentage;
%         disp("Minimum Power Reached on iteration "+i)
%     end
%     power_output(i) = max_power(i)*percent_power(i)/100;                    % [hp]
% 
% 


