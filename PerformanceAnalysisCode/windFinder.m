% Wind Finder Function
% This code will take in time, distance, and altitude of the airplane, convert feet altitude to hectopascals 
% then use hecto pascals to find the matching tailwind on the correct day in the location.

% Positive tailwind pushes the aircraft forward

% TODO: add a location interpolation

function [tailwind_knots] = windFinder(AS_current, all_tailwind, distance)
% Input
% AS_current = the current state vector of the aircraft
%               [ time, distance, weight, altitude, airspeed, ground speed, CL, CD, mode]
% all_tailwind = the cell containing all weather vectors initalized at the beginning of the simulation

time_sec = AS_current(1);           % [sec]
distance_current = AS_current(2);   % [NM]
altitude_ft = AS_current(4);        % [ft]

% Convert the altitude in ft to a pressure altitude in hectoPascals
altitude_hectoPascal = altitudeToPressureHpa(altitude_ft);

%% Time
% Determine the day of tailwinds to look at
time_day = time_sec / (60*60*24);
if time_day > 10
    warning("Flight Duration has exceeded 10 days")
end

for i = length(all_tailwind):-1:1
    if time_day >= i-1
        today_tailwind = all_tailwind{i};
        break       
    end
end

%% Location
distance_difference = distance - distance_current;
[~,location_index] = min(abs(distance_difference));

%% Altitude
pressure_altitude = [  850;
                        700;
                        600;
                        500;
                        400;
                        300;
                        ];

% Determine the altitude to look at winds
levels = 1:length(pressure_altitude);
interpolate_alt = true;

for i = 1:length(pressure_altitude)
    if altitude_hectoPascal >= pressure_altitude(1)
        wind_level = 1;
        interpolate_alt = false;
        break
    elseif altitude_hectoPascal <= pressure_altitude(end)
        wind_level = length(levels);
        interpolate_alt = false;
        warning("Pressure Altitude above 300 hPa")
        break
    elseif altitude_hectoPascal >= pressure_altitude(i)
        wind_level = levels(i);
        break
    end
end

%% Wind Determination
if interpolate_alt
    y0 = today_tailwind(wind_level, location_index);
    y1 = today_tailwind(wind_level-1, location_index);
    x0 = pressure_altitude(wind_level);
    x1 = pressure_altitude(wind_level-1);
    x = altitude_hectoPascal;
    tailwind_ms = ( y0 * (x1 - x) + y1 * (x - x0) ) / (x1 - x0);
else
    tailwind_ms = today_tailwind(wind_level, location_index);
end
 

% Convert Tailwind from m/s to ft/s
tailwind_knots = tailwind_ms * 1.94384449;     % [knots]

% if altitude_hectoPascal >= pressure_altitude(1)
%     wind_level = 1;
%     interpolate_alt = false;
% elseif altitude_hectoPascal >= pressure_altitude(2)
%     wind_level = 2;
% elseif altitude_hectoPascal >= pressure_altitude(3)
%     wind_level = 3;
% elseif altitude_hectoPascal >= pressure_altitude(4)
%     wind_level = 4;
% else
%     wind_level = 4;
%     interpolate_alt = false;
%     warning("Pressure Altitude above 500 hPa")
% end






