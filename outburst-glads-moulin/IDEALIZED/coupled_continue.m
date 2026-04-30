% Step 2 in coupled model 
% Input standalone winter spinup: 
clear
% last modified april 30,  2026 by Neosha
% Purpose: add some constant melt
%load kyagar_wsu_400d_50m-kyagar5.mat % standalone winter spinup

load Spinups/idealized.mat
pos = pos;
clear('md', 'description')

load Spinups/idealized_coupled.mat

%% Set hydrological parameters
md.hydrology.head = md.results.TransientSolution(end).HydrologyHead;
md.hydrology.gap_height = md.results.TransientSolution(end).HydrologyGapHeight;
md.hydrology.reynolds = md.results.TransientSolution(end-1).HydrologyBasalFlux/1.787e-6;
md.friction.effective_pressure = md.results.TransientSolution(end).EffectivePressure;

md.initialization.vel = md.results.TransientSolution(end).Vel;
md.initialization.vx = md.results.TransientSolution(end).Vx;
md.initialization.vy = md.results.TransientSolution(end).Vy;

md.transient.isstressbalance=1; % Solve for ice velocity
md.transient.ishydrology=1;

md.friction.coupling = 4; % 4 is fully coupled



%% Set up timestepping

% Set simulation settings
md.cluster=generic('np', 40);
md.timestepping.start_time = 0/365;
md.timestepping.time_step=7200/md.constants.yts; % Time step (in years)
md.timestepping.final_time=100/365; % Final time (in years)
md.settings.output_frequency=12;
disp('output frequency = ')
md.settings.output_frequency

%% Set a constant englacial input (surface melt)
timevec = 0:md.timestepping.time_step:md.timestepping.final_time;
md.hydrology.englacial_input = 20.0 * ones(md.mesh.numberofvertices + 1, length(timevec));
md.hydrology.englacial_input(end, :) = timevec;


md = solve(md, 'Transient');

% Save
description='starting from idealized_coupled.mat, with a constant englacial input of 20.0'
save('coupled_input20.mat', 'md', 'description', 'pos', '-v7.3')
