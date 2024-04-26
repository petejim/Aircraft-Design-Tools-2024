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
alpha0 = -deg2rad(4);%same
groundAlpha = deg2rad(0);% set this to actual value
rotAlpha = deg2rad(10);% set this to actual value

% construct airplane
plane = DC_AirplaneClass(WTO, S, AR, osw, CD0, k, eta_p,dCL_dAoA,alpha0);

% runway conditions
% set CRR
CRR = 0.025; %  value given by roskam for concrete
plane.Crr = CRR;


% wind conditions
headwind = 1;
crosswind = 0;
plane.Wx = -headwind;
plane.Wy = 0;
plane.Wc = crosswind;

% initial conditions
plane.x = 0;
plane.y = 1998;
plane.Vx = 0;
plane.Vy = 0;
plane.Ax = 0;
plane.Ay = 0;
plane.AoA = groundAlpha;
plane.deltaT = 0;
plane=plane.calcTAS();


% try some CD0s and CRRs
CRRlist = [0.02, 0.025, 0.03, 0.035,0.04];
CD0list = [0.016,0.02,0.025,0.03];
fn = 1;
for i = 1:length(CRRlist)
    for j = 1:length(CD0list)
        plane.Crr=CRRlist(i);
        plane.CD0=CD0list(j);
        [t,L,D,Fr,T,Fx,Ax,Vx,x,TAS,rotL,rotCL] = takeoff_1(plane,rotAlpha);
        TOG(i,j) = x(length(x));
        TOT(i,j) = t(length(t));
        figure(fn)
        plot(t,T)
        hold on
        plot(t,D)
        plot(t,Fr)
        plot(t,Vx)
        ttltxt = "CD0 = "+num2str(CD0list(j))+" Crr = " + num2str(CRRlist(i));
        title(ttltxt)
        xlabel('time')
        legend('Thrust','Drag','rolling resistance')
        fn = fn+1;
    end
end




%% plot
fn = fn+1;
figure(fn)
contour(CD0list,CRRlist,TOG,'ShowText','on')
xlabel('CD0')
ylabel('CRR')
fn = fn+1;
figure(fn)
contour(CD0list,CRRlist,TOT,'ShowText','on')

%% functions
function [t,L,D,Fr,T,Fx,Ax,Vx,x,TAS,rotL,rotCL] = takeoff_1(plane,rotAlpha)
tstep = 0.1;% seconds
i = 1;
t(i) = 0;
[L(i),~]=plane.getL();
[D(i),~] = plane.getDrag();
Fr(i) = plane.getRollFriction();
[~,T(i)] = plane.getPowerThrust(1);
Fx(i) = T(i)-Fr(i)-D(i);
Ax(i) = plane.Ax;
Vx(i) = plane.Vx;
x(i) = plane.x;
TAS(i) = plane.TAS;
[rotL(i),rotCL(i)] = plane.getLFromAoA(rotAlpha);
while L(i)<plane.W
    i = i+1;
    [D(i),~] = plane.getDrag();
    Fr(i) = plane.getRollFriction();
    [~, ~, ~, FF(i), T(i)] = plane.engine_prop(1);

    FF(i) = FF(i)*2;% 2 engines
    T(i) = T(i)*2;

    Fx(i) = T(i)-Fr(i)-D(i);
    plane.Ax = Fx(i)/(plane.W/32.17);
    Ax(i) = plane.Ax;% Clean this up to store either in object or here, not both
    plane.Vx = plane.Vx+plane.Ax*tstep;
    Vx(i) = plane.Vx;
    plane.x = plane.x+plane.Vx*tstep;
    x(i) = plane.x;
    plane=plane.calcTAS();
    TAS(i) = plane.TAS;
    [L(i),CL(i)]=plane.getL();
    [rotL(i),rotCL(i)] = plane.getLFromAoA(rotAlpha);
    if rotL(i)>plane.W
        plane.AoA=rotAlpha;
    end
    t(i) = t(i-1)+tstep;
    plane.W = plane.W-FF(i)*tstep;
end

end
