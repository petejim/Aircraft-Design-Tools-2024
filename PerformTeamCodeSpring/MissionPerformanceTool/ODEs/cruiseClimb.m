function [] = cruiseClimb(plane, percentRange, VTASkts)
    %% Description
    % This function does a constant CL cruise climb, and updates
    % the aircraft object with the new state variables after the climb.
    % Calling this will perform a single step of the climb. %   Either 
    % the percentRange or VTASkts must be provided, but do not do both.
    % Give the other as false.

    %% Inputs:
    %   plane: object containing the aircraft's current state
    %   percentRange: the percent range (CL corresponding to L/Dmax * percentRange / 100) (or false)
    %   VTASkts: the target true airspeed in knots (or false)



    %% Code:

    % Check if CL and VTAS are both set
    if ~isempty(plane.cruiseClimb)
        if plane.cruiseClimb.CL && plane.cruiseClimb.VTAS
            plane.TAS = plane.cruiseClimb.VTAS;
            plane.CL = plane.cruiseClimb.CL;
        end
    else

        if VTASkts && percentRange

            error("Both VTAS and percent range cannot be set")

        elseif VTASkts

            plane.TAS = missionConversions(VTASkts, "ktToft_s");

            % Find CL based on SLF
            plane.CL = plane.steadyLevelCL();

            % Set the cruise climb object
            plane.cruiseClimb.CL = plane.CL;
            plane.cruiseClimb.VTAS = plane.TAS;

        elseif percentRange

            % Find CL for a given percent range
            plane.CL = plane.getPercentRangeCL(percentRange);

            % Set density
            [plane.rho, ~, ~] = stdAtmosphere_imperial(plane.y, 0);

            % Find the TAS for the given CL
            plane.TAS = plane.getTAS_SLF();

            % Set the cruise climb object
            plane.cruiseClimb.CL = plane.CL;
            plane.cruiseClimb.VTAS = plane.TAS;
        end
    end

    % Find the new altitude
    plane.rho = plane.getRho();

    % Previous altitude
    yPrev = plane.y;

    % Find the new altitude
    plane.y = altFromDens(plane.rho);

    %% Aero:
    % Solve for CD based on CL
    plane.CD = cdFromDragPolarSpreadsheet(plane, plane.CL);

    % Solve for drag
    plane.drag = plane.forceFromCoefficient(plane.CD);

    %% Propulsion:
    % Solve for power [ft-lb/s]
    power = plane.drag * plane.TAS;

    % Get sfc from engine model [lb/hr/hp] , shaft power [hp], and flow power [lb ft/s]
    [SFC, shaftPowerHp, ~, powerAvail, powerUsed] = plane.getSFC(power);

    % Set power available and power used
    plane.engPowAvail = powerAvail;
    plane.engPowUsed = powerUsed;

    % Set SFC
    plane.SFC = SFC;

    % obtain change in fuel weight [lb/s]
    plane.wDot = -powerUsed * SFC / 3600;

    %% Weather
    % Set groundspeed
    plane.setVelocsByTailAndCross();

    %% State updates

    % Update weight
    plane.W = plane.W + plane.wDot * plane.tStep;

    % Set Vy
    plane.Vy = (plane.y - yPrev)/plane.tStep;

    % Update the aircraft's position
    plane.x = plane.x + plane.Vx * plane.tStep;

end







