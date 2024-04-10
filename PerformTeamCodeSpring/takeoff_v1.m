% Takeoff v1 for AERO 445

% Define airplane parameters (later make this take them from file)
WTO = 9075;
S = 313;
AR = 27;
osw = 0.8;
CD0 = 0.016;
k = 0.0147;
eta_p = 0.8;
dCL_dAoA = 5;%make this less horseshit someday
alpha0 = 0;%same
groundAlpha = deg2rad(2);% set this to actual value
rotAlpha = deg2rad(10);% set this to actual value

% construct airplane
plane = DC_AirplaneClass(WTO, S, AR, osw, CD0, k, eta_p,dCL_dAoA,alpha0);

% runway conditions
% set CRR
CRR = 0.025; %  value given by roskam for concrete
plane.Crr = CRR;


% wind conditions
headwind = 0;
crosswind = 0;


% initial conditions
plane.x = 0;
plane.y = 1998;
plane.Vx = 0;
plane.Vy = 0;
plane.Ax = 0;
plane.Ay = 0;
plane.AoA = groundAlpha;
plane.deltaT = 0;
plane.findTAS




