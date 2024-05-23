%% Description
% Basic events are intended to demonstrate the use of events in the
% simulation. These events are simple and can be used as a template for
% more complex events.

%% Code
function [altitudeEvent, distanceEvent] = basicEvents()

    % Return the functions so that they can be used in the script
    altitudeEvent = @altitudeEvent;
    distanceEvent = @distanceEvent;

end

function [altCheckFunc] = altitudeEvent(altitudeMin, altitudeMax)
    % Return an anonymous function that checks if the plane's altitude is
    % within the specified bounds
    % If no min or max is desired, specify false

    if altitudeMin == false
        altCheckFunc = @(aircraftObject) aircraftObject.altitude <= altitudeMax;
    elseif altitudeMax == false
        altCheckFunc = @(aircraftObject) aircraftObject.altitude >= altitudeMin;
    else
        altCheckFunc = @(aircraftObject) aircraftObject.altitude >= altitudeMin && aircraftObject.altitude <= altitudeMax;
    end

end

function [distCheckFunc] = distanceEvent(distanceMin, distanceMax)
    % Return an anonymous function that checks if the plane's distance is
    % within the specified bounds
    % If no min or max is desired, specify false

    if distanceMin == false
        distCheckFunc = @(aircraftObject) aircraftObject.distance <= distanceMax;
    elseif distanceMax == false
        distCheckFunc = @(aircraftObject) aircraftObject.distance >= distanceMin;
    else
        distCheckFunc = @(aircraftObject) aircraftObject.distance >= distanceMin && aircraftObject.distance <= distanceMax;
    end

end