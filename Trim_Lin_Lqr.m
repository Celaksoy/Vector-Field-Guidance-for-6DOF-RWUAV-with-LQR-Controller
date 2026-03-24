%% Trim, Linearization, LQR Design

app = HelicopterParameterEstimation;
uiwait(app.HelicopterParameterEstimationUIFigure);
disp('Parametreler alındı, devam ediliyor...');
fprintf("\n");

Vrefs = [15 20 25];  
alt = -1000;

i = 1;

for V_i = Vrefs

    % Trim

    model = 'trim_model';
    
    opspec = operspec(model);
    
    % State (1) - phi theta psi
    opspec.States(1).x = [0;0;0];
    opspec.States(1).Known = [false;false;false];
    opspec.States(1).SteadyState = [true;true;true];
    
    % State (2) - p,q,r
    opspec.States(2).x = [0;0;0];
    opspec.States(2).Known = [true;true;true];
    opspec.States(2).SteadyState = [true;true;true];
    
    % State (3) - ub,vb,wb
    opspec.States(3).x = [V_i;0;0];
    opspec.States(3).Known = [true;false;false];
    opspec.States(3).SteadyState = [true;true;true];
    
    % State (4) - xe,ye,ze
    opspec.States(4).x = [0; 0; alt];
    opspec.States(4).Known = [false;false;true];
    opspec.States(4).SteadyState = [false;false;true];
    
    % Input (1) - trim_icin_deneme/Col
    opspec.Inputs(1).u = 0.12; 
    opspec.Inputs(1).Min = 0.08;
    opspec.Inputs(1).Max = 0.15;
    
    % Input (2) - trim_icin_deneme/CycLa
    opspec.Inputs(2).u = 0; 
    opspec.Inputs(2).Min = -0.25;
    opspec.Inputs(2).Max = 0.25;
    
    % Input (3) - trim_icin_deneme/CycLo
    opspec.Inputs(3).u = 0.01; 
    opspec.Inputs(3).Min = -0.25;
    opspec.Inputs(3).Max = 0.25;
    
    % Input (4) - trim_icin_deneme/Tail
    opspec.Inputs(4).u = 0.05; 
    opspec.Inputs(4).Min = 0;
    opspec.Inputs(4).Max = 0.5;
    
    opt = findopOptions('DisplayReport','off');
    
    [op,opreport] = findop(model,opspec,opt);
    
    % Linearization

    io = getlinio(model);
    linsys = linearize(model,io,op);
    
    %LQR Design

    LQR.Q = diag([0.1 0.1 0.01 20 20 40 15 10 30 0]);
    
    LQR.R = diag([.02 .02 .02 .02]);
    
    LQR.A = linsys.A;
    LQR.B = linsys.B;
    
    K = lqr(LQR.A,LQR.B,LQR.Q,LQR.R);
    
    LQR.K_lqr(:,:,i) = K;

    disp(num2str(Vrefs(i)) + " m/s ileri hız değeri için K_LQR hesaplandı.");
   
    i = i+1;

end

fprintf("\n");
disp("Tüm trim noktaları için K_LQR hesaplandı." + string(datetime('now')));
fprintf("\n");

%% PLOTS

disp('Çıktılar basılıyor...');

% Perpendicular
wp = [0 0; 1000 1000; 2000 0; 1000 -1000; 0 -100];

% Zigzag
%wp = [0 0; 1000 600; 2000 -600; 3000 600; 4000 0];

modelName = 'heli_model';  
simOut = sim(modelName);  

xyz_ts   = simOut.xyz;
euler_ts = simOut.euler;
control_ts = simOut.control;
uvw_ts   = simOut.uvw;
pqr_ts   = simOut.pqr;

t = xyz_ts.Time;

xyz     = xyz_ts.Data;
euler   = euler_ts.Data;
control = control_ts.Data;
uvw     = uvw_ts.Data;
pqr     = pqr_ts.Data;

figure('Units','centimeters','Position',[2 2 24 16]);

tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

% Position (x y z)

nexttile
plot(t, xyz(:,1),'LineWidth',1.2); hold on
plot(t, xyz(:,2),'LineWidth',1.2);
plot(t, xyz(:,3),'LineWidth',1.2);
grid on
xlabel('Time (s)')
ylabel('Position (m)')
legend('x','y','z','Location','best')
title('Position')

% Euler Angles

nexttile
plot(t, rad2deg(euler(:,1)),'LineWidth',1.2); hold on
plot(t, rad2deg(euler(:,2)),'LineWidth',1.2);
plot(t, rad2deg(euler(:,3)),'LineWidth',1.2);
grid on
xlabel('Time (s)')
ylabel('Angle (deg)')
legend('\phi','\theta','\psi','Location','best')
title('Euler Angles')

% Body Velocities

nexttile
plot(t, uvw(:,1),'LineWidth',1.2); hold on
plot(t, uvw(:,2),'LineWidth',1.2);
plot(t, uvw(:,3),'LineWidth',1.2);
grid on
xlabel('Time (s)')
ylabel('Velocity (m/s)')
legend('u','v','w','Location','best')
title('Body Velocities')

% Angular Rates

nexttile
plot(t, rad2deg(pqr(:,1)),'LineWidth',1.2); hold on
plot(t, rad2deg(pqr(:,2)),'LineWidth',1.2);
plot(t, rad2deg(pqr(:,3)),'LineWidth',1.2);
grid on
xlabel('Time (s)')
ylabel('Rate (deg/s)')
legend('p','q','r','Location','best')
title('Angular Rates')

% Collective & Tail

nexttile
plot(t, control(:,1),'LineWidth',1.2); hold on
plot(t, control(:,4),'LineWidth',1.2);
grid on
xlabel('Time (s)')
ylabel('Control Input')
legend('Collective','Tail','Location','best')
title('Main Controls')

%Cyclic Lat & Lon

nexttile
plot(t, control(:,2),'LineWidth',1.2); hold on
plot(t, control(:,3),'LineWidth',1.2);
grid on
xlabel('Time (s)')
ylabel('Control Input')
legend('Cyclic Lat','Cyclic Lon','Location','best')
title('Cyclic Inputs')

%Improve Aesthetics ---

set(findall(gcf,'-property','FontSize'),'FontSize',10)
set(findall(gcf,'-property','FontName'),'FontName','Times New Roman')
 
Export 300 DPI TIFF 
exportgraphics(gcf,'simulation_results.tif','Resolution',300)
 
% Trajectory
figure
plot(xyz(:,1), xyz(:,2), 'LineWidth', 1.5)
hold on
plot(wp(:,1), wp(:,2), 'go','MarkerSize', 10,'LineWidth', 3)

for i = 1:size(wp,1)
    text(wp(i,1), wp(i,2), sprintf('  WP%d', i), ...
        'FontWeight','bold')
end

grid on
axis equal
xlabel('X')
ylabel('Y')
title('Top View Trajectory with Waypoints')
legend('Trajectory','Waypoints')