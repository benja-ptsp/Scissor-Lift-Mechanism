%% RUN_ME.m — Scissor Lift Mechanism (one-click runner)
clear; clc; close all;
root = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(root, 'simulation')));

%% Part II — Symbolic analysis (height & slider force curves)
disp('Running symbolic analysis...');
run(fullfile(root, 'simulation', 'symbolic', 'scissor_kinematics.m'));

%% Part III — Simscape Multibody
% disp('Opening Simscape model...');
% open_system(fullfile(root, 'simulation', 'multibody', 'scissor_model.slx'));
% sim('scissor_model');

disp('Done.');
