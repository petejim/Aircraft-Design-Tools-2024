function [] = constVConstAltCruise(aircraftObject, airspeed)

    % Function finds the aircraft state at the next time
    % step using the constant velocity and constant altitude cruise
    % Inputs:
    %   aircraftObject: object containing the aircraft's current state
    %   airspeed: desired true airspeed for the cruise [KTAS]

    % Sets:
    %   aircraftObject.TAS: true airspeed [ft/s]
    %   aircraftObject.Vx: horizontal velocity [ft/s]
    %   aircraftObject.Vy: vertical velocity [ft/s]
    %   aircraftObject.CL: lift coefficient
    %   aircraftObject.CD: drag coefficient
    %   aircraftObject.drag: drag force [lb]
    %   aircraftObject.wDot: rate of change of weight [lb/s]
    %   aircraftObject.x: horizontal position [ft]
    %   aircraftObject.w: weight [lb]
    %   aircraftObject.SFC: specific fuel consumption [lb/hr/hp]
    %   aircraftObject.rho: air density [slug/ft^3]


    % Convert airspeed from KTAS ft/s TAS
    airspeed = missionConversions(airspeed, "ktToft_s");

    % Set the aircraft's airspeed
    aircraftObject.TAS = airspeed;

    %% Wind

    % Set groundspeed
    aircraftObject.setVelocsByTailAndCross()

    % Set Vy
    aircraftObject.Vy = 0;

    % Set density
    [rho, ~, ~] = stdAtmosphere_imperial(aircraftObject.y,aircraftObject.deltaT);
    aircraftObject.rho = rho;

    %% Aero

    % Solve for CL steady level flight
    aircraftObject.CL = aircraftObject.steadyLevelCL();

    % Solve for CD based on CL
    aircraftObject.CD = cdFromDragPolarSpreadsheet(aircraftObject, aircraftObject.CL);

    % Solve for drag
    aircraftObject.drag = aircraftObject.forceFromCoefficient(aircraftObject.CD);

    % Solve for power [ft-lb/s]
    power = aircraftObject.drag * aircraftObject.TAS;

    %% Propulsion

    % Get sfc from engine model [lb/hr/hp] , shaft power [hp], and flow power [lb ft/s]
    [SFC, shaftPowerHp, ~, powerAvail, powerUsed] = aircraftObject.getSFC(power);

    % Set power available and power used
    aircraftObject.engPowAvail = powerAvail;

    aircraftObject.engPowUsed = powerUsed;

    % Set SFC
    aircraftObject.SFC = SFC;

    % obtain change in fuel weight [lb/s]
    aircraftObject.wDot = -SFC * powerUsed / 3600;

    %% State updates

    % Update the aircraft's position
    aircraftObject.x = aircraftObject.x + aircraftObject.Vx * aircraftObject.tStep;

    % Update the aircraft's weight
    aircraftObject.W = aircraftObject.W + aircraftObject.wDot * aircraftObject.tStep;

end

