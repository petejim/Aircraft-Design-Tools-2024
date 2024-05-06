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

        % Sea level engine matrix
        engMatSL

        % critical altitude
        crit_alt

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
        % x-component of wind [ft/s]
        Wx
        % y-component of wind [ft/s]
        Wy
        % crosswind component [ft/s]
        Wc
        % True airspeed
        TAS
        % prop efficiency envelope
        etaP_envelope
        % prop diameter [ft]
        D_prop
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

            % W
            obj.W = WTO;

            % load engine matrix SL
            engMatSL_table = load("CD135_SL.mat");
            obj.engMatSL = table2array(engMatSL_table.ans);
            
            % load propeller data
            % for now, propeller data comes from piper arrow
            envelope = load("etaP_envelope.mat");
            obj.etaP_envelope = envelope.eta_envelope;
            
            % prop diameter
            obj.D_prop = 6;%ft

            % critical alt
            obj.crit_alt = 6000;

            % for now zero out position, velocity, acceleration, AoA, etc
            obj.x = 0;
            obj.y = 0;
            obj.Vx = 0;
            obj.Vy = 0;
            obj.Ax = 0;
            obj.Ay = 0;
            obj.AoA = 0;
            obj.Crr = 0;
            

        end
        % Standard getters and setters-------------------------------
        function obj = set.W(obj,W)
            obj.W = W;
        end
        function obj = set.Crr(obj,CRR)
            obj.Crr = CRR;
        end
        function obj = set.x(obj,x)
            obj.x=x;
        end
        function obj = set.y(obj,y)
            obj.y=y;
        end
        function obj = set.Vx(obj,Vx)
            obj.Vx=Vx;
        end
        function obj = set.Vy(obj,Vy)
            obj.Vy=Vy;
        end
        function obj = set.Ax(obj,Ax)
            obj.Ax=Ax;
        end
        function obj = set.Ay(obj,Ay)
            obj.Ay=Ay;
        end
        function obj = set.AoA(obj,AoA)
            obj.AoA = AoA;
        end
        function obj = set.deltaT(obj,deltaT)
            obj.deltaT = deltaT;
        end
        function obj = set.Wx(obj,Wx)
            obj.Wx = Wx;
        end
        function obj = set.Wy(obj,Wy)
            obj.Wy = Wy;
        end
        function obj = set.Wc(obj,Wc)
            obj.Wc = Wc;
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

    end

end