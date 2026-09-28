clear all; clc;

%% Entire Rocket Body
Argus_Diam = 0.131; %meters
Argus_Area = 0.014; %m^2
Argus_radius = Argus_Diam/2;



%% Sustainer Rocket body
Sustainer_Length = 3.25;
SustainerDryMass = 15;
SustainerWetMass = 31.4;

%% Booster Rocket body
Booster_Length = 4.73;
BoosterDryMass = 9.59;
BoosterWetMass = 26.4;

%% Thrust Data
boosterISP = 223;
sustainerISP = 189;
[boosterCurve, sustainerCurve] = thrustCurves("Data/O5500X.eng", "Data/N4000W.eng", 6);


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