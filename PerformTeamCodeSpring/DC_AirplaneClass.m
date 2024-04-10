% Class to represent airplane configuration and state of airplane

classdef DC_AirplaneClass
    properties

        % Takeoff weight
        W_TO

        % Wing area
        S

        % Aspect ratio
        AR

        % Oswald efficiency factor
        osw

        % Zero-lift drag coefficient
        CD0

        % Propulsive efficiency
        eta_p

        % k
        k


    end

    methods
        function obj = DC_AirplaneClass(WTO, S, AR, osw, CD0, k, eta_p)
            % Constructor

            % WTO     = Takeoff weight                          [lbs]
            % S       = Wing area                               [ft^2]
            % AR      = Aspect ratio
            % osw     = Oswald efficiency factor
            % CD0     = Zero-lift drag coefficient
            % k       = k
            % eta_p   = Propulsive efficiency

            % Takeoff weight
            obj.W_TO = WTO;

            % Wing area
            obj.S = S;

            % Aspect ratio
            obj.AR = AR;

            % Oswald efficiency factor
            obj.osw = osw;

            % Zero-lift drag coefficient
            obj.CD0 = CD0;

            % k
            obj.k = k;

            % Propulsive efficiency
            obj.eta_p = eta_p;




        end

        % function [CL, CD] = getCLCD(obj, V, rho, h)
        %     % Calculate lift and drag coefficients

        %     % V     = Airspeed                                [ft/s]
        %     % rho   = Air density                             [slugs/ft^3]
        %     % h     = Altitude                                [ft]

        %     % Calculate dynamic pressure
        %     q = 0.5 * rho * V^2;

        %     % Calculate lift coefficient
        %     CL = obj.W_TO / (q * obj.S);

        %     % Calculate drag coefficient
        %     CD = obj.CD0 + obj.k * CL^2;

        % end
    end

end