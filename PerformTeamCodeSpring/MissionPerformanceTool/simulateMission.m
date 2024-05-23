function [dataTable] = simulateMission(aircraftObject, route, wind, events, fieldsToStore)

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


    %% Main Loop

    while complete == false

        % Check event logic by iterating through the events
        for i = 1:length(events)
            
            % If event start logic is true, then start the event
            if events{i}.startCondition(aircraftObject) == true

                % If the event has a new ode, then set the new ode
                if isfield(events{i}, 'solver')
                    simSolver = events{i}.ode;
                end

                % If the event has a change to the plane, then set the planeConfig
                if isfield(events{i}, 'planeConfig')
                    events{i}.planeConfig(aircraftObject);
                end

                % If the event is terminal, then end the simulation
                if isfield(events{i}, 'eventTerminal')
                    complete = true;
                    break;
                end

            end

        end

        % Break out if the sim is complete
        if complete == true
            break;
        end

        % Check if table needs to be expanded
        if stepNum > height(dataTable)
            dataTable = [dataTable; blankTable];
        end
        

        % Find local wind data


        % Set the local wind data
        aircraftObject.localWind = localWind;

        % Solve for a time step
        simSolver(aircraftObject);

        % Extract the data and store it in the data array
        dataTable(stepNum, :) = extractData(aircraftObject, fieldsToStore);

        % Increment the step number
        stepNum = stepNum + 1;

    end








end

function [newArray] = extractData(aircraftObject, fieldsToStore)
    % This function takes the state of the aircraft object and extracts the
    % data to an array in the order requested. 

    newArray = nan(1, length(fieldsToStore));
    for i = 1:length(fieldsToStore)
        newArray(i) = aircraftObject.(fieldsToStore{i});
    end

end


% Events

% Solver will be in place until next event with a solver switches it out. If two events with solvers get 
% triggered at the same time, the last one will be the one that is used.


%% TODO:
% - Add in the solver functions
% - Add in the planeConfig functions
% - Add in the startCondition functions
% - Deal with wind data
