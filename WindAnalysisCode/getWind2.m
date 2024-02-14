%% AERO 444 - Senior Design 2 - Route Wind Analysis Tool

%Team E:
%Anthony Guerra
%Chris Sheehan
%Ryan White


%Call Data Function
function [tail,cross] = getWind2(x,y,unitx,unity,feet,dateIndex) %inputs location in deg, alt, date in ____ format

    %recognize global variables indexed after init
    global WindX
    global WindY
    global WindPAlt
    
    global speedU
    global speedV
    
    hPa = altitudeToPressureHpa(feet);
    
    %get 2-D slice with date and alt
    nearest_latitudes = findTwoNearestIndices(WindY, y);
    nearest_longitudes = findTwoNearestIndices(WindX, x);
    nearest_pressures = findTwoNearestIndices(WindPAlt, hPa);
    nearest_dates = [floor(dateIndex), ceil(dateIndex), ceil(dateIndex) - dateIndex, dateIndex - floor(dateIndex)];

    if nearest_dates(1) == nearest_dates(2)
        nearest_dates(3) = 1;
    end

    wind_valueU = 0;
    wind_valueV = 0;
    AAA = 0;

    for h  = 1:2
        date_index = nearest_dates(h);
        lambda = nearest_dates(h + 2);
        for i = 1:2
            lat_index = nearest_latitudes(i);
            alpha = lambda * nearest_latitudes(i + 2);
            for j = 1:2
                lon_index = nearest_longitudes(j);
                beta = nearest_longitudes(j + 2) * alpha;
                for k = 1:2
                    pressure_level_index = nearest_pressures(k);
                    gamma = nearest_pressures(k + 2) * beta;
                    AAA = AAA + gamma;
                    
                    wind_partialU = speedU(lon_index,lat_index,pressure_level_index,date_index);
                    wind_valueU = wind_valueU + gamma * wind_partialU;
                    
                    wind_partialV = speedV(lon_index,lat_index,pressure_level_index,date_index);
                    wind_valueV = wind_valueV + gamma * wind_partialV;
                    
                end
            end
        end
    end

    A = [wind_valueU, wind_valueV];
    B = [unitx, unity];
    B_perp = [-unity, unitx];

    tail = dot(A, B);
    cross = dot(A, B_perp);

end

