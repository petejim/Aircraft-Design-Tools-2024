function[range,x,totT,t,avgV,weight] = rangeFromFuelFractions(bregTypes,...
    MTOW,fFuel,dists,veloTAS,vWind,altitudes,SFCs,WS,EWF,eta,AR,osw,CD0)

% Density conversion
densitys = densFromAlt(altitudes);

weight = zeros(length(bregTypes)+1,1);

x = zeros(length(bregTypes),1);

t = zeros(length(bregTypes),1);

% Conversion to change feet to nautical miles
ft2nm = 12 * 2.54 / 100 / 1852;

% Conversion to change lbf/hr/hp to lbf/s/(lbf ft/s)
sfcConv = 1 / 3600 / 550;

% Induced drag coefficient
k = 1/(pi * osw * AR);

for i = 1:(length(fFuel)+1)

    % You might be able to think of a way to vectorize this
    if i == 1
        weight(i,1) = MTOW;
    else
        weight(i,1) = MTOW * prod((1-fFuel(1:(i-1))));
    end

end

S = MTOW / WS;

for i = 1:length(bregTypes)

    updWS = weight(i) / (S);
    % This function is the same that the weightFromSegments code uses
    [CL1,LD1] = find_LD_and_CL(veloTAS(i),densitys(i),updWS,AR,osw,CD0);

    % I rewrote this one using Dr. Iscold's poster
    LDmax = sqrt(CD0/k)/2/CD0;

    switch bregTypes(i)

        case 0

            % time in hours
            t(i,1) = 2 * LD1 * eta * 550 * (weight(i+1)^(-1/2) - ...
                weight(i)^(-1/2)) / (SFCs(i) * ...
                (2/(densitys(i) * S * CL1))^(1/2));

            % Const L/D, alt
            x(i,1) = eta * LD1 * ft2nm / (sfcConv * SFCs(i)) * ...
                log(1 / (1 - fFuel(i))) + t(i,1) * vWind(i);


        case 1

            % time in hours
            t(i,1) = dists(i)/(veloTAS(i) + vWind(i));

            % Const L/D, velocity
            x(i,1) = eta * LD1 * ft2nm / (sfcConv * SFCs(i)) * ...
                log(1 / (1 - fFuel(i))) + vWind(i) * t(i,1);

        case 2

            % time in hours
            t(i,1) = dists(i)/(veloTAS(i) + vWind(i));


            % Const velocity, altitude
            x(i,1) = 2 * eta * LDmax * ft2nm / (sfcConv * SFCs(i)) ...
                * atan(LD1 * fFuel(i) / (2 * LDmax * ...
                (1 - k * CL1 * LD1 * fFuel(i)))) + vWind(i) * t(i,1);


        otherwise

            error("invalid breguet flag")

    end
    
end
    
range = sum(x);

totT = sum(t);

avgV = range / totT;

end