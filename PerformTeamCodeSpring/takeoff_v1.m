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


% construct airplane
plane = DC_AirplaneClass(WTO, S, AR, osw, CD0, k, eta_p,dCL_dAoA,alpha0);

% runway conditions
% set CRR

% initial conditions