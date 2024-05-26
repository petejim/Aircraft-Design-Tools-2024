function [] = constVConstAltCruise(aircraftObject)

    % Function finds the aircraft state at the next time
    % step using the constant velocity and constant altitude cruise

    % Solve for CL steady level flight
    CL = aircraftObject.steadyLevelCL();

    % Solve for CD based on CL
    CD = cdFromDragPolarSpreadsheet(aircraftObject, CL);








end

