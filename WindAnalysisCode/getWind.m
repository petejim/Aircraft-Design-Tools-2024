2%% AERO 444 - Senior Design 2 - Route Wind Analysis Tool

%Team E:
%Anthony Guerra
%Chris Sheehan
%Ryan White


%Call Data Function
function [wind_valueU,wind_valueV] = getWind(x,y,feet,date) %inputs location in deg, alt, date in ____ format

    %recognize global variables indexed after init
    global WindX
    global WindY
    global WindTime
    global WindPAlt
    
    global speedU
    global speedV

    %turn date input string into index
    dateIndex = strmatch(date,WindTime);
    
    hPa = altitudeToPressureHpa(feet);
    
    %get 2-D slice with date and alt
    nearest_latitudes = findTwoNearestIndices(WindY, y);
    nearest_longitudes = findTwoNearestIndices(WindX, x);
    nearest_pressures = findTwoNearestIndices(WindPAlt, hPa);

    alpha = 0;
    beta = 0;
    gamma = 0;
    AAA = 0;
    wind_valueU = 0;
    wind_partialU = 0;
    wind_valueV = 0;
    wind_partialV = 0;

    for i = 1:2
        lat_index = nearest_latitudes(i);
        alpha = nearest_latitudes(i + 2);
        for j = 1:2
            lon_index = nearest_longitudes(j);
            beta = nearest_longitudes(j + 2) * alpha;
            for k = 1:2
                pressure_level_index = nearest_pressures(k);
                gamma = nearest_pressures(k + 2) * beta;
                %AAA = AAA + gamma;
                
                wind_partialU = speedU(lon_index,lat_index,pressure_level_index,dateIndex);
                wind_valueU = wind_valueU + gamma * wind_partialU;
                
                wind_partialV = speedV(lon_index,lat_index,pressure_level_index,dateIndex);
                wind_valueV = wind_valueV + gamma * wind_partialV;
                
            end
        end
    end


        %turn degree inputs into indexes in X and Y arrays
        %turn date format into indexes in T
        %turn PAlt into index in P

        %interpolation to get precise u and v

        %return u and v

end

