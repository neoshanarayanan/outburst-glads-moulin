function [md, description, pos] = RunEnglacialInputPrecondition(md_coupledspinup, englinp, finaltime)

% Author: Neosha Narayanan, October 2026
% This function takes a coupled winter spinup (md_coupledspinup) and
% feeds it an englacial input until it (hopefully) goes into equilibrium.

% Inputs: 
% md_coupledspinup : equilibrated coupled spinup from coupled_spinup.m
% In the past I've used Spinups/idealized_coupled_outflow75.mat on Moulin
% englinp: constant, distributed englacial input to feed into subglacial
% system
% finaltime : number of days we want the simulation to run.

md = md_coupledspinup;
pos = pos;

% Set hydrological parameters
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
md.friction.coefficient = 300.*ones(md.mesh.numberofvertices, 1);


% Set up timestepping 
md.cluster=generic('np', 40);
md.timestepping.start_time = 0/365;
md.timestepping.time_step=7200/md.constants.yts; % Time step (in years)
md.timestepping.final_time=finaltime/365; % Final time (in years)
md.settings.output_frequency=12;
disp('output frequency = ')
md.settings.output_frequency

% Set a constant englacial input (surface melt)
timevec = 0:md.timestepping.time_step:md.timestepping.final_time;
md.hydrology.englacial_input = englinp * ones(md.mesh.numberofvertices + 1, length(timevec)); % HERE IS THE KNOB
md.hydrology.englacial_input(end, :) = timevec;


md = solve(md, 'Transient');

% Save
description='starting from idealized_coupled.mat, with a constant englacial input of 1';
filename = sprintf("coupled_input%d.mat", englinp);
save('~/cos-lab-wchu/neosha/outburst_outputs/ParamSweep2_EnglInp/Preconditions/'+filename, 'md', 'description', 'pos', '-v7.3')

end