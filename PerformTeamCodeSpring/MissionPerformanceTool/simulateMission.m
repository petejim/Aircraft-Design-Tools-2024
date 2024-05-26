function [dataTable] = simulateMission(aircraftObject, route, events, fieldsToStore)

    %% Description
    % This function is a 2 DOF simulation of an aircraft. This is designed for 
    % an around the world aircraft. It relies on tools created by the Aircraft
    % Design class of 2024. It is heavily based on the mission performance tool
    % created by Peter Kim, Sam Coyle, and Justin Bradford.

    %% Inputs

    % aircraftObject: 
    % 
    % An object that contains all the aircraft parameters

    % route: 
    % 
    % A struct that contains the route data

    % wind: 
    % 
    % A struct that contains the wind data

    % events: 
    % 
    % A struct that contains the events data. The first event is the
    % starting state, so if want to begin with takeoff, the first event should
    % be takeoff.
    % 
    % Fields:

    % name = string, name of the event
    % planeConfig = if the event requires a change in the aircraft object, define a function that will change the aircraft object
    %               as of now, this is irreversable
    % ode = the ode function that will be used to integrate while the event is true
    % startCondition = function that will be passed the aircraft object and will return true if the event should start
    % eventTerminal = true if the event end the simulation

    % fieldsToStore:

    % A cell array of strings that specify the fields that should be stored in the data array




    %% Code

    %% Initialization

    complete = false;

    simSolver = false;

    stepNum = 1;

    % Array to store the data
    data = nan(1000, length(fieldsToStore));
    blankTable = array2table(data, "VariableNames", fieldsToStore);
    clear data;
    dataTable = blankTable;

    % Get first round of data
    dataTable(stepNum, :) = extractData(aircraftObject, fieldsToStore);

    %% Wind Data Initialization
    
    global WindX
    global WindY
    global WindTime
    global WindPAlt
    
    global speedU
    global speedV

    initWind();

    % Generate the days on the route
    route.days = generateDates(route.startDate, route.numDays);

    % Extract just profileTeamFNoPy arguments
    controlPointsLongLat = fliplr(route.controlPointsLatLong);
    setWeatherDist = route.setWeatherDist;
    days = route.days;

    % Preallocate the wind data
    tailwinds = cell(1, route.numDays);
    crosswinds = cell(1, route.numDays);
    distance = cell(1, route.numDays);

    % The chunk of code below will either load wind data, generate wind data, or generate the wind data and save it to a file
    % based on whether the user specifies a wind data file in the route struct and if it exists.

    if isfield(route, 'windDataFile')

        % if the file does not exist, generate the wind data
        filename = fullfile("WindDataLoaded", route.windDataFile);
        if ~isfile(filename)

            % Get wind data on each day
            for i = 1:route.numDays
                
                % Get the wind data for the day
                [tailwinds{i}, crosswinds{i}, ~, ~, distance, ~, ~, ~, ~, ~] = profileTeamFNoPy(controlPointsLongLat, setWeatherDist, days{i});

            end

            % Save the wind data to a file
            
            save(filename, "tailwinds", "crosswinds", "distance");
        
        else

            % If the file does exist, load the wind data
            windData = load(filename);
    
            tailwinds = windData.tailwinds;
            crosswinds = windData.crosswinds;
            distance = windData.distance;

        end

    else

        % If the user does not specify a wind data file, generate the wind data and don't save it

        % Get wind data on each day
        for i = 1:route.numDays

            % Get the wind data for the day
            [tailwinds{i}, crosswinds{i}, ~, ~, distance, ~, ~, ~, ~, ~] = profileTeamFNoPy(controlPointsLongLat, setWeatherDist, days{i});

        end

    end


    % Preallocate for 3D wind arrays
    tailjoe = zeros([size(tailwinds{1},1), size(tailwinds{1}, 2), length(tailwinds)]);
    crossjoe = zeros([size(crosswinds{1},1), size(crosswinds{1}, 2), length(crosswinds)]);

    % Convert data to 3D array
    for i = 1:length(tailwinds)
        tailjoe(:, :, i) = tailwinds{i};
        crossjoe(:, :, i) = crosswinds{i};
    end


    % Store the wind data in the route struct
    route.tailwinds = tailjoe;
    route.crosswinds = crossjoe;
    route.weatherDistActual = distance;


    % Clear placeholder variables
    clear tailwinds crosswinds controlPointsLongLat setWeatherDist days tailjoe crossjoe;


    %% Main Loop

    while complete == false

        % Iterate throught the active events and check if they are still active
        for i = 1:length(events)

            % If the event is active, check if it is still active
            if events{i}.active == true && events{i}.startCondition(aircraftObject) == false

                events{i}.active = false;

            end
        
        end

        % Check event logic by iterating through the events
        for i = 1:length(events)
            
            % If event start logic is true, 
            % the event is not already active, 
            % and the event is not expended, 
            % then start the event
            if events{i}.expended == false && events{i}.active == false && events{i}.startCondition(aircraftObject) == true

                % If the event has a new ode, then set the new ode
                if isa(events{i}.ode, 'function_handle')
                    simSolver = events{i}.ode;
                end

                % If the event has a change to the plane, then set the planeConfig
                if isa(events{i}.planeConfig, 'function_handle')
                    events{i}.planeConfig(aircraftObject);
                end

                % Set the event as expended if it does not repeat
                if events{i}.repeat == false

                    events{i}.expended = true;

                end

                % Set the event to active
                events{i}.active = true;

                % State that the event has started
                disp(['Event "', events{i}.name, '" has started.']);

                % If the event is terminal, then end the simulation
                if isfield(events{i}, 'eventTerminal')

                    if events{i}.eventTerminal == true

                        complete = true;

                        break;

                    end
                end
            end
        end

        % Break out if the sim is complete
        if complete == true
            stepNum = stepNum + 1;
            break;
        end

        % Find local wind data and set it in the aircraft object
        windFinder(aircraftObject, route);

        % Solve for a time step
        simSolver(aircraftObject);

        % Increment the step number
        stepNum = stepNum + 1;

        % Check if table needs to be expanded
        if stepNum > height(dataTable)
            dataTable = [dataTable; blankTable];
        end

        % Extract the data and store it in the data array
        dataTable(stepNum, :) = extractData(aircraftObject, fieldsToStore);

    end


    % Chop off the extra rows
    dataTable = dataTable(1:stepNum, :);

end

function [newTable] = extractData(aircraftObject, fieldsToStore)
    % This function takes the state of the aircraft object and extracts the
    % data to a table in the order requested. 

    newTable = table();
    for i = 1:length(fieldsToStore)
        fieldName = fieldsToStore{i};
        fieldValue = aircraftObject.(fieldName);
        newTable.(fieldName) = fieldValue;
    end

end


function dates = generateDates(startDate, numDays)
    % Generates a consecutive cell list of dates starting from the given date

    % Convert the start date to a datetime
    startDate = datetime(startDate, 'InputFormat', 'dd-MMM-yyyy');
    
    % Generate a vector of dates
    dates = startDate + caldays(0:numDays-1);
    
    % Convert the dates to strings
    dates = cellstr(datestr(dates, 'dd-mmm-yyyy'));
end


% Events

% Solver will be in place until next event with a solver switches it out. If two events with solvers get 
% triggered at the same time, the last one will be the one that is used.

% Events will not repeat their action until their start condition is not true for at least one time step.
% This means that if an event is triggered, it will not be triggered again until the start condition is false then true again.
% Because truth of startCondition is evaluated on each time step, carefull with the complexity of the startCondition function.


%% TODO:
% - Add in the solver functions
% - Add in the planeConfig functions
% - Add in the startCondition functions
% - Deal with wind data


%% Wind
% Steal:
% windFinder.m
% profileTeamFNoPy.m

%% ODE Solvers
% should modify the aircraft object to reflect new state and take into account the wind
% The current state of the object and local wind will be up to date. The solver
% should update any and every aircraft parameter that changes.
