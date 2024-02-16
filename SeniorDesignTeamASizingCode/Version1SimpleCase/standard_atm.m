function density = standard_atm(altitude_feet)
    % Convert altitude from feet to meters
    altitude_meters = altitude_feet * 0.3048;

    % Constants for the U.S. Standard Atmosphere model
    R = 287.05;   % Specific gas constant for dry air in J/(kg*K)
    T0 = 288.15;  % Sea level temperature in K
    P0 = 101325.0;  % Sea level pressure in Pa
    L = 0.0065;   % Temperature lapse rate in K/m
    g0 = 9.80665;  % Standard acceleration of gravity in m/s^2

    % Calculate temperature at the given altitude
    T = T0 - L * altitude_meters;

    % Calculate pressure at the given altitude
    P = P0 * ((T0 - L * altitude_meters) / T0) ^ (g0 / (R * L));

    % Calculate density using the ideal gas law
    density = P / (R * T);

end