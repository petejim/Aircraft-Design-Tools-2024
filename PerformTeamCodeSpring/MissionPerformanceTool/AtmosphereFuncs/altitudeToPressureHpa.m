%% AERO 444 - Senior Design 2 - Route Wind Analysis Tool

function pressure_hPa = altitudeToPressureHpa(altitude_ft)
    % Constants for the standard atmosphere
    P0 = 1013.25; % Sea level standard atmospheric pressure (hPa)
    T0 = 288.15;  % Sea level standard temperature (K)
    g = 9.80665;  % Earth-surface gravitational acceleration (m/s^2)
    L = 0.0065;   % Temperature lapse rate (K/m)
    R = 287.05;   % Ideal gas constant for dry air (J/(kg·K))
    altitude_m = altitude_ft * 0.3048; % Convert feet to meters

    % Barometric formula
    pressure_hPa = P0 * (1 - L * altitude_m / T0) ^ (g / (R * L));
end