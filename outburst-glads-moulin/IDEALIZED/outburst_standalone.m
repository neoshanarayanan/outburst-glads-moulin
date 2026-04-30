% Simulates outburst flood at Kyagar Glacier through ice-dammed lake at
% the east side of the terminus through a Neumann flux BC
% Neosha Narayanan, August 2025
% Last updated: April 2026 for idalized geometry

% ^^ Taken from shakti-outburst-totten repo on April 21, 2026 for idealized
% case with SHMIP geometry

clear all

%% Load from winter spinup


load ConnectedHydrologyResults/coupled_input20.mat
%disp('standalone WSU loaded')
%% Set up model from the loaded spinup

% Set new initial conditions (starting from end of previous run)
md.hydrology.head=md.results.TransientSolution(end-1).HydrologyHead;
md.hydrology.gap_height=md.results.TransientSolution(end-1).HydrologyGapHeight;
md.hydrology.reynolds=md.results.TransientSolution(end-1).HydrologyBasalFlux./1.787e-6;
md.friction.effective_pressure = md.results.TransientSolution(end).EffectivePressure;


if md.transient.isstressbalance==1
    md.initialization.vel = md.results.TransientSolution(end-1).Vel;
    md.initialization.vx = md.results.TransientSolution(end-1).Vx;
    md.initialization.vy = md.results.TransientSolution(end-1).Vy;
end

%% Define model timing 

year_start_time = 0/365;
year_end_time = 125/365;

md.timestepping.start_time = year_start_time;
md.timestepping.time_step=1800/md.constants.yts; % Time step (in years)
md.timestepping.final_time=year_end_time; % number of days % for 2020 this will be 366
timevec=0:md.timestepping.time_step:md.timestepping.final_time;

%% Find flood location

% Find segments
segx = md.mesh.x(md.mesh.segments(:, 1)); % x-coords of all border vertex1s
segy = md.mesh.y(md.mesh.segments(:, 1));

% Lake position
%pos = md.mesh.segments(find(segy>3.949670e6 & segy<3.950010e6 & segx<=6.97269e5 & segx>=6.97027e5), 3); % Updated for kyagar10, from Li et al. 2023
pos = md.mesh.segments(find(segy>300 & segx>=325 & segx <= 425), 3);

%% Create a long buildup (simulate lake getting bigger and bigger)

buildupDuration = 45/365; % Lake is building up over this amount of days
buildupStartDay = 15/365;
buildupEndDay = buildupStartDay + buildupDuration;
buildupTimeSteps = buildupStartDay:md.timestepping.time_step:buildupEndDay;

buildupStart_timestep = length(0:md.timestepping.time_step:buildupStartDay);
buildupEnd_timestep = buildupStart_timestep + length(buildupTimeSteps);
floodtime_indices = buildupStart_timestep:buildupEnd_timestep-1;

maxFlux = 1; %m2/s
a = maxFlux/length(buildupTimeSteps); % slope of linear buildup curve
hydrograph = a* (1:length(buildupTimeSteps));


%% Format Neumann BC for prescription into ISSM

%Plot hydrograph to ensure that it is correct
plot(1:length(buildupTimeSteps),hydrograph, 'LineWidth', 2)
title('Flood Hydrograph')
ylabel('Flux (m^2/s)')
xlabel('Time (y)')


% Assign hydrograph BC to each selected segment
hydrograph = repmat(hydrograph, numel(pos), 1);


% Now pass the BC to the model 
md.hydrology.neumannflux = zeros(md.mesh.numberofelements+1, length(timevec));
md.hydrology.neumannflux(end, :) = timevec; 
md.hydrology.neumannflux(pos, floodtime_indices) = hydrograph;
md.hydrology.neumannflux(end, :) = timevec; % redundancy

% Set new max for hydrology gap height (NEW SEP 10)
md.hydrology.gap_height_max = 100;


% Additional diagnostic tools if the flood isn't working!! 

% % Plot sum of flux to verify that the above code worked 
% flux_sum = sum(md.hydrology.neumannflux(1:end-1, :), 2);   % sum over time
% plotmodel(md,'data',flux_sum);
% title('Element-wise sum of neumannflux over time');

% Plot flux timeseries
% plot(mean(md.hydrology.neumannflux, 1))


%% Solve hydrology model 

% Verify hydrology and stressbalance solutions are on
md.transient.ishydrology=1;

md.transient.requested_outputs={'HydrologyMeltRate','HydrologyFrictionHeat','HydrologyDissipation'};

% Output settings
md.settings.output_frequency=48;
md.verbose.solution=1;

% Compute
md.cluster=generic('np', 32);
md = solve(md, 'Transient');

description = 'long leadup glof, starting from coupled_input20.mat';
save('idealized_coupled_outburst_connected20.mat', 'md', 'description','pos', '-v7.3')
