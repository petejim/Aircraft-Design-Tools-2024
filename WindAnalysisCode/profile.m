%% get profile

function [tail,cross,distance,point_distance,latitudes,longitudes,unitx,unity] = profile(waypoints, velocity, point_dist, start_alt, end_alt, date)

    %recognize global variables indexed after init
    global WindX
    global WindY
    global WindTime
    global WindPAlt
    
    global speedU
    global speedV

    %turn date input string into index
    dateIndex = strmatch(date,WindTime);

    point_dist = point_dist/0.868976;

    % Convert to Python list of tuples
    pyWaypoints = py.list();
    for i = 1:size(waypoints, 1)
        pyWaypoints.append(py.tuple({waypoints(i, 1), waypoints(i, 2)}));
    end

    % Path to the Python script
    filePath = '/Users/chrissheehan/PycharmProjects/api/venv/interp.py'; % Replace with your file path
    
    % Run the Python script with pyrunfile
    [points]= pyrunfile(filePath, 'points', waypoints = pyWaypoints, point_dist = point_dist);

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

    distance = distance * 0.868976;
    point_distance = point_distance * 0.868976;

    for i = 1:length(distance)

        currentDateIndex = dateIndex + (distance(i)/(velocity * 24));
        alt = start_alt + (end_alt * distance(i)/distance(end));

        [tail(i),cross(i)] = getWind2(longitudes(i), latitudes(i), unitx(i), unity(i), alt , currentDateIndex);

    end

    figure()
    plot(distance, tail)
    figure()
    plot(distance, cross)

end