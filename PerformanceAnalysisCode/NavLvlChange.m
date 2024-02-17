function [time,x,W,P,alt,v,x_dot,sfc,Cl,Cd] = NavLvlChange(Wi,Vi,alt1,alt2,eta,delta_T,delta_time,climb_rate,EngineType,SeaLevelEngine,MinSFC,n,S,k,Cd0)

% INPUTS:
% Wi - initial weight in lbf or lbm*(ft/s2)
% alt1 - Initial Altitude
% alt1 - Final Altitude
% speed - cruise speed in knots
% eta - propeller efficiency
% delta_T - off standard temperature difference in Fahrenheit
% delta_time - time step in seconds
% SeaLevelMatrix - engine matrix
% MinSFC - engine function input
% n - engine function input

% OUTPUTS
% Cl - lift coefficient
% Cd - drag coefficient
% x - distance in nautical miles
% W - final weight in lbf
% v - TAS in knots
% P - power in hp
% time - seconds

% conversions and constants
ft2meter = 0.3048; % feet to meters
mile2ft = 6076.12; % nautical mile to feet
kgm3_2_slugft3 = 0.00194032; % kg per meter cubed to slug per foot cubed
knots2ftps = 1.68781; % knots to feet per second
min2sec = 1/60; % sec
HPconv = 550; % lb*ft/s

% initialize state vector
x(1) = 0; 
W(1) = Wi; % Initial weight
time(1) = 0;
alt(1) = alt1; % Initial altitude (ft)
v(1) = Vi*knots2ftps; % Initial velicity (ft/s)
climb_rate = climb_rate*min2sec;
path(1) = real(asin(climb_rate/(v(1)))); % Path Angle (degrees)
Cl = [];
Cd = [];

if alt1 < alt2
    % Climb Euler
    i = 1;
    while alt < alt2
        % Atmosphere Model
        [T_isa_SI,~,~,rho_SI] = atmosisa(alt(i)*ft2meter); % matlab isa
        Ti_isa = (T_isa_SI - 273.15)*(9/5)+32; % Kelvin to Fahrenheit
        T(i) = Ti_isa + delta_T; % Fahrenheit
        rho(i) = rho_SI*kgm3_2_slugft3 ; % slug/ft3

        % Lift and climb
        Cl(i) = (2*W(i))/(rho(i)*v(i)^2*S);
        Cd(i) = Cd0 + (k*(Cl(i)^2)); %from drag polar given
        D(i) = 0.5*rho(i)*Cd(i)*S*(v(i))^2; % lbf
        path(i) = real(asin(climb_rate/v(i))); % path angle
        rate_climb(i) = v(i) * sin(path(i)); % climb rate 

        % Climb Power 
        [AdjEngineDeck] = ChangeEngineAlt(EngineType,SeaLevelEngine,MinSFC,alt(i),n); % change power matrix
        power_req_level(i) = (D(i)*v(i))/(HPconv*eta); % sea level power 
        power_req(i) = power_req_level(i) + ((rate_climb(i)*W(i))/HPconv); % required climb power
        p_avail(i) = max(AdjEngineDeck(:,1)); % max available shaft power
        if power_req(i) > p_avail(i)
            warning('Required Power Exceeds Available Power')
        end
        percent_power(i) = power_req(i)/p_avail(i)*100; 
        sfc(i) = AdjEngineDeck(round(percent_power(i)),2);

        % Current State
        x_dot(i) = v(i)*cos(path(i)); % ft/s
        W_dot = (-sfc(i)*power_req(i))/3600; % divide by 3600 to get in lbf/s

        % Update State
        x(i+1) = x_dot(i)*delta_time + x(i);
        W(i+1) = W_dot*delta_time + W(i);
        time(i+1) = time(i) + delta_time;
        alt(i+1) = alt(i) + v(i)*sin(path(i));
        Cl(i+1) = Cl(i);
        Cd(i+1) = Cd(i);

        % Velocity Change (should not be required)
        if rate_climb < climb_rate
           v(i+1) = v(i) + 1;
        elseif rate_climb > climb_rate
           v(i+1) = v(i) - 1;
        elseif rate_climb == climb_rate
           v(i+1) = v(i);
        end
        i = i + 1;
    end
elseif alt1 > alt2
        % Descent Euler
    i = 1;
    while alt > alt2
        % Atmosphere Model
        [T_isa_SI,~,~,rho_SI] = atmosisa(alt(i)*ft2meter); % matlab isa
        Ti_isa = (T_isa_SI - 273.15)*(9/5)+32; % Kelvin to Fahrenheit
        T(i) = Ti_isa + delta_T; % Fahrenheit
        rho(i) = rho_SI*kgm3_2_slugft3 ; % slug/ft3

        % Lift and Descent
        Cl(i) = (2*W(i))/(rho(i)*v(i)^2*S);
        Cd(i) = Cd0 + (k*(Cl(i)^2)); %from drag polar given
        D(i) = 0.5*rho(i)*Cd(i)*S*(v(i))^2; % lbf
        path(i) = real(asin(climb_rate/v(i))); % path angle
        rate_climb(i) = v(i) * sin(path(i)); % climb rate 

        % Descent Power 
        [AdjEngineDeck] = ChangeEngineAlt(EngineType,SeaLevelEngine,MinSFC,alt(i),n); % change 
        power_req_level(i) = (D(i)*v(i))/(HPconv*eta); % sea level power 
        power_req(i) = power_req_level(i) + ((rate_climb(i)*W(i))/HPconv); % required climb power
        p_avail(i) = max(AdjEngineDeck(:,1)); % max available shaft power
        if power_req(i) > p_avail(i)
            warning('Required Power Exceeds Available Power')
        end
        percent_power(i) = power_req(i)/p_avail*100; 
        sfc(i) = AdjEngineDeck(round(percent_power(i)),2);

        % Current State
        x_dot(i) = v(i)*cos(path(i)); % ft/s
        W_dot = (-sfc(i)*power_req(i))/3600; % divide by 3600 to get in lbf/s

        % Update State
        x(i+1) = x_dot(i)*delta_time + x(i);
        W(i+1) = W_dot*delta_time + W(i);
        time(i+1) = time(i) + delta_time;
        alt(i+1) = alt(i) + v(i)*sin(path(i));
        Cl(i+1) = Cl(i);
        Cd(i+1) = Cd(i);

        % Velocity Change (should not be required)
        if rate_climb < climb_rate
           v(i+1) = v(i) + 1;
        elseif rate_climb > climb_rate
           v(i+1) = v(i) - 1;
        elseif rate_climb == climb_rate
           v(i+1) = v(i);
        end
        i = i + 1;
    end
elseif alt1 == alt2
    error('Input altitudes must differ (0-15k ft)')
end
v = v/knots2ftps; % convert velocity vector back to knots
x = x/mile2ft; % convert feet to nautical miles
time = (1:length(alt))*delta_time;
P = power_req;
P(length(P)+1) = P(length(P));
sfc(length(sfc)+1) = sfc(length(sfc));
x_dot(length(x_dot)+1) = x_dot(length(x_dot));
x_dot = x_dot/knots2ftps;
end