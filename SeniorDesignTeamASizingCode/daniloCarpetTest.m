%% Team A

close all; clear; clc;


%% Code

addpath CarpetPlotFuncsModded\


%% Varied for carpet

% Range of wing loadings

WS = linspace(25,50,6);

% Range of aspect ratios

AR = linspace(15,45,7);

%% Fixed mission parameters

segmts = 1;

rangeDes = 20000;

bregTypes = 1 + zeros(segmts,1);

% bregTypes(end) = 0;
% 
% bregTypes(1) = 1;

dists = rangeDes / segmts + zeros(segmts,1);

veloTAS = 90 + zeros(segmts,1);
% velocs = [100;100;100;90];

vWind = 15 + zeros(segmts,1);

alt = 0 + zeros(segmts,1);
% alt = [10000;12500;15000;15000];

SFCs = 0.36 + zeros(segmts,1);

wPayload = 600;

wRF = 100;

EWF = 0.24;

eta = 0.8;

osw = 0.9;

CD0 = 0.0270;

[X_WS,Y_AR] = meshgrid(WS,AR);

z = X_WS .* 0;

for i = 1:length(WS)

    for j = 1:length(AR)

        [Result] = weightFromSegments(bregTypes,dists,veloTAS,vWind,alt,SFCs,...
            wPayload,wRF,WS(i),EWF,eta,AR(j),osw,CD0);

        z(j,i) = Result(1);

    end
    
end

%%
carpetMod2(X_WS,Y_AR,z,0.1,0,"red","blue");

ylim([0,10000])


%% Functions

function h = carpetMod2(x1, x2, y, offset, nref, linspec1, linspec2, varargin)
%CARPET Plots a carpet plot with two independent and one dependent variable.
%   h = carpet(x1, x2, y, offset) generates a carpet plot with
%   independent variables x1 & x2 and dependent variable y.  The plot is
%   created using a cheater axis generated by the equation:
%
%   xcheat = x1 + x2 * offset.
%
%   x1 & x2 may be vectors, or they may be matrices as generated by
%   MESHGRID.  x1, x2, & y should be arranged such that they could be
%   plotted with SURF(x1,x2,y).
%
%   Handles to the resulting carpet plot curves are returned in h.
%
%   Setting nonzero nref will cause lines in the carpet plot to be skipped.
%   This can be used to create smooth curves in the carpet plot without
%   excess clutter.  Default nref = 0.  The same value of nref is applied
%   to both x1 and x2 directions.  Refined vectors can be created using
%   REFVEC.
%
%   linspec1 specifies the line style for the x1=constant lines.  If it is
%   not specified, it defaults to 'k'.
%
%   linspec2 specifies the line style for the x2=constant lines.  If it is
%   not specified, it defaults to linspec1.
%
%   Any additional arguments passed to CARPET are passed to the plot
%   command.
%
%   See also CARPETCONVERT, CARPETCONTOURCONVERT, REFVEC.

%   Rob McDonald 
%   ramcdona@calpoly.edu  
%   19 February 2013 v. 1.0

if( nargin < 5 )
  nref = 0;
end

% Handle default line styles.
if( nargin < 6 )
  linspec1 = 'k';
end

if( nargin < 7 )
  linspec2 = linspec1;
end

% If input is not matrix similar to meshgrid, make it so.
if( isvector(x1) && isvector(x2) )
  [X1,X2] = meshgrid( x1, x2 );
else
  X1 = x1;
  X2 = x2;
end

% Calculate the cheater axis.
Xcheat = X1 + X2 * offset;

% Plot the carpet plot lines.
figure();
hold on
plot(Xcheat(1:nref+1:end,:)', y(1:nref+1:end,:)',...
    varargin{:}, Color=linspec1)
plot(Xcheat(:,1:nref+1:end), y(:,1:nref+1:end), ...
    varargin{:}, Color=linspec2);
% Hide the X-axis and turn off the box.
ca = gca;
set(ca,'XTick',[])
box off
set(ca,'XColor',[1,1,1])
end



