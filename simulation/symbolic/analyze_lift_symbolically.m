function result = analyze_lift_symbolically(stroke_mm, cycle_s)
% ANALYZE_LIFT_SYMBOLICALLY Symbolic kinematics of the verified 2-stage lift.
% Requires MATLAB + Symbolic Math Toolbox; Simulink is not required.
% Run: result = analyze_lift_symbolically;          % 23 mm, 5 s
%      result = analyze_lift_symbolically(10, 3);   % 10 mm, 3 s
% Calculations: m, s, rad. Plot/table units: mm, s, deg.
if nargin<1,stroke_mm=23;end
if nargin<2,cycle_s=5;end
validateattributes(stroke_mm,{'numeric'},{'scalar','real','finite','positive','<=',23});
validateattributes(cycle_s,{'numeric'},{'scalar','real','finite','positive'});
folder=fileparts(mfilename('fullpath'));outdir=fullfile(folder,'Results');if ~isfolder(outdir),mkdir(outdir);end

%% 1. Verified geometry and coordinate definitions
% L is the distance between END PIVOT CENTRES, not the 59 mm arm outline.
% xA: fixed lower pivot. q: signed lower-joint displacement, -stroke <= q <= 0.
% d=d0+q: horizontal end-pivot separation. xB=xA+d: absolute slider-axis x.
% H: upper surface of the platform above the base underside.
% h0=10.5+11=21.5 mm includes the base-pivot and top-surface offsets.
par=struct('L_m',0.048,'d0_m',0.0435,'h0_m',0.0215,'xA_m',0.008,...
 'sliderAxisHeight_m',0.0105,'platformCenterX_m',0.0325,'platformCenterY_m',0.0225,...
 'stroke_m',stroke_mm/1000,'cycle_s',cycle_s);
assert(par.d0_m<par.L_m && par.d0_m-par.stroke_m>0);

%% 2. General symbolic input-output equations (independent of time profile)
L=sym('L','real');d0=sym('d0','real');h0=sym('h0','real');xA=sym('xA','real');
q=sym('q','real');qdot=sym('qdot','real');qddot=sym('qddot','real');t=sym('t','real');Htarget=sym('Htarget','real');
assumeAlso(L>0);assumeAlso(d0+q>0);assumeAlso(d0+q<L);
d=d0+q;
H=h0+2*sqrt(L^2-d^2);
xB=xA+d;
J=simplify(diff(H,q));                 % v_top = J(q)*v_slider
K=simplify(diff(H,q,2));               % curvature term for acceleration
vH=simplify(J*qdot);
aH=simplify(J*qddot+K*qdot^2);
theta=acos(d/L);
omega=simplify(diff(theta,q)*qdot);
alpha=simplify(diff(theta,q)*qddot+diff(theta,q,2)*qdot^2);
qInverse=sqrt(L^2-((Htarget-h0)/2)^2)-d0; % positive d branch
Hinitial=subs(H,q,0);
rise=simplify(H-Hinitial);
assert(isAlways(simplify(J+2*d/sqrt(L^2-d^2))==0));
assert(isAlways(simplify(K+2*L^2/(L^2-d^2)^(sym(3)/2))==0));

%% 3. Prescribed input profile: same cosine cycle as the Multibody model
S=sym('S','positive');T=sym('T','positive');
qTime=-S/2*(1-cos(2*pi*t/T));
vBTime=diff(qTime,t);
aBTime=diff(qTime,t,2);
HTime=subs(H,q,qTime);
vHTime=diff(HTime,t);
aHTime=diff(HTime,t,2);
thetaTime=subs(theta,q,qTime);
omegaTime=diff(thetaTime,t);
alphaTime=diff(thetaTime,t,2);
% Verify the independently differentiated time expression obeys the Jacobian.
assert(isAlways(simplify(vHTime-subs(J,q,qTime)*vBTime)==0));
assert(isAlways(simplify(aHTime-(subs(J,q,qTime)*aBTime+subs(K,q,qTime)*vBTime^2))==0));

%% 4. Exact rational parameter substitution and numeric functions
vars=[L d0 h0 xA S T];
values=[sym(48)/1000 sym(87)/2000 sym(43)/2000 sym(8)/1000 sym(stroke_mm,'r')/1000 sym(cycle_s,'r')];
num=@(expr)simplify(subs(expr,vars,values));
E=struct('sliderDisplacement',num(qTime),'sliderPosition',num(subs(xB,q,qTime)),...
 'sliderVelocity',num(vBTime),'sliderAcceleration',num(aBTime),...
 'platformHeight',num(HTime),'platformVelocity',num(vHTime),'platformAcceleration',num(aHTime),...
 'armAngle',num(thetaTime),'armAngularVelocity',num(omegaTime),'armAngularAcceleration',num(alphaTime));
names=fieldnames(E);F=struct;for i=1:numel(names),F.(names{i})=matlabFunction(E.(names{i}),'Vars',t);end
F.heightFromQ=matlabFunction(num(H),'Vars',q);F.jacobian=matlabFunction(num(J),'Vars',q);
time=linspace(0,cycle_s,2001)';
V=struct;for i=1:numel(names),z=double(F.(names{i})(time));if isscalar(z),z=repmat(z,size(time));end;V.(names{i})=z(:);end
height0=double(num(Hinitial));
trace=table(time,V.sliderDisplacement*1000,V.sliderPosition*1000,V.sliderVelocity*1000,V.sliderAcceleration*1000,...
 V.platformHeight*1000,(V.platformHeight-height0)*1000,V.platformVelocity*1000,V.platformAcceleration*1000,...
 rad2deg(V.armAngle),rad2deg(V.armAngularVelocity),...
 'VariableNames',{'Time_s','Slider_q_mm','Slider_x_mm','Slider_v_mm_s','Slider_a_mm_s2',...
 'Platform_height_mm','Platform_rise_mm','Platform_v_mm_s','Platform_a_mm_s2','Arm_angle_deg','Arm_omega_deg_s'});

%% 5. Main required graphs: slider and platform position and velocity
cIn=[0.10 0.36 0.66];cOut=[0.86 0.32 0.12];
f1=figure('Name','Lift position and velocity','Color','w','Position',[80 80 1400 920]);
tl=tiledlayout(f1,2,2,'TileSpacing','compact','Padding','compact');
title(tl,sprintf('Two-stage scissor lift | %.3g mm stroke | %.3g s cycle',stroke_mm,cycle_s));
nexttile;plot(time,trace.Slider_x_mm,'Color',cIn,'LineWidth',2);ylabel('Absolute slider x_B (mm)');title('INPUT: bottom slider position');styleTime();
nexttile;plot(time,trace.Platform_height_mm,'Color',cOut,'LineWidth',2);ylabel('Platform top height H (mm)');title('OUTPUT: top platform position');styleTime();
nexttile;plot(time,trace.Slider_v_mm_s,'Color',cIn,'LineWidth',2);yline(0,':');ylabel('Slider velocity dx_B/dt (mm/s)');title('INPUT: signed horizontal velocity');styleTime();
nexttile;plot(time,trace.Platform_v_mm_s,'Color',cOut,'LineWidth',2);yline(0,':');ylabel('Platform velocity dH/dt (mm/s)');title('OUTPUT: signed vertical velocity');styleTime();
exportgraphics(f1,fullfile(outdir,'01_Position_and_Velocity.png'),'Resolution',160);savefig(f1,fullfile(outdir,'01_Position_and_Velocity.fig'));

%% 6. Input-output relationship: geometry and changing velocity ratio
inward=linspace(0,par.stroke_m,501)';height=F.heightFromQ(-inward);gain=-F.jacobian(-inward);
f2=figure('Name','Lift input-output relation','Color','w','Position',[110 110 1400 920]);
tl=tiledlayout(f2,2,2,'TileSpacing','compact','Padding','compact');title(tl,'Nonlinear input-output relationship');
nexttile;plot(inward*1000,height*1000,'Color',cOut,'LineWidth',2);xlabel('Inward slider travel u = -q (mm)');ylabel('Platform height H (mm)');title('Position mapping');grid on;
nexttile;plot(inward*1000,(height-height0)*1000,'Color',cOut,'LineWidth',2);xlabel('Inward slider travel u (mm)');ylabel('Platform rise (mm)');title('Output displacement versus input displacement');grid on;
nexttile;plot(inward*1000,gain,'Color',[0.35 0.25 0.65],'LineWidth',2);xlabel('Inward slider travel u (mm)');ylabel('dH/du (mm/mm)');title('Velocity gain: v_{top} = (dH/du) v_{inward}');grid on;
nexttile;up=time<=cycle_s/2;down=time>=cycle_s/2;plot(trace.Slider_v_mm_s(up),trace.Platform_v_mm_s(up),'Color',cIn,'LineWidth',2);hold on;plot(trace.Slider_v_mm_s(down),trace.Platform_v_mm_s(down),'Color',cOut,'LineWidth',2);xline(0,':');yline(0,':');xlabel('Signed slider velocity (mm/s)');ylabel('Signed platform velocity (mm/s)');title('Velocity mapping also depends on position');legend('Raising','Lowering','Location','best');grid on;
exportgraphics(f2,fullfile(outdir,'02_Input_Output_Relationship.png'),'Resolution',160);savefig(f2,fullfile(outdir,'02_Input_Output_Relationship.fig'));

%% 7. Supplementary graphs useful for motion and actuator studies
f3=figure('Name','Lift acceleration and arm rotation','Color','w','Position',[140 140 1400 920]);
tl=tiledlayout(f3,2,2,'TileSpacing','compact','Padding','compact');title(tl,'Supplementary kinematics: acceleration and arm rotation');
nexttile;plot(time,trace.Slider_a_mm_s2,'Color',cIn,'LineWidth',2);yline(0,':');ylabel('Slider acceleration (mm/s^2)');title('Prescribed input acceleration');styleTime();
nexttile;plot(time,trace.Platform_a_mm_s2,'Color',cOut,'LineWidth',2);yline(0,':');ylabel('Platform acceleration (mm/s^2)');title('Output acceleration');styleTime();
nexttile;plot(time,trace.Arm_angle_deg,'Color',[0.2 0.5 0.3],'LineWidth',2);ylabel('Arm angle to horizontal (deg)');title('Scissor angle');styleTime();
nexttile;plot(time,trace.Arm_omega_deg_s,'Color',[0.35 0.25 0.65],'LineWidth',2);yline(0,':');ylabel('Arm angular velocity (deg/s)');title('Arm rotation rate');styleTime();
exportgraphics(f3,fullfile(outdir,'03_Acceleration_and_Arm_Angle.png'),'Resolution',160);savefig(f3,fullfile(outdir,'03_Acceleration_and_Arm_Angle.fig'));

%% 8. Checks, summary metrics, equations and reproducible outputs
residual=(V.platformHeight-par.h0_m).^2+4*(par.d0_m+V.sliderDisplacement).^2-4*par.L_m^2;
fd=gradient(V.platformHeight,time);idx=3:numel(time)-2;fdError=max(abs(fd(idx)-V.platformVelocity(idx)));
assert(max(abs(residual))<1e-12);assert(fdError<1e-4);
assert(max(abs(V.sliderVelocity([1 end])))<1e-10);assert(max(abs(V.platformHeight([1 end])-height0))<1e-10);
[tPeak,negativePeak]=fminbnd(@(tau)-double(F.platformVelocity(tau)),0,cycle_s/2);
summary=struct('stroke_mm',stroke_mm,'cycle_s',cycle_s,'slider_x_min_mm',min(trace.Slider_x_mm),...
 'slider_x_max_mm',max(trace.Slider_x_mm),'platform_height_min_mm',height0*1000,...
 'platform_height_max_mm',double(F.heightFromQ(-par.stroke_m))*1000,...
 'platform_rise_mm',(double(F.heightFromQ(-par.stroke_m))-height0)*1000,...
 'peak_slider_speed_mm_s',stroke_mm*pi/cycle_s,'peak_platform_speed_mm_s',-negativePeak*1000,...
 'peak_platform_speed_raising_time_s',tPeak,'initial_arm_angle_deg',trace.Arm_angle_deg(1),...
 'max_arm_angle_deg',max(trace.Arm_angle_deg),'initial_inward_velocity_gain',double(-F.jacobian(0)),...
 'final_inward_velocity_gain',double(-F.jacobian(-par.stroke_m)),...
 'geometric_residual_max_m2',max(abs(residual)),'velocity_finite_difference_error_m_s',fdError);
quarterTimes=(0:4)'*cycle_s/4;sample=trace(1:500:end,:);assert(max(abs(sample.Time_s-quarterTimes))<1e-12);
writetable(trace,fullfile(outdir,'Kinematic_data.csv'));writetable(sample,fullfile(outdir,'Quarter_cycle_values.csv'));
file=fopen(fullfile(outdir,'Summary.json'),'w');fwrite(file,jsonencode(summary,PrettyPrint=true));fclose(file);
general=struct('height',H,'sliderPosition',xB,'rise',rise,'jacobian',J,'curvature',K,'platformVelocity',vH,...
 'platformAcceleration',aH,'armAngle',theta,'armAngularVelocity',omega,'armAngularAcceleration',alpha,'inverseInput',qInverse);
file=fopen(fullfile(outdir,'Symbolic_equations.txt'),'w');fprintf(file,'SYMBOLIC SCISSOR-LIFT KINEMATICS\nSI units: m, s, rad. Positive square-root / raised configuration.\nL=0.048; d0=0.0435; h0=0.0215; xA=0.008.\nq is signed prismatic displacement; inward travel u=-q.\n\n');n=fieldnames(general);for i=1:numel(n),fprintf(file,'%s = %s\n\n',n{i},char(general.(n{i})));end
fprintf(file,'DEFAULT/SELECTED TIME PROFILE\n');for i=1:numel(names),fprintf(file,'%s(t) = %s\n\n',names{i},char(E.(names{i})));end;fclose(file);
result=struct('parameters',par,'generalSymbolic',general,'timeSymbolic',E,'data',trace,'samples',sample,'summary',summary);
save(fullfile(outdir,'Lift_symbolic_results.mat'),'result');
fprintf('\nSYMBOLIC ANALYSIS COMPLETED\n');disp(summary);disp(sample(:,{'Time_s','Slider_q_mm','Slider_x_mm','Slider_v_mm_s','Platform_height_mm','Platform_v_mm_s'}));
fprintf('Results saved to: %s\n',outdir);
 function styleTime
  xlabel('Time (s)');grid on;xlim([0 cycle_s]);xline(cycle_s/2,':','Peak height','LabelVerticalAlignment','bottom');
 end
end

