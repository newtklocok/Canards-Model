clear all; clc;

%% Entire Rocket Body
Diam = 0.157; %meters
Area = 0.014; %m^2
radius = Diam/2;

% spincan
spincan_radius = 0.0889;
TR_L = ;
SC_L = ;

%% Sustainer Rocket body
Sustainer_Length = 0.381+0.317+1.19; % includes nosecone
SustainerDryMass = 15;
SustainerWetMass = 31.4;
Sustainer_MotorDiam = 0.098;  

%% Booster Rocket body
Booster_Length = 4.73;
BoosterDryMass = 9.59;
BoosterWetMass = 26.4;
Booster_MotorDiam = 0.098;  

%% Masses for Separation
InitialMass = SustainerWetMass + BoosterWetMass;
SeparationMass = BoosterDryMass;

%% Thrust Data
boosterISP = 223;
sustainerISP = 189;
sustainer_delay = 6;
[boosterCurve, sustainerCurve] = thrustCurves("Data/O5500X.txt", "Data/N4000W.txt", sustainer_delay);

boost_start = boosterCurve(1, 1);
boost_end = boosterCurve(length(boosterCurve), 1);

sustain_start = sustainerCurve(1, 1);
sustain_end = sustainerCurve(length(sustainerCurve), 1);

%% Load CG & CP over time data from OR
% Columns: time [s], CP [m], CG [m]
boost_data = readmatrix('Data/booster_cg_cp.csv', 'CommentStyle', '#');
boost_t_cg = boost_data(:,1);
boost_x_cg = boost_data(:,3);

sus_data = readmatrix('Data/sustainer_cg_cp.csv', 'CommentStyle', '#');
sus_t_cg = sus_data(:,1);
sus_x_cg = sus_data(:,3);

% Separation time from the OpenRocket
t_sep = 4.997;  % s

% Attached rocket: before separation
% The sustainer branch includes both stages during this phase.
before_sep = sus_t_cg < t_sep;

stack_t_cg = sus_t_cg(before_sep);
stack_x_cg = sus_x_cg(before_sep);

% Extend the pre-separation value to the separation boundary.
% CG is constant here because booster burnout has already occurred.
stack_t_cg(end+1,1) = t_sep;
stack_x_cg(end+1,1) = stack_x_cg(end);

% Sustainer alone: after separation
after_sep = sus_t_cg >= t_sep;

sus_only_t_cg = sus_t_cg(after_sep);
sus_only_x_cg = sus_x_cg(after_sep);

%% Nosecone
%Nosecone diameter
NC_dBase = 0.131;
NC_dTop = 0; %Might need to change

%Nosecone areas
NC_aBase = pi*(NC_dBase/2)^2;
NC_aTop = pi*(NC_dTop/2)^2;

NC_aPlan =  0.03355206;
NC_VOL = 0.00025723428;
NC_L = 0.381;  

NC_CP = NC_L*0.466;
NC_CG = 0.20388;

% For TANGENT OGIVE (might need to change to add k parameter (Eq A.3 & A.4))
NC_rho = ((NC_dBase/2)^2 + NC_L^2) / NC_dBase; % Eq A.2
NC_rx = @(x) sqrt(NC_rho^2 - (NC_L - x).^2) - sqrt(NC_rho^2 - NC_L^2); % Eq A.5
% integrate to find planform centroid (Eq 3.27)
NC_Xlift_numerator = integral(@(x) x .* 2 .* NC_rx(x), 0, NC_L);
NC_Xlift = NC_Xlift_numerator / NC_aPlan;

%% Canards 
CR_AR = 0;
CR_mC = 0;
CR_Plan = 0;
CR_pos = 0;

%% Sustainer Static Fins
SF_NFins = 4;
SF_RC = 0.318;
SF_TC = 0.122;
SF_SL = 0.196;
SF_SA = 1.01; %Rads
SF_H = 0.122;
SF_plan = ((SF_TC+SF_RC)/2)*SF_H;

SF_AR = (SF_H^2)/SF_plan;
SF_aFin = 0.01844427;

SF_MidChord = deg2rad(46.8);

sf_yMac = (SF_H/3)*((SF_RC+(2*SF_TC))/(SF_RC+SF_TC));

%% Booster Static Fins
BF_NFins = 4;
BF_RC = 0.318;
BF_TC = 0.152;
BF_SL = 0.227;
BF_SA = deg2rad(58.3); %Rads
BF_H = 0.14;
BF_plan = ((BF_TC+BF_RC)/2)*BF_H;
BF_AR = (BF_H^2)/BF_plan;
BF_aFin = 0.0305436;
BF_MidChord = deg2rad(44.8);
BF_yMac = (BF_H/3)*((BF_RC+(2*BF_TC))/(BF_RC+BF_TC));

%%  FIN GEOMETRY (trapezoidal fins)
% all calculated from the fin dimensions
Gc_SF = atan((SF_SL + SF_TC/2 - SF_RC/2)/SF_H); % midchord angle, Fig. 3.2a
cbar_SF = (2/3)*(SF_RC^2 + SF_RC*SF_TC + SF_TC^2)/(SF_RC + SF_TC); % Eq. 3.30 (trapezoid)
xMAC_SF = (SF_SL/3)*(SF_RC + 2*SF_TC)/(SF_RC + SF_TC); % Eq. 3.32 (= 1st term of Eq. 3.34)

Gc_BF = atan((BF_SL + BF_TC/2 - BF_RC/2)/BF_H); % midchord angle, Fig. 3.2a
cbar_BF = (2/3)*(BF_RC^2 + BF_RC*BF_TC + BF_TC^2)/(BF_RC + BF_TC); % Eq. 3.30 (trapezoid)
xMAC_BF = (BF_SL/3)*(BF_RC + 2*BF_TC)/(BF_RC + BF_TC); % Eq. 3.32 (= 1st term of Eq. 3.34)

% canards
CR_Span = sqrt(CR_AR*CR_Plan); % span from AR = s^2/S
cbar_CR = CR_Plan/CR_Span; % mean chord, used as MAC length (approx., Eq. 3.30)

%% Adding
SurfaceRoughness = 60e-6; % 60 um for regular paint
SF_X = 3.00; % dist from nose tip to sustainer fin root leading edge (meters)
BF_X = 7.00; % dist from nose tip to booster fin root leading edge (meters)

