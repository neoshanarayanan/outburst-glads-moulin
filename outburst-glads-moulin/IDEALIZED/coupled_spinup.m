% Taken from shakti-outburst-totten on April 21, 2026
% Input standalone winter spinup: 
clear

load Spinups/idealized.mat
%% Set hydrological parameters
md.hydrology.head = md.results.TransientSolution(end).HydrologyHead;
md.hydrology.gap_height = md.results.TransientSolution(end).HydrologyGapHeight;
md.hydrology.reynolds = md.results.TransientSolution(end-1).HydrologyBasalFlux/1.787e-6;
md.friction.effective_pressure = md.results.TransientSolution(end).EffectivePressure;

% Set atmospheric pressure BC at the lake
%lake_pos = pos;
%md.hydrology.spchead(lake_pos) = md.geometry.base(lake_pos);

%% Set flow law and velocity boundary conditions

%md=setflowequation(md,'SSA','all');
md = setflowequation(md, 'MOLHO', 'all');
% extra conditions for MOLHO
md.stressbalance.spcvx_base = NaN(md.mesh.numberofvertices,1); % Try setting to 0
md.stressbalance.spcvy_base = NaN(md.mesh.numberofvertices,1);
md.stressbalance.spcvx_shear = NaN(md.mesh.numberofvertices,1);
md.stressbalance.spcvy_shear = NaN(md.mesh.numberofvertices,1);

md.stressbalance.spcvx = NaN(md.mesh.numberofvertices,1);
md.stressbalance.spcvy = NaN(md.mesh.numberofvertices,1);
md.stressbalance.spcvz = NaN(md.mesh.numberofvertices,1);

%pos = find(md.mesh.vertexonboundary & md.mesh.y <= 3.95060e6); % this is the same extent as the atm press BC from winter_spin_up.m
%pos = find(md.mesh.vertexonboundary & md.mesh.x>=6.95603e5 & md.mesh.x <=6.96130e5 & md.mesh.y >= 3.950360e6 & md.mesh.y <= 3.950900e6); % This is the location of the updated atmospheric pressure BC (newfront)

%min_pos = min(md.mesh.y(pos));
%pos = find(md.mesh.vertexonboundary & md.mesh.y <= min_pos);

%md.stressbalance.spcvx_base(pos)=0; % Set 0 basal sliding along lateral edges
md.stressbalance.spcvy_base(pos)=0;
md.stressbalance.spcvz(pos)=0;
md.stressbalance.spcvy_shear(pos)=0; % Set 0 shear along lateral edges
md.stressbalance.spcvx_shear(pos)=0;
md.stressbalance.spcvx_base(pos) = 0; % added nov 20

%% Set hydrology initial conditions

% Set hydrology initial conditions
disp('Setting hydrology initial conditions');
md.hydrology.head=md.results.TransientSolution(end).HydrologyHead;
md.hydrology.gap_height=md.results.TransientSolution(end).HydrologyGapHeight;
md.hydrology.reynolds=md.results.TransientSolution(end).HydrologyBasalFlux./1.787e-6;

%pos=find(md.mesh.vertexonboundary & md.mesh.y>=3.9505e06);
% The ylim that's been working for the outburst flood is 3.9505e6.

% Set atmospheric pressure BC at pos
%md.hydrology.spchead(pos)=md.geometry.base(pos);

%% Set friction 
disp('Setting friction');
md.transient=deactivateall(md.transient);
md.transient.isstressbalance=1; % Solve for ice velocity
md.transient.ishydrology=1;

md.friction=friction(); % Budd friction
md.friction.coefficient=300.*ones(md.mesh.numberofvertices,1); % set constant coefficients
md.friction.p           = ones(md.mesh.numberofelements,1);
md.friction.q           = ones(md.mesh.numberofelements,1);
Neff = md.materials.rho_ice*md.constants.g*md.geometry.thickness-md.materials.rho_water*md.constants.g*(md.hydrology.head - md.geometry.base); % Assume initial N
md.friction.effective_pressure=Neff;

md.friction.coupling = 4; % 4 is fully coupled


%% Do the simulation

% Set simulation settings
md.cluster=generic('np', 8);
md.timestepping.time_step=7200/md.constants.yts; % Time step (in years)
md.timestepping.final_time=100/365; % Final time (in years)
md.settings.output_frequency=12;
disp('output frequency = ')
md.settings.output_frequency

% Run the model 
md=solve(md,'Transient');

%md = solve(md, 'sb');

% Save
description = '';
save('Spinups/coupled_shmip.mat', 'md', 'description', '-v7.3')