clear all; clc;

%% Entire Rocket Body
Diam = 0.102;
Area = pi*Diam^2/4;
spincan_radius = 0.127/2;

%% Booster Rocket body
Booster_Length = 1.92; % total length
BoosterDryMass = 6.916;
BoosterWetMass = 9.532;
Booster_MotorDiam = 0.075;

% Moment of Inertias (from OR)
Ixx_empty = 0.016109; % (rotational)
Iyy_empty = 3.018769; % (longitudinal)
Ixx_full = 0.017068;
Iyy_full = 3.518905;

%% Thrust Data
boosterISP = 229;

function curve = thrustCurve(file)
data = readmatrix(file, "FileType", "text", "NumHeaderLines", 2);
data = data(~any(isnan(data),2), :);
curve = [data(:,1) data(:,2)];

% Prepend t=0 row with zero thrust
if curve(1,1) ~= 0
    curve = [[0, 0]; curve];
end
end

boosterCurve = thrustCurve("Data/Cesaroni_2856L910-P.csv");

boost_start = boosterCurve(1, 1);
boost_end = boosterCurve(length(boosterCurve), 1);

g0 = 9.80665;
propMass = trapz(boosterCurve(:,1), boosterCurve(:,2))/(g0*boosterISP);
BoosterBurnoutMass = BoosterWetMass - propMass;   % Empty mass

%% Load CG & CP over time data from OR
% Columns: time [s], CP [m], CG [m]
boost_data = readmatrix('Data/test_rocket_cg_cp.csv', 'CommentStyle', '#');
boost_t_cg = boost_data(:,1);
boost_x_cg = boost_data(:,3)/100;

%% Nosecone
% Nosecone diameter
NC_dBase = 0.102;
NC_dTop = 0.000000001; 
NC_phiJoint = 0;   % tangent ogive meets the tube tangentially
NC_kappa = 1;   % tangent ogive

% Spincan & Transition Lengths
TR_L = 0.102;
SC_L = 0.229;

% Nosecone areas
NC_aBase = pi*(NC_dBase/2)^2;
NC_aTop = pi*(NC_dTop/2)^2;
NC_L = 0.406;  

NC_CP = NC_L*0.466;

% For TANGENT OGIVE (might need to change to add k parameter (Eq A.3 & A.4))
NC_rho = ((NC_dBase/2)^2 + NC_L^2) / NC_dBase; % Eq A.2

NC_rx = @(x) sqrt(NC_rho^2 - (NC_L - x).^2) - sqrt(NC_rho^2 - NC_L^2);
NC_aPlan =  integral(@(x) 2*NC_rx(x), 0, NC_L);

% integrate to find planform centroid (Eq 3.27)
NC_Xlift_numerator = integral(@(x) x .* 2 .* NC_rx(x), 0, NC_L);
NC_Xlift = NC_Xlift_numerator / NC_aPlan;

%% Canards 
CR_RC = 0.0254;  CR_TC = 0;  CR_Span = 0.03;  CR_SL = 0.025;   % m
CR_t  = 0.003;
CR_X = 0.4826;
CR_Plan = (CR_RC + CR_TC)/2*CR_Span;                              % 3.81e-4 m^2, one canard, one side
cbar_CR = (2/3)*(CR_RC^2 + CR_RC*CR_TC + CR_TC^2)/(CR_RC + CR_TC);  % MAC = 0.016933 m
CR_yMAC = (CR_Span/3)*(CR_RC + 2*CR_TC)/(CR_RC + CR_TC);          % 0.0100 m (Span/3 for a triangle)
xMAC_CR = (CR_SL/3)*(CR_RC + 2*CR_TC)/(CR_RC + CR_TC);            % 0.00833 m
CR_LE = atan(CR_SL/CR_Span);                                      % 0.6947 rad
CR_mC = atan((CR_SL + CR_TC/2 - CR_RC/2)/CR_Span);                % 0.3892 rad
CR_pos = CR_X + xMAC_CR + 0.25*cbar_CR;                      % CR_X_LE = root leading edge from nose tip

%% Booster Spincan
BF_NFins = 4;
BF_RC = 0.229;                 % root chord, m
BF_TC = 0.0889;                % tip chord, m
BF_H  = 0.102;                 % span, m          (your file had 0.14)
BF_SL = 0.185;                 % sweep length, m  (your file had 0.227)
BF_t  = 0.003;                   % fin thickness, m  <- you haven't given me this
BF_X = 1.626; % dist from nose tip to booster fin root leading edge (meters)

BF_plan = ((BF_TC+BF_RC)/2)*BF_H;                        % one fin, one side, m^2 (0.016213)
BF_SA   = atan(BF_SL/BF_H);                              % LE sweep, rad (1.0669)
BF_yMac = (BF_H/3)*((BF_RC + 2*BF_TC)/(BF_RC + BF_TC));  % spanwise MAC position, m (0.04351)

%%  FIN GEOMETRY (trapezoidal fins)
% all calculated from the fin dimensions
Gc_BF = atan((BF_SL + BF_TC/2 - BF_RC/2)/BF_H); % midchord angle, Fig. 3.2a
cbar_BF = (2/3)*(BF_RC^2 + BF_RC*BF_TC + BF_TC^2)/(BF_RC + BF_TC); % Eq. 3.30 (trapezoid)
xMAC_BF = (BF_SL/3)*(BF_RC + 2*BF_TC)/(BF_RC + BF_TC); % Eq. 3.32 (= 1st term of Eq. 3.34)

%% Adding
SurfaceRoughness = 60e-6; % 60 um for regular paint


