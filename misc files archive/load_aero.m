%% load_aero.m - Clipped to Flight Envelope (Mach <= 3.5)
clear; clc;

data = readtable('Aero Data.CSV', 'VariableNamingRule', 'preserve'); 

% Filter for Alpha == 0 AND Mach <= 3.5 (flight regime)
valid_idx = (data.Alpha == 0) & (data.Mach <= 3.5);
data_flight = data(valid_idx, :);

% Assign variables
Mach_vec       = data_flight.Mach;
Cd_mach        = data_flight.CD;
CnA_mach       = data_flight.("CNalpha (0 to 4 deg) (per rad)");
Cp_inches_mach = data_flight.CP;

% Capitalized aliases
Cd_Mach        = Cd_mach;
CnA_Mach       = CnA_mach;
Cp_inches_Mach = Cp_inches_mach;

disp('Aero data clipped to Mach 3.5 and loaded.');

%% Rocket Motor Thrust Curve (2856-L910-CS-P)
% Format: [Time (s), Thrust (N)]
eng_data = [
    0.000,    0.000;    % Ignition start boundary
    0.034,  858.741;
    0.056,  921.678;
    0.305,  952.448;
    0.718,  983.217;
    1.221, 1047.550;
    1.642, 1005.590;
    1.842,  973.427;
    2.951,  773.427;
    3.035,  584.615;
    3.108,  169.231;
    3.152,   72.727;
    3.182,   27.972;
    3.262,    0.000;    % Burnout
    100.0,    0.000     % Coast phase pad (keeps thrust 0N for rest of flight)
];

thrust_time_vec = eng_data(:, 1);  % Time breakpoints (s)
thrust_force_vec = eng_data(:, 2); % Thrust magnitude (N)%% Rocket Motor Thrust Curve (2856-L910-CS-P)

disp('Motor Thrust Curve loaded.');
