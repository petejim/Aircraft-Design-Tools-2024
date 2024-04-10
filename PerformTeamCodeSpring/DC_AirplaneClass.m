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

        % dCL_dAoA
        dCL_dAoA

        % zero-lift AoA
        alpha0

        % State Variables-------------------------------------
        % current weight
        W
        % x position [ft]
        x
        % y position (alt) [ft]
        y
        % Vx [ft/s]
        Vx
        % Vy [ft/s]
        Vy
        % Ax [ft/s^2]
        Ax
        % Ay [ft/s^2]
        Ay
        % AoA [rad]
        AoA
        % Coefficient of rolling resistance
        Crr
        % True airspeed
        TAS

        % Standard atmosphere temperature offset
        deltaT
    end

    methods
        function obj = DC_AirplaneClass(WTO, S, AR, osw, CD0, k, eta_p, dCL_dAoA, alpha0)
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

            % lift slope
            obj.dCL_dAoA = dCL_dAoA;

            % zero-lift AoA
            obj.alpha0 = alpha0;


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
        function [L] = getLfromAoA(obj)
            % for the current state AoA find the lift being generated
            % for now use zero-lift AoA, lift slope to get CL from alpha
            CL = obj.dCL_dAoA*(obj.AoA-obj.alpha0);
            [rho, ~, ~] = stdAtmosphere_imperial(obj.y, obj.deltaT);
            L = 0.5*rho*obj.S*CL*obj.TAS^2;
        end
        function [AoA] = getAoAfromn(obj,n)
            % given load factor n finds the required AoA
            lift = n*obj.W;
            [rho, ~, ~] = stdAtmosphere_imperial(obj.y, obj.deltaT);
            CL = 2*lift/(rho*obj.S*obj.TAS^2);
            AoA=CL/obj.dCL_dAoA+obj.alpha0;
        end
        function [obj] = setCRR(obj, CRR)
            obj.Crr = CRR;
        end
        function [Fr] = getRollFriction(obj)
            L = obj.getLfromAoA();
            N = obj.W-L;
            Fr = N*obj.Crr;
        end


    end

end