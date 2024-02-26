function [Cd0] = interferenceDrag(Cd0fn, nNac, tratio, c, nc, S, S_ref)

%==========================================================================
% INPUTS
% Cd0fn - [Cd0 of Fuselage, Cd0 of Nacelle]
% nNac - number of nacelles
% tratio - [Thickness ratio of Horizontal, Thickness Ratio of Vertical]
% c - [Chord of Horizontal, Chord of Vertical]
% nc - [Number of Corners Horizontal, Number of Corner Vertical]
% S - [Reference Area of Horizontal, Reference Area of Vertical]
%=======================================================================

Cdfuse = 0.05*Cd0fn(1);

CdNac = 0.05*Cd0fn(2)*nNac;

Cdhs = nc(1)*(0.8*tratio(1)^3 - 0.0005)*(c(1)^2/S_ref);

Cdvs = nc(2)*(0.8*tratio(2)^3 - 0.0005)*(c(2)^2/S_ref);

Cd0 = Cdfuse+CdNac+Cdhs+Cdvs;