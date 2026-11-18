%% scissor_kinematics.m — 2-stage scissor lift: height & slider force
% Geometry from hardware/mechanical/assembly/scissor_lift_assembly.stl
L      = 48;      % arm length, pin-to-pin [mm]
nStage = 2;       % number of scissor stages
offset = 21.5;    % base below bottom pin (10.5) + platform above top pin (11.0) [mm]
thMin  = 25;      % [deg] slider at slot end
thMax  = 65;      % [deg] slider at slot start

%% Symbolic relations
syms th W real
H  = nStage*L*sin(th);                 % pin-to-pin height
s  = L*cos(th);                        % horizontal pin span (slider position)
dHds = simplify(diff(H,th)/diff(s,th)); % = -2*cot(th)
F  = simplify(-W*dHds);                % slider force for load W (virtual work)
disp('dH/ds ='); disp(dHds)
disp('F ='); disp(F)

%% Numeric curves
thv   = linspace(thMin,thMax,200);
Htot  = nStage*L*sind(thv) + offset;
ratio = 2*cotd(thv);                   % F/W

fprintf('Height range: %.1f -> %.1f mm\n', Htot(1), Htot(end));
fprintf('F/W range   : %.2f -> %.2f\n', ratio(1), ratio(end));

figure; plot(thv, Htot, 'LineWidth', 2); grid on
xlabel('Arm angle \theta (deg)'); ylabel('Overall height (mm)');
title('Overall height vs. arm angle');

figure; plot(Htot, ratio, 'LineWidth', 2); grid on
xlabel('Overall height (mm)'); ylabel('F / W');
title('Required slider force vs. height (frictionless)');

T = table(thv(:), Htot(:), ratio(:), 'VariableNames', {'theta_deg','height_mm','F_over_W'});
here = fileparts(mfilename('fullpath'));
writetable(T, fullfile(here, 'scissor_kinematics_table.csv'));
