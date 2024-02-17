%% get profile

function [tail,cross,u,v,distance,point_distance,latitudes,longitudes,unitx,unity] = profileTeamF(waypoints, point_dist, date)

    %recognize global variables indexed after init
    global WindX
    global WindY
    global WindTime
    global WindPAlt
    
    global speedU
    global speedV

    %turn date input string into index
    dateIndex = strmatch(date,WindTime);

    % Convert to Python list of tuples
    pyWaypoints = py.list();
    for i = 1:size(waypoints, 1)
        pyWaypoints.append(py.tuple({waypoints(i, 1), waypoints(i, 2)}));
    end

    % Path to the Python script
%     filePath = '..\WindAnalysisCode\interp.py"'; % Replace with your file path
    
    % Run the Python script with pyrunfile
    [points]= pyrunfile("interp.py", 'points', waypoints = pyWaypoints, point_dist = point_dist);

    Length = length(points);
    
    latitudes = zeros(1, Length);
    longitudes = zeros(1, Length);
    point_distance = zeros(1, Length);
    distance = zeros(1, Length);
    unitx  = zeros(1, Length);
    unity = zeros(1, Length);

    % Extract latitudes and longitudes from each tuple
    for i = 1:Length
        % Extract each tuple
        tuple = points{i};
        
        % Extract and assign latitude and longitude
        longitudes(i) = tuple{1};
        latitudes(i) = tuple{2};
        point_distance(i) = tuple{3};

        if i > 1
            unitx(i - 1) = tuple{4};
            unity(i - 1) = tuple{5};
            distance(i) =  distance(i - 1) + point_distance(i);
        end

        if longitudes(i) < 0
            longitudes(i) = longitudes(i) + 360;
        end
    end

    unitx(i) = tuple{4};
    unity(i) = tuple{5};

    dateIndex = dateIndex + 5;

    for j = 1:4

        for i = 1:length(distance)
    
            tail_point = 0;
            cross_point = 0;
            u_partial = 0;
            v_partial = 0;
    
            for k = 0:49
    
                days_index = mod(k,10);
                year_index = 365 * floor(k/10);
                dist_index = (7 * distance(i)/distance(end));

                currentDateIndex = dateIndex - year_index - days_index + dist_index;

    
                [tail_partial,cross_partial, u_point,v_point] = getWind3(longitudes(i), latitudes(i), unitx(i), unity(i), j, currentDateIndex);
    
                tail_point = tail_point + tail_partial/50;
                cross_point = cross_point + cross_partial/50;
                u_point = u_point + u_partial;
                v_point = v_point + v_partial;
    
            end
    
            tail(j,i) = tail_point;
            cross(j,i) = cross_point;
            u(j,i) = u_point;
            v(j,i) = v_point;
    
        end

    end

%     figure()
%     hold on
%     for i = 1:4
%         plot(distance, tail(i,:))
%     end
%     figure()
%     hold on
%     for i = 1:4
%         plot(distance, cross(i,:))
%     end

end