% Takeoff v1 for AERO 445


%% Voyager
% Define airplane parameters (later make this take them from file)
WTO = 9694;
S = 363;
AR = 33.7;
osw = 0.8;
CD0 = 0.040;
k = 0.0118;
eta_p = 0.8;
dCL_dAoA = 6;%make this less horseshit someday
alpha0 = -deg2rad(3.6664);% same
groundAlpha = deg2rad(0);% set this to actual value
rotAlpha = deg2rad(8);% set this to actual value

% construct airplane
voyager = DC_AirplaneClass(WTO, S, AR, osw, CD0, k, eta_p,dCL_dAoA,alpha0);

% runway conditions
% set CRR
CRR = 0.037; %  value given by roskam for concrete
voyager.Crr = CRR;



% wind conditions
headwind = 0;
crosswind = 0;
voyager.Wx = -headwind;
voyager.Wy = 0;
voyager.Wc = crosswind;

% initial conditions
voyager.x = 0;
voyager.y = 2311;
voyager.Vx = 0;
voyager.Vy = 0;
voyager.Ax = 0;
voyager.Ay = 0;
voyager.AoA = groundAlpha;
voyager.deltaT = 0;
voyager=voyager.calcTAS();


% calculate roskam takeoff for reference
TOP23 = (voyager.W_TO/voyager.S)*(voyager.W_TO/270)/(0.942829*1.4);
STOG = 4.9*TOP23+0.009*TOP23^2;
STO = 1.66*STOG

[t,L,D,Fr,T,Fx,Ax,Vx,x,TAS,rotL,rotCL,W,Vy,y] = takeoff_1(voyager,rotAlpha);
TOD= x(length(x))
TOT= t(length(t))
figure(1)
plot(t,T)
hold on
plot(t,D)
plot(t(1:length(Fr)),Fr)
plot(t,Vx)
plot(t,y)
plot(t,(atand(Vy./Vx)))

P_thr = T.*TAS/550;
etaP = P_thr/(130+110);

xlabel('time')
legend('Thrust','Drag','rolling resistance','x velocity','alt','gamma')

figure(2)
subplot(3,1,1)
plot(x,Vx./1.68781,'LineWidth',1.5)
grid on;
xlabel('Distance [ft]', 'FontName', 'Calibri', 'FontSize', 14);
ylabel('X velocity [kts]', 'FontName', 'Calibri', 'FontSize', 14);
xlim([0, 15000]);
ylim([0, 100]);
title('Velocity', 'FontName', 'Calibri', 'FontSize', 14)

subplot(3,1,2)
plot(x(2:length(x)),y(2:length(y)),'LineWidth',1.5)
grid on;
xlabel('Distance [ft]', 'FontName', 'Calibri', 'FontSize', 14);
ylabel('Altitude [ft]', 'FontName', 'Calibri', 'FontSize', 14);
xlim([0, 15000]);
ylim([2250, 2450]);
title('Altitude', 'FontName', 'Calibri', 'FontSize', 14)

subplot(3,1,3)
plot(x(2:length(x)),T(2:length(T)),'LineWidth',1.5)
hold on
plot(x(2:length(x)),D(2:length(D)),'LineWidth',1.5)
plot(x(2:length(Fr)),Fr(2:length(Fr)),'LineWidth',1.5)
plot(x(2:length(x)),(D(2:length(D))+Fr(2:length(Fr))),'LineWidth',1.5)
grid on;
xlabel('Distance [ft]', 'FontName', 'Calibri', 'FontSize', 14);
ylabel('X Axis Forces [lbs]', 'FontName', 'Calibri', 'FontSize', 14);
xlim([0, 15000]);
ylim([0, 1500]);
legend('Thrust','Drag','Friction','Total resistance')
title('Forces', 'FontName', 'Calibri', 'FontSize', 14)


set(gcf, 'Color', 'white'); % Set background color of figure to white
set(gcf,'Position',[100,100,800,800])

figure(3)
plot(x,etaP)

% try some CD0s and CRRs
% CRRlist = [0.02, 0.025, 0.03, 0.035,0.04];
% CD0list = [0.016,0.02,0.025,0.03];
% fn = 1;
% for i = 1:length(CRRlist)
%     for j = 1:length(CD0list)
%         plane.Crr=CRRlist(i);
%         plane.CD0=CD0list(j);
%         [t,L,D,Fr,T,Fx,Ax,Vx,x,TAS,rotL,rotCL] = takeoff_1(plane,rotAlpha);
%         TOG(i,j) = x(length(x));
%         TOT(i,j) = t(length(t));
%         figure(fn)
%         plot(t,T)
%         hold on
%         plot(t,D)
%         plot(t,Fr)
%         plot(t,Vx)
%         ttltxt = "CD0 = "+num2str(CD0list(j))+" Crr = " + num2str(CRRlist(i));
%         title(ttltxt)
%         xlabel('time')
%         legend('Thrust','Drag','rolling resistance')
%         fn = fn+1;
%     end
% end




%% plot
% fn = fn+1;
% figure(fn)
% contour(CD0list,CRRlist,TOG,'ShowText','on')
% xlabel('CD0')
% ylabel('CRR')
% fn = fn+1;
% figure(fn)
% contour(CD0list,CRRlist,TOT,'ShowText','on')

%% functions
function [t,L,D,Fr,T,Fx,Ax,Vx,x,TAS,rotL,rotCL,W,Vy,y] = takeoff_1(plane,rotAlpha)
tstep = 0.1;% seconds
rotationTime = 2;%s
rotCondition = 0;
fieldElev = plane.y;

i = 1;
t(i) = 0;
[L(i),~]=plane.getL();
[D(i),~] = plane.getDrag();
Fr(i) = plane.getRollFriction();
[~,T(i)] = plane.engine_prop_voyager(1);
Fx(i) = T(i)-Fr(i)-D(i);
Ax(i) = plane.Ax;
Vx(i) = plane.Vx;
x(i) = plane.x;
TAS(i) = plane.TAS;
[rotL(i),rotCL(i)] = plane.getLFromAoA(rotAlpha);
W(i) = plane.W;
initAlpha = plane.AoA;
while rotCondition == 0
    i = i+1;
    [D(i),~] = plane.getDrag();
    Fr(i) = plane.getRollFriction();
    [~, ~, ~, FF(i), T(i)] = plane.engine_prop_voyager(1);

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
        rotCondition = 1;
        plane.AoA=rotAlpha;
    end
    t(i) = t(i-1)+tstep;
    plane.W = plane.W-FF(i)*tstep;
    W(i) = plane.W;
    Vy(i) = 0;
    y(i) = plane.y;
end
% rotation starting, rotate at fixed rate until either L=W or max angle
% reached
t_begin_rot = t(i);
while L(i)<plane.W
    if (t(i)-t_begin_rot)<rotationTime
        plane.AoA = (rotAlpha-initAlpha)*(t(i)-t_begin_rot)/rotationTime+initAlpha;
    end
    i = i+1;
    [D(i),~] = plane.getDrag();
    Fr(i) = plane.getRollFriction();
    [~, ~, ~, FF(i), T(i)] = plane.engine_prop_voyager(1);

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
    t(i) = t(i-1)+tstep;
    plane.W = plane.W-FF(i)*tstep;
    W(i) = plane.W;
    Vy(i) = 0;
    y(i) = plane.y;
end


% climb to 50 ft
while (plane.y-fieldElev)<50
    Fy = L(i)-plane.W;
    if Ax(i)<0
        % we can't climb this steeply
        func = @(AoA) plane.getLFromAoA(AoA)-plane.W;
        plane.AoA = fzero(@(AoA) func(AoA),plane.AoA);
        [L(i),CL(i)]=plane.getL();
        Fy = L(i)-plane.W;
    end
    i = i+1;
    plane.Ay = Fy/(plane.W/32.17);
    [D(i),~] = plane.getDrag();
    [~, ~, ~, FF(i), T(i)] = plane.engine_prop_voyager(1);
    FF(i) = FF(i)*2;% 2 engines
    T(i) = T(i)*2;
    Fx(i) = T(i)-D(i)-(plane.Vy/plane.Vx)*plane.W;%added approximate term to deal with energy going into climb
    plane.Ax = Fx(i)/(plane.W/32.17);
    Ax(i) = plane.Ax;
    plane.Vx = plane.Vx+plane.Ax*tstep;
    Vx(i) = plane.Vx;
    plane.x = plane.x+plane.Vx*tstep;
    x(i) = plane.x;
    plane.Vy = plane.Vy+plane.Ay*tstep;
    Vy(i) = plane.Vy;
    plane.y = plane.y+plane.Vy*tstep;
    y(i) = plane.y;
    plane=plane.calcTAS();
    TAS(i) = plane.TAS;
    [L(i),CL(i)]=plane.getL();
    t(i) = t(i-1)+tstep;
    plane.W = plane.W-FF(i)*tstep;
    W(i) = plane.W;
    Fr(i) = 0;

end



end