function [W_toval, W_eval, W_fval] = carpetPlotFunction(carpetscale,LDval,SFCval,EWFval,eta,LDmin,LDmax,SFCmin,SFCmax,EWFmin,EWFmax,W_pl,R)
% Generates carpet plots of LoD and BSFC, LoD and EWF, and BSFC and EWF vs.
% MTOW using Breguet Range Equation

% Define variables
LD = linspace(LDmin,LDmax,11);
SFC = linspace(SFCmin,SFCmax,11);
EWF = linspace(EWFmin,EWFmax,11);

W_to_i = 10000; % takeoff weight initial guess, in lbs

[W_toval, W_eval, W_fval] = sizing1(LDval, SFCval, EWFval, W_pl, R, eta);

% for (i = 1:length(LD))
%     for j = 1:length(SFC)
%         for k = 1:length(EWF)
%             [W_to(i,j,k), W_e(i,j,k), W_f(i,j,k)] = sizing1(LD(i), SFC(j), EWF(k), W_pl, R, eta);
%         end
%     end
% end

%% Figure 1: L/D & SFC

for (i = 1:length(LD))
    for j = 1:length(SFC)
         [W_to(i,j,:), W_e(i,j,:), W_f(i,j,:)] = sizing1(LD(i), SFC(j), EWFval, W_pl, R, eta);
    end
end

[X, Y] = meshgrid(LD, SFC);
offset = LD(6) * SFC(6);
Z = reshape(W_to(:,:,1), [length(LD), length(SFC)]);
Z = Z';
carpet(X, Y, Z, offset, 0, 'r', 'b', 'LineWidth', 2);
stepSize = 2;
carpetlabel(X(1:stepSize:end,:), Y(1:stepSize:end,:), Z(1:stepSize:end,:), offset, 0, -2, 2, -0.5, 0, 'FontSize', 10);
legend('SFC', 'L/D', 'Location', 'northeast');

ylim([0 carpetscale]);
set(gca, 'Box', 'on', 'LineWidth', 2, 'Color', 'none', 'XColor', 'black', 'YColor', 'black');
ylabel('Maximum Takeoff Weight');
grid minor;
set(gcf, 'color', 'w');
set(gca, 'FontName', 'Calibri');
set(gca, 'FontSize', 12);
set(gcf, 'Position', [0, 1000, 500, 370]); 
text(mean(X(:)) + offset/2, min(Y(:)), ['Empty Weight Fraction: ', num2str(EWFval)], ...
    'FontSize', 16, 'FontName', 'Calibri', 'HorizontalAlignment', 'center');

%% Figure 2: L/D & EWF

for (i = 1:length(LD))
    for j = 1:length(EWF)
         [W_to(i,:,j), W_e(i,:,j), W_f(i,:,j)] = sizing1(LD(i), SFCval, EWF(j), W_pl, R, eta);
    end
end

[X,Y] = meshgrid(LD,EWF);
offset =  20;
Z = reshape(W_to(:,1,:),[length(LD),length(EWF)]);
Z = Z';
h_p = carpet(X,Y,Z,offset,0,'#0B6623','b','LineWidth',2);
%  % h = carpetlabel(X, Y, Z, offset, 0, -1, 1, 0, 0,'FontSize', 12);
% 
% carpettext(X,Y,Z, offset, 0, 0, "L/D", 1, 0);
% carpettext(X,Y,Z, offset, 0, 0, "EWF", 3, 1);
% xlim([23 34])

ylim([0 carpetscale]);
set(gca, 'Box', 'on', 'LineWidth', 2, 'Color', 'none', 'XColor', 'black', 'YColor', 'black');
ylabel('Maximum Takeoff Weight');
grid minor
set(gcf,'color','w');
set(gca,'FontName', 'Calibri');
set(gca,'FontSize', 12); 
set(gcf, 'Position', [470, 1000, 500, 370]); 
text(mean(X(:)) + offset/4, min(Y(:)), ['Specific Fuel Consumption: ', num2str(SFCval)], ...
    'FontSize', 16, 'FontName', 'Calibri', 'HorizontalAlignment', 'center');

%% Figure 3: SFC & EWF

for (i = 1:length(SFC))
    for j = 1:length(EWF)
         [W_to(:,i,j), W_e(:,i,j), W_f(:,i,j)] = sizing1(LDval, SFC(i), EWF(j), W_pl, R, eta);
    end
end

[X,Y] = meshgrid(SFC,EWF);
offset = SFC(6)*EWF(6);
Z = reshape(W_to(1,:,:),[length(SFC),length(EWF)]);
Z = Z';
h_p = carpet(X,Y,Z,offset,0,'#0B6623','r','LineWidth',2);
% 
% %h = carpetlabel(X, Y, Z, offset, 0, -1, 1, 0, 0,'FontSize', 12);
% 
% carpettext(X,Y,Z, offset, 0, 0, "SFC", 0, 0);
% carpettext(X,Y,Z, offset, 0, 0, "EWF", 0, 0);
% xlim([.31 .42])

ylim([0 carpetscale]);
set(gca, 'Box', 'on', 'LineWidth', 2, 'Color', 'none', 'XColor', 'black', 'YColor', 'black');
ylabel('Maximum Takeoff Weight');
grid minor
set(gcf,'color','w');
set(gca,'FontName', 'Calibri');
set(gca,'FontSize', 12); 
set(gcf, 'Position', [1000, 1000, 500, 370]); 
text(mean(X(:)) + offset/3, min(Y(:)), ['Lift to Drag Ratio: ', num2str(LDval)], ...
    'FontSize', 16, 'FontName', 'Calibri', 'HorizontalAlignment', 'center');


end

%% Sizing Function

function [W_to, W_e, W_f] = sizing1(LD, SFC, EWF, W_pl, R, eta)
W_to = 10000;
error = 10;

while (abs(error) >= 1)
    W_e = EWF .* W_to;
    W_f_1 = W_to - W_e - W_pl;
    W_f_2 = W_to-(W_to./(exp((R.*6076.12).*(SFC/550/3600)./(eta*LD))));
    error = W_f_1 - W_f_2;
    W_to = W_to - error;
end

W_f = W_to - W_pl - W_e;

end
