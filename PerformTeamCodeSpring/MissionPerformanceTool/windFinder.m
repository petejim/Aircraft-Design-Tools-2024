% Wind Finder Function


function [] = windFinder(aircraftObject, route)
    %% Inputs:
    % aircraftObject: object containing the aircraft's current state
    % route: object containing the route information
    
    time_sec = aircraftObject.time;           % [sec]
    distance_current = missionConversions(aircraftObject.x, "ftToNM");   % [NM]
    altitude_ft = aircraftObject.y;        % [ft]
    all_tailwind = route.tailwinds;        % [kt]
    all_crosswind = route.crosswinds;      % [kt]
    distance = route.weatherDistActual;    % [NM]

    %% Outputs:
    % tailwindKnots: tailwind component of wind at the current point [kt]
    % crosswindKnots: crosswind component of wind at the current point [kt]

    %% Boundary values
    xMin = altitudeToPressureHpa(0); % [hPa]
    yMin = 0; % [NM]
    yMax = max(distance) + 20; % [NM]
    zMin = 0; % [day]
    zMax = size(all_tailwind, 3) - 1; % [day]
    
    %% Time
    % Determine the day of tailwinds to look at
    time_day = time_sec / (60*60*24);
    if time_day > 10
        warning("Flight Duration has exceeded 10 days")
    end
    
    %% Altitude
    pressure_altitude = [  850;
                            700;
                            600;
                            500;
                            400;
                            300;
                            ];

    x = pressure_altitude;

    % y vals are the route distance
    y = distance;

    % z vals are the day
    z = (0:size(all_tailwind, 3) - 1)';

    % xp is the current pressure altitude
    xp = altitudeToPressureHpa(altitude_ft);

    % yp is the current distance
    yp = distance_current;

    % zp is the current day
    zp = time_day;

    %% Checks

    % Check if the input values are outside the range
    if xp < xMin || yp < yMin || yp > yMax || zp < zMin || zp > zMax
        error('The input values are outside the range of the original data.')
        % This means that there was not enough weather data generated, the plane is too high or too low, or idk
    end

    %% Interpolation

    [X, Y, Z] = meshgrid(y, x, z);

    % Interpolate the tailwind and crosswind components
    aircraftObject.tailwind = interp3(y, x, z, all_tailwind, yp, xp, zp);

    aircraftObject.crosswind = interp3(y, x, z, all_crosswind, yp, xp, zp);
    
    % For each out-of-range query, find the closest point in the dataset and assign its value
    if isnan(aircraftObject.tailwind)
        [~, idx] = min(abs(x - xp));
        [~, idx2] = min(abs(y - yp));
        [~, idx3] = min(abs(z - zp));
        aircraftObject.tailwind = all_tailwind(idx, idx2, idx3);
        aircraftObject.crosswind = all_crosswind(idx, idx2, idx3);
    end


end



   
    
    
    
    
    
    
    