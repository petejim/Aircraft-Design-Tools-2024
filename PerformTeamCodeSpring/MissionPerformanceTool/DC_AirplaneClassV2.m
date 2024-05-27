% Class to represent airplane configuration and state of airplane

classdef DC_AirplaneClassV2 < handle
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

        % Sea level engine matrix [P, SFC, RPM]
        engMatSL

        % critical altitude
        crit_alt

        % State Variables-------------------------------------
        % current weight
        W
        % weight change rate [lb/s]
        wDot
        % Time [s]
        time
        % Step size [s]
        tStep
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
        % x-component of wind [ft/s]
        Wx
        % y-component of wind [ft/s]
        Wy
        % crosswind component [ft/s]
        Wc
        % True airspeed [ft/s]
        TAS
        % Density [slug/ft^3]
        rho
        % prop efficiency envelope
        etaP_envelope
        % prop diameter [ft]
        D_prop
        % Standard atmosphere temperature offset
        deltaT
        % Tailwind [kt] positive is tailwind
        tailwind
        % Crosswind [kt] (I don't know the sign convention)
        crosswind
        % Drag polar [CD, CL]
        dragPolar
        % Shaft power [hp]
        shaftPower
        % Lift coefficient
        CL
        % Drag coefficient
        CD
        % Drag [lbf]
        drag
        % SFC [lb/hp/hr]
        SFC
        % Percent range struct
        percentRange
        % Cruise climb struct (should be zerod out at the start of each cruise climb)
        cruiseClimb
        % obj.cruiseClimb.CL
        % obj.cruiseClimb.VTAS  [ft/s]
        % Num engines running
        engCount
        % Available engine power [hp]
        engPowAvail
        % Total engine power in use [hp]
        engPowUsed

    end

    methods
        function obj = DC_AirplaneClassV2(WTO, S, AR, osw, CD0, k, eta_p, dCL_dAoA, alpha0)
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

            % W
            obj.W = WTO;

            % load engine matrix SL
            engMatSL_table = load("CD135_SL.mat");
            obj.engMatSL = table2array(engMatSL_table.engineData);
            
            % load propeller data
            % for now, propeller data comes from piper arrow
            envelope = load("etaP_envelope.mat");
            obj.etaP_envelope = envelope.eta_envelope;
            
            % prop diameter
            obj.D_prop = 6;%ft

            % critical alt
            obj.crit_alt = 6000;

            % for now zero out position, velocity, acceleration, AoA, etc
            obj.time = 0;
            obj.x = 0;
            obj.y = 0;
            obj.Vx = 0;
            obj.Vy = 0;
            obj.Ax = 0;
            obj.Ay = 0;
            obj.AoA = 0;
            obj.Crr = 0;
            

        end

        % -----------------------------------------------------------
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
        function [L,CL] = getL(obj)
            % for the current state AoA find the lift being generated
            % for now use zero-lift AoA, lift slope to get CL from alpha
            CL = obj.dCL_dAoA*(obj.AoA-obj.alpha0);
            [rho, ~, ~] = stdAtmosphere_imperial(obj.y, obj.deltaT);
            L = 0.5*rho*obj.S*CL*obj.TAS^2;
        end

        function [L,CL] = getLFromAoA(obj,AoA)
            % find what lift would be at a specified AoA other than current
            % state
            CL = obj.dCL_dAoA*(AoA-obj.alpha0);
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

        function [D,CD] = getDrag(obj)
            [~,CL] = obj.getL();
            CD = obj.CD0+obj.k*CL^2;
            [rho, ~, ~] = stdAtmosphere_imperial(obj.y, obj.deltaT);
            D = 0.5*rho*obj.S*CD*obj.TAS^2;
        end

        function [Fr] = getRollFriction(obj)
            L = obj.getL();
            N = obj.W-L;
            if N>0
                Fr = N*obj.Crr;
            else
                Fr=0;
            end
        end

        function [obj] = calcTAS(obj)
            % for now just do tailwind component
            obj.TAS = obj.Vx-obj.Wx;
        end

        function [P_thp, T] = getPowerThrust(obj, p_pct)
            % flesh this out with actual CD-135 engine deck and prop
            % performance
            % For now just constant derating and prop efficiency
            P_shp = 2*135*p_pct;
            P_thp = obj.eta_p*P_shp;
            T = P_thp*550/obj.TAS;
            if T>1500
                T=1500;
            end
        end

        function [P_shp, P_thp, SFC, FF, T] = engine_prop(obj, p_pct)
            [rho,~,~] = stdAtmosphere_imperial(obj.y,obj.deltaT);
            [rho_crit,~,~] = stdAtmosphere_imperial(obj.crit_alt,0);
            if rho>rho_crit
                % below critical altitude
                P_shp = obj.engMatSL(length(obj.engMatSL),1)*p_pct;
                SFC = interp1(obj.engMatSL(:,1),obj.engMatSL(:,2),P_shp);
                rpm = interp1(obj.engMatSL(:,1),obj.engMatSL(:,3),P_shp);
            else
                % 107 hp at 16k
                engMatCorr = obj.engMatSL;
                engMatCorr(:,1) = obj.engMatSL(:,1).*rho/rho_crit;
                P_shp = engMatCorr(length(engMatCorr),1)*p_pct;
                SFC = interp1(engMatCorr(:,1),engMatCorr(:,2),P_shp);
                rpm = interp1(engMatCorr(:,1),engMatCorr(:,3),P_shp);
            end
            J = obj.TAS/(rpm/60*obj.D_prop);
            % current data has minimum J=0.1479, maximum J=2.0662
            if J>=0.1479 && J<2.0662
                etaP = interp1(obj.etaP_envelope(:,1),obj.etaP_envelope(:,2),J)*0.82/0.86;
                P_thp = etaP*P_shp;
                T = P_thp*550/obj.TAS;
            elseif J<0.1479
                etaP_jmin = interp1(obj.etaP_envelope(:,1),obj.etaP_envelope(:,2),0.1479)*0.82/0.86;
                P_thp_jmin = etaP_jmin*P_shp;
                TAS_jmin = 0.1479*(rpm/60*obj.D_prop);
                T = P_thp_jmin*550/TAS_jmin;
                P_thp = T*obj.TAS*550;
            end
            FF = SFC*P_shp/3600;%lb/s
        end
        function [P_shp, P_thp, SFC, FF, T] = engine_prop_voyager(obj, p_pct)
            % simulate voyager's engines for takeoff study
            [rho,~,~] = stdAtmosphere_imperial(obj.y,obj.deltaT);
            [rho_crit,~,~] = stdAtmosphere_imperial(0,0);% voyager used normally aspirated engines
            engMatCorr = obj.engMatSL*120/135;%correct power to average of voyager engines
            if rho>rho_crit
                % below critical altitude
                P_shp = engMatCorr(length(engMatCorr),1)*p_pct;
                SFC = interp1(engMatCorr(:,1),engMatCorr(:,2),P_shp);
                rpm = interp1(engMatCorr(:,1),engMatCorr(:,3),P_shp)*2800/2300;% hack it to make rpm more realistic for direct drive
            else
                % 107 hp at 16k
                engMatCorr(:,1) = engMatCorr(:,1).*rho/rho_crit;
                P_shp = engMatCorr(length(engMatCorr),1)*p_pct;
                SFC = interp1(engMatCorr(:,1),engMatCorr(:,2),P_shp);
                rpm = interp1(engMatCorr(:,1),engMatCorr(:,3),P_shp)*2800/2300;%hack it to make rpm more realistic for direct drive
            end
            prop_dia_est = 69/12;
            J = obj.TAS/(rpm/60*prop_dia_est);
            % current data has minimum J=0.1479, maximum J=2.0662
            if J>=0.1479 && J<2.0662
                etaP = interp1(obj.etaP_envelope(:,1),obj.etaP_envelope(:,2),J)*0.82/0.86;% efficiency hit for testing
                P_thp = etaP*P_shp;
                T = P_thp*550/obj.TAS;
            elseif J<0.1479
                etaP_jmin = interp1(obj.etaP_envelope(:,1),obj.etaP_envelope(:,2),0.1479)*0.82/0.86;
                P_thp_jmin = etaP_jmin*P_shp;
                TAS_jmin = 0.1479*(rpm/60*prop_dia_est);
                T = P_thp_jmin*550/TAS_jmin;
                P_thp = T*obj.TAS*550;
            else
                disp('J is too high')
            end
            FF = SFC*P_shp/3600;%lb/s
        end        


        %% Methods for Mission Simulation

        function [CL] = steadyLevelCL(obj)

            % Function solves for the lift coefficient in steady level flight

            % obj.W [lbs]
            % obj.rho [slugs/ft^3]
            % obj.S [ft^2]
            % obj.TAS [ft/s]

            % Density from standard atmosphere
            [rho, ~, ~] = stdAtmosphere_imperial(obj.y, obj.deltaT);
        
            % Solve for CL
            CL = obj.W / (0.5 * rho * obj.S * obj.TAS^2);
        
        end

        function [] = setDragPolar(obj, path)
            % Function sets the drag polar for the aircraft object
            % path: path to the drag polar spreadsheet (assumes .xlsx first column is CD, second column is CL)
            obj.dragPolar = readmatrix(path);

        end

        function [] = setEngine(obj, path)
            % Function sets the engine data for the aircraft object
            % path: path to the engine data spreadsheet (assumes .xlsx first column is power, second column is SFC, third column is RPM)
            engineData = table2array(load(path).engineData);
            obj.engMatSL = engineData;

        end

        function [CD] = cdFromDragPolarSpreadsheet(obj, CL)
            % Function returns the drag coefficient for a given lift coefficient
            % CL: lift coefficient
            % obj.dragPolar: drag polar data

            % Check if the drag polar data is loaded
            if isempty(obj.dragPolar)
                error('Drag polar data not loaded. Use setDragPolar() to load the data.');
            end

            % Find the drag coefficient for the given lift coefficient
            CD = interp1(obj.dragPolar(:,2), obj.dragPolar(:,1), CL);

        end

        function [SFC, shaftPower, flowPower, powerAvail, powerUsed] = getSFC(obj, powerRequired)
            % Function returns the specific fuel consumption for a given power setting
            % powerRequired: power from drag [lb-ft/s]
            % obj.engMatSL: engine data

            % Returns:
            % SFC: specific fuel consumption [lb/hp/hr]
            % shaftPower: shaft power [hp]
            % flowPower: power from fuel flow [lb-ft/s]

            % Propeller efficiency
            power = missionConversions(powerRequired / obj.eta_p, "lb_ft_sTohp");
            % Now power = shaft power

            % Returns:
            % SFC: specific fuel consumption [lb/hp/hr]

            % Check if the engine data is loaded
            if isempty(obj.engMatSL)
                error('Engine data not loaded. Use setEngine() to load the data.');
            end

            % Max power adjustment (came from mario's engine tool)
            if obj.y > obj.crit_alt

                % Difference between current altitude and critical altitude
                % I'm thinking this should be replaced with a pressure difference
                difference = obj.y - obj.crit_alt;
                % Density from standard atmosphere
                [rho, ~, ~] = stdAtmosphere_imperial(difference, 0);
                % Find ratio of current density to sea level density
                ratio = rho / 0.002377;
                % Adjust power
                powerRatio = 1.132 * ratio - 0.132;

            else

                powerRatio = 1;

            end

            if obj.y > obj.crit_alt
                if power > obj.engMatSL(end, 1) * powerRatio
                    error('Power setting exceeds maximum engine power.');
                end
            elseif power > obj.engMatSL(end, 1)
                error('Power setting exceeds maximum engine power.');
            end

            % Find the specific fuel consumption for the given power setting
            SFC = interp1(obj.engMatSL(:,1), obj.engMatSL(:,2), power);

            % Set shaft power
            shaftPower = power;

            % Set power used
            powerUsed = shaftPower;

            % Set power available
            powerAvail = max(obj.engMatSL(:,1)) * powerRatio;

            % Set flow power
            flowPower = missionConversions(power, "hpTolb_ft_s");

        end

        function [force] = forceFromCoefficient(obj, coeffVal)
            % Function calculates the force from a coefficient value
            % coeffVal: coefficient value
            % obj.rho: air density
            % obj.S: wing area
            % obj.TAS: true airspeed

            % Returns:
            % force: force [lbs]

            % Calculate dynamic pressure
            q = 0.5 * obj.rho * obj.TAS^2;

            % Calculate force
            force = coeffVal * q * obj.S;

        end

        function [] = setVelocsByTailAndCross(obj)
            % Function sets the x and y velocities based on the tailwind and crosswind
            % obj.TAS: true airspeed
            % obj.tailwind: tailwind
            % obj.crosswind: crosswind

            % Sets:
            % obj.Vx: x velocity [ft/s]

            % Convert crosswind and tailwind to ft/s
            crosswindLoc = missionConversions(obj.crosswind, "ktToft_s");
            tailwindLoc = missionConversions(obj.tailwind, "ktToft_s");
            
            % angle plane flies relative to ground track
            alpha = asin(crosswindLoc/obj.TAS);

            % x velocity
            obj.Vx = obj.TAS*cos(alpha) + tailwindLoc;


        end

        function [CL_desired] = getPercentRangeCL(obj, percentRange)
            % Function calculates the lift coefficient for a given percent of the range
            % and the current drag polar and state. Always returns the smaller (faster)
            % lift coefficient of the two possible values. Will store the CL for this
            % percent range in the object for future use.

            % percentRange: percent of the range

            % Check if the CL for this percent range has already been calculated
            if ~isempty(obj.percentRange)
                for i = 1:length(obj.percentRange)
                    if obj.percentRange(i,1) == percentRange
                        CL_desired = obj.percentRange(i,2);
                        return
                    end
                end
            end

            L_D = obj.dragPolar(:,2)./obj.dragPolar(:,1);
            
            [L_D_max, indMax] = max(L_D);

            % Get L/D for lower CL side of max L/D
            L_D_lower = L_D(1:indMax);

            % Get CL for lower CL side of max L/D
            CL_lower = obj.dragPolar(1:indMax,2);

            L_D_desired = percentRange * L_D_max / 100;

            % Find CL for desired L/D
            CL_desired = interp1(L_D_lower, CL_lower, L_D_desired);

            % Store CL for this percent range
            if isempty(obj.percentRange)
                obj.percentRange = [percentRange, CL_desired];
            else
                obj.percentRange = [obj.percentRange; percentRange, CL_desired];
            end

        end

        function [TAS] = getTAS_SLF(obj)
            % Function calculates the true airspeed for the aircraft in straight and level flight
            % obj.W: weight
            % obj.rho: air density
            % obj.S: wing area
            % obj.CL: lift coefficient

            % Returns:
            % TAS: true airspeed [ft/s]

            TAS = sqrt(2 * obj.W / (obj.rho * obj.S * obj.CL));

        end

        function [rho] = getRho(obj)
            % Function calculates the air density to maintain steady
            % level flight

            % obj.W: weight
            % obj.S: wing area
            % obj.CL: lift coefficient
            % obj.TAS: true airspeed

            % Returns:
            % rho: air density [slug/ft^3]

            rho = 2 * obj.W / (obj.S * obj.TAS^2 * obj.CL);

        end
    end
end