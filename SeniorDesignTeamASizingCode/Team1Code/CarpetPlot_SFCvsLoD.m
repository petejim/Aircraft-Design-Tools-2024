%% AERO 443 Sizing Analysis
clc;
clear;
close all;

addpath CarpetPlotFuncs\


%% Weight Calculation
%   Requirements
%Range that aircaft must hit
RangeMin = 19900; % kn
%Weight of payload
Wpl = 645; % lbs

% Propeller efficiency
eta = 0.8;

%ranges of inputs
%SFC from 0.340 to 0.380 
%EWF from 0.210 to 0.270
%LoD from 20 to 27 ??
%Distance [18500,19200,19900, 20000, 25000] %mario
%payload

LoD = [21, 22, 23, 24, 25, 26, 27];
EWF = [0.22,0.23,0.24,0.25, 0.26, 0.27, 0.28, 0.29, 0.3]; 
BSFC = [0.38, 0.37, 0.36, 0.35, 0.34]; %lb/hp-hr
MTOW = [];

x1 = BSFC;
x2 = LoD;

for i = 1: length(BSFC)
    for j = 1: length(LoD)
        
        Result = findWeights(Wpl,EWF(5),eta,BSFC(i),LoD(j),RangeMin);

        MTOW(i,j) = Result(3);
        
    end
end

f = MTOW;
%% Reference Lines


LoD1 = [21, 22, 23, 24, 25, 26, 27];
EWF1 = [0.26]; 
BSFC1 = [0.345]; %lb/hp-hr
MTOW1 = [];

x11 = BSFC1;
x21 = LoD1;

for i = 1: length(BSFC1)
    for j = 1: length(LoD1)
        
        Result = findWeights(Wpl,EWF1(i),eta,BSFC1,LoD1(j),RangeMin);

        MTOW1(i,j) = Result(3);
        
    end
end

f1 = MTOW1;
%% Carpet Plot Script

off = 0.007;

%Number of lines for independant variable 1
n = 6;

%Number of lines for independant variable 2
m = 6;

%Constants
e = 0.85;
rho = 0.002376892351915; %slug/ft^3
v = 120; %knots
WS = 0.83; %Wing Loading

%Plot offsets for the carpet plot


%Independant Variable Arrays
%{
x1 = [21,22,23,24,25]; %L/D
x2 = [0.300,0.315,0.330,0.345,0.360]; %PSFC

f = [6392, 5467, 4802, 4301, 3910;
    7765, 6446, 5542, 4885, 4386;
    9746, 7765, 6495, 5612, 4964;
    12850,9637,7765,6540,5678;
    18400,12497,9539,7765,6583
    ]';
%}

%{
L/D vs EWF
x1 = [23,24,25,26,27]; %L/D
x2 = [0.22,0.23,0.24,0.25,0.26,0.27]; %EWF

f = [7807,6577,5709,5064,4567;
    8882,7324,6263,5496,4915;
    10301,8262,6937,6007,5320;
    12259,9476,7773,6624,5798;
    15135,11107,8838,7383,6371;
    19775,13418,10241,8337,7069
    ]';
%}



%will need to resize plots each time

figure('Name','Carpet Plot', 'NumberTitle', 'off')
 hold on 

 % DC: Line at 13000 pounds for MTOW
 plot([0 1], [13000, 13000], '--k')
 plot([0 1], [20000, 20000], 'k', 'linewidth', 0.7)
 plot([0 1], [4000, 4000], 'k', 'linewidth', 0.7)
carpet(x1, x2, f', off, 0, 'b', 'r', 'linewidth', 1.5);
carpet(x11, x21, f1', off, 0, '--b', '--r','linewidth',1.5);
carpetlabel(x1, x2, f', off, 0, 0, 1);
carpetlabel(x1, x2, f', off, 0, 1, 0);
carpettext(x1, x2, f', off, 23, 0.36, 'L/D',-0.1,2);
carpettext(x1, x2, f', off, 21, 0.33, 'BSFC',-0.5,3);
ax = gca; % axes handle
ax.YAxis.Exponent = 0;
set(gca,'fontname','treubuchet', 'fontsize', 14)
ylabel('Maximum Take Off Weight (lbs)')
set(gcf,'color','w');
box on
grid on
axis([ 0.485 0.575 4000 20000])
x0=100;
y0=100;
width= 900;
height= 480;
set(gcf, 'position',[x0,y0,width,height])
f = gcf;
exportgraphics(f,"test image2.png")





%% Solver Function

function [Result] = findWeights(Wpl,EWF,eta,BSFC,LoD,R)

% All weights in lbf
% Wpl = weight of payload ( include reserve fuel)
% EWF = empty weight fraction
% eta = propeller efficiency
% BSFC = brake specific fuel consumption (must be in lbm / hr / hp)
% LoD = lift to drag ratio
% R = range (in nautical miles)

% Result = vector of resulting weight values in lbs 
% [empty weight,fuel weight,takeoff weight]


% Empty weight, fuel weight, payload weight should equal takeoff
WeightSumsEq = @(We,Wf,WTO) We + Wf + Wpl - WTO;

% Weight fraction equation
EWF_Eq = @(We,WTO) EWF - We/WTO;

% Breguet range equation
Breguet_Eq = @(Wf,WTO) 1980000 / 6076.11549 * eta / BSFC * LoD * ...
    log(WTO/(WTO - Wf)) - R;

% Puts those three eqs into vector for fsolve
fullEquation = @(xVec) [WeightSumsEq(xVec(1),xVec(2),xVec(3));...
    EWF_Eq(xVec(1),xVec(3));Breguet_Eq(xVec(2),xVec(3))];

% xVec(1) = empty weight
% xVec(2) = weight of fuel
% xVec(3) = take off weight
Result = fsolve(fullEquation,[2000,9000,13000]);

end


