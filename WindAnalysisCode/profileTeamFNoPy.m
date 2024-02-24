%% get profile

function [tail,cross,u,v,distance,point_distance,latitudes,longitudes,unitx,unity] ...
    = profileTeamFNoPy(waypoints, point_dist, date)

%% Note
% The original function assumed that the fisrt coordinate point was also 
% the last coordinate point, that is no longer the case. If you want the 
% route to loop back, you must add the first coordinate point to the end of
% the list of waypoints.

%% Description
% This function calculates the wind components at each point along the 
% flight path. It adds points between the input waypoints such that the 
% distance between points is approximately equal to the input point_dist. 
% It then calculates the wind components at each point using the wind data
% averaged (ask team F how they did this, I am not team F). This function 
% was created to remove any python from the code, as it was causing issues.

%% Inputs
% waypoints  = [longitude,latitude]                               [deg,deg]
% point_dist = distance between points                                 [nm]
% date       = date of flight (format: 'dd-mmm-yyyy HH:MM:SS')        [str]

%% Outputs
% tail           = tailwind component of wind at each point            [kt]
% cross          = crosswind component of wind at each point           [kt]
% u              = u component of wind at each point                   [kt]
% v              = v component of wind at each point                   [kt]
% distance       = distance from start to each point                   [nm]
% point_distance = distance between each point                         [nm]
% latitudes      = latitude of each point                             [deg]
% longitudes     = longitude of each point                            [deg]
% unitx          = x component of unit vector between each point [unitless]
% unity          = y component of unit vector between each point [unitless]


    %recognize global variables indexed after init
    global WindX
    global WindY
    global WindTime
    global WindPAlt
    
    global speedU
    global speedV

    %turn date input string into index
    dateIndex = strmatch(date,WindTime);

    % % Convert to Python list of tuples
    % pyWaypoints = py.list();
    % for i = 1:size(waypoints, 1)
    %     pyWaypoints.append(py.tuple({waypoints(i, 1), waypoints(i, 2)}));
    % end

    % % Path to the Python script
    % filePath = 'D:\SCHOOL\2023-24 School Shit\2 - Winter Quarter\AERO 444\WindAnalysisTool\interp.py'; % Replace with your file path
    
    % % Run the Python script with pyrunfile
    % [points]= pyrunfile(filePath, 'points', waypoints = pyWaypoints, point_dist = point_dist);

    points = newInterp(waypoints, point_dist);

    Length = size(points, 1);
    
    % latitudes = zeros(1, Length);
    % longitudes = zeros(1, Length);
    % point_distance = zeros(1, Length);
    distance = zeros(1, Length);
    % unitx  = zeros(1, Length);
    % unity = zeros(1, Length);

    % % Extract latitudes and longitudes from each tuple
    % for i = 1:Length
    %     % Extract each tuple
    %     tuple = points{i};
        
    %     % Extract and assign latitude and longitude
    %     longitudes(i) = tuple{1};
    %     latitudes(i) = tuple{2};
    %     point_distance(i) = tuple{3};

    %     if i > 1
    %         unitx(i - 1) = tuple{4};
    %         unity(i - 1) = tuple{5};
    %         distance(i) =  distance(i - 1) + point_distance(i);
    %     end

    %     if longitudes(i) < 0
    %         longitudes(i) = longitudes(i) + 360;
    %     end
    % end

    % unitx(i) = tuple{4};
    % unity(i) = tuple{5};

    longitudes = points(:,1);
    latitudes = points(:,2);
    % Statute miles might want to change this in the future
    point_distance = points(:,3);
    unitx = points(:,4);
    unity = points(:,5);
    longitudes(longitudes < 0) = longitudes(longitudes < 0) + 360; 
    % Statute miles might want to change this in the future
    distance = cumsum(point_distance);

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


function [points] = newInterp(waypoints, point_dist)

    points = calculate_intermediate_points(waypoints, point_dist);

end

function [points] = calculate_intermediate_points(waypoints, point_dist)

% For some reason the original output distance in statute miles, so I'm sticking with that


    % og claims this is kilometer conversion, hmm!?!
    distance_per_point = point_dist;

    % [longitude, latitude, distance_from_previous_point, unit_x, unit_y]
    points = [waypoints(1,1),waypoints(1,2),nan,nan,nan];

    for i = 1:size(waypoints, 1)-1

        start_point = waypoints(i, :);
        end_point = waypoints(i+1, :);


        % calculate total distance between waypoints using mapping toolbox
        total_distance_deg = distance(start_point(2), start_point(1), end_point(2), end_point(1));

        % Working in nautical miles
        total_distance = deg2nm(total_distance_deg);

        % Calculate the number of intermediate points needed
        num_points = floor(total_distance / distance_per_point);

        % If there is not enough distance to add a point, add one point
        if num_points == 0
            num_points = 1;
        end

        % Find the intermediate points
        [lat,long] = track2(start_point(2), start_point(1), end_point(2), end_point(1),[1 0],"degrees",num_points+2);

        points = [points;long(2:end,1),lat(2:end,1),nan*long(2:end,1),nan*long(2:end,1),nan*long(2:end,1)];

    end

    % Calculate the distance between each point
    for i = 1:size(points, 1)
        if i == 1
            points(i, 3) = 0;
        else

            points(i, 3) = deg2nm(distance(points(i, 2), points(i, 1), points(i-1, 2), points(i-1, 1)));
        end
    end

    % Calculate the unit vector between each point
    for i = 1:size(points, 1)
        if i == size(points, 1)
            points(i, 4:5) = points(i-1, 4:5);
        else
            [x_comp,y_comp] = calculate_unit_vector([points(i, 1), points(i, 2)], [points(i+1, 1), points(i+1, 2)]);
            points(i, 4:5) = [x_comp, y_comp];
        end
    end

end

function [x_comp,y_comp] = calculate_unit_vector(start_point, end_point)

    % Convert latitude and logitude differences to radians
    % Adjust longitude difference for wrap around
    diff_long = end_point(1) - start_point(1);
    diff_long = mod((diff_long + 180),360) - 180;
    diff_long = deg2rad(diff_long);

    diff_lat = deg2rad(end_point(2) - start_point(2));

    % x component (East-West direction)
    x_comp = diff_long * cos(deg2rad((start_point(2) + end_point(2))/2));

    % y component (North-South direction)
    y_comp = diff_lat;

    % Normalize the vector
    magnitude = sqrt(x_comp^2 + y_comp^2);

    if magnitude == 0
        x_comp = 0;
        y_comp = 0;
    else
        x_comp = x_comp / magnitude;
        y_comp = y_comp / magnitude;
    end

end