function [time,x,W,alt,P,v,x_dot,sfc,Cl,Cd] = best_climb_v2(Wi,alt1,alt2,eta,delta_T,delta_time,EngineType,SeaLevelEngine,MinSFC,service_ceiling,n,S,k,Cd0)
% INPUTS:
% Wi - initial weight in lbf or lbm*(ft/s2)
% alt1 - Initial Altitude
% alt1 - Final Altitude
% eta - propeller efficiency
% delta_T - off standard temperature difference in Fahrenheit
% delta_time - time step in seconds
% SeaLevelMatrix - engine matrix
% MinSFC - engine function input
% n - engine function input

% OUTPUTS
% x - distance in nautical miles
% W - final weight in lbf
% P - power in hp
% time - seconds
% alt - change in altitude

% conversions
ft2meter = 0.3048; % feet to meters
mile2ft = 6076.12; % nautical mile to feet
kgm3_2_slugft3 = 0.00194032; % kg per meter cubed to slug per foot cubed
knots2ftps = 1.68781; % knots to feet per second

% constants
[T_isa_SI,~,~,rho_SI] = atmosisa(alt1*ft2meter); % matlab isa
Ti_isa = (T_isa_SI - 273.15)*(9/5)+32; % Kelvin to Fahrenheit
Ti = Ti_isa + delta_T; % Fahrenheit
rhoi = rho_SI*kgm3_2_slugft3 ; % slug/ft3
g0 = 32.174; % ft per second squared (assuming gravity is constant with altitude)

% initialize state vector
x(1) = 0;
W(1) = Wi;
time(1) = 0;
rho(1) = rhoi;
alt(1) = alt1;
path(1) = 2; % initial path angle (degrees)

% Euler
i = 1;
while alt < alt2
    % Solve Aerodynamics
    v(i) = sqrt(2*W(i))/(rho(i)*S) * ((k/(3*Cd0))^0.25);
    Cl(i) = (2*(W(i)*cosd(path(i))))/(rho(i)*S*(v(i))^2);
    Cd(i) = Cd0 + (k*(Cl(i)^2)); %from drag polar given
    D(i) = 0.5*rho(i)*Cd(i)*S*(v(i))^2; % lbf

    % Update Engine Model
    [AdjEngineDeck] = ChangeEngineAlt(EngineType,SeaLevelEngine,MinSFC,alt(i),service_ceiling,n);
    max_power_avail(i) = AdjEngineDeck(end,1);          % [hp]
    max_power_avail_lbf(i) = max_power_avail(i)*550;    % [lbf * ft/s]
    sfc(i) = AdjEngineDeck(end,2);

    % Current State
    x_dot(i) = v(i)*cosd(path(i)); % ft/s
    W_dot = (-sfc(i)*max_power_avail(i))/3600; % divide by 3600 to get in lbf/s

    % Update State
    x(i+1) = x_dot(i)*delta_time + x(i);
    W(i+1) = W_dot*delta_time + W(i);
    time(i+1) = time(i) + delta_time;
    path(i+1) = asind( ((max_power_avail_lbf(i)*eta)/(v(i)*W(i)))- (D(i)/W(i)) );
    alt(i+1) = alt(i) + x_dot(i)*sind(path(i))*delta_time;

    % Atmosphere at updated altitude
    [T_isa_SI,~,~,rho_SI] = atmosisa(alt(i)*ft2meter); % matlab isa
    Ti_isa = (T_isa_SI - 273.15)*(9/5)+32; % Kelvin to Fahrenheit
    T(i+1) = Ti_isa + delta_T; % Fahrenheit
    rho(i+1) = rho_SI*kgm3_2_slugft3 ; % slug/ft3
    Cl(i+1) = Cl(i);
    Cd(i+1) = Cd(i);
    i = i + 1;
end
v(i) = sqrt(2*W(i))/(rho(i)*S) * ((k/(3*Cd0))^0.25);
x_dot = x_dot/knots2ftps;
v = v/knots2ftps; % convert velocity vector back to knots
x = x/mile2ft; % convert feet to nautical miles
x_dot(length(x_dot)+1) = x_dot(length(x_dot));
time = 1:(length(alt)*delta_time);
P = max_power_avail;
P(length(P)+1) = P(length(P));
sfc(length(sfc)+1) = sfc(length(sfc));
end


%     T = D(i);

%     v_dot = (T-D(i))/((W(i)*cosd(path(i)))/g0); % ft/s2

%     p_avail(i) = max(AdjEngineDeck(:,1)); % max available shaft power
%     P_req(i) = (((D(i)*v(i))/eta)/550)*eta; % divide by 550 to put into hp
%     if P_req(i) > p_avail(i)
%         error('Required Power Exceeds Available Power')
%     end
%     percent_power(i) = (P_req(i)/p_avail(i))*100;

%     v(i+1) = v_dot*delta_time + v(i);
    