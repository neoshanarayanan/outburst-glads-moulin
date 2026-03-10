% Step 2 in coupled model 
% Input standalone winter spinup: 
clear

load kyagar_wsu_glads.mat
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

pos=find((md.mask.ice_levelset<0).*(md.mesh.vertexonboundary) & md.mesh.y>=3.9485e6); % Apply Dirichlet b.c. on boundaries except terminus region
md.stressbalance.spcvx_base(pos)=0; % Set 0 basal sliding along lateral edges
md.stressbalance.spcvy_base(pos)=0;
md.stressbalance.spcvz(pos)=0;
md.stressbalance.spcvy_shear(pos)=0; % Set 0 shear along lateral edges
md.stressbalance.spcvx_shear(pos)=0;


%% Set hydrology initial conditions

% Set hydrology initial conditions
disp('Setting hydrology initial conditions');
%md.hydrology.head=md.results.TransientSolution(end).HydrologyHead;
%md.hydrology.gap_height=md.results.TransientSolution(end).HydrologyGapHeight;
%md.hydrology.reynolds=md.results.TransientSolution(end).HydrologyBasalFlux./1.787e-6;

pos=find(md.mesh.vertexonboundary & md.mesh.y>=3.9504e06);
% The ylim that's been working for the outburst flood is 3.9505e6.


md.hydrology.spcphi(pos)=md.geometry.base(pos); % Will need to change this

%% Set friction 
disp('Setting friction');
md.transient=deactivateall(md.transient);
md.transient.isstressbalance=1; % Solve for ice velocity
md.transient.ishydrology=1;

md.friction=friction(); % Budd friction
md.friction.coefficient=1000.*ones(md.mesh.numberofvertices,1); % set constant coefficients
md.friction.p           = ones(md.mesh.numberofelements,1);
md.friction.q           = ones(md.mesh.numberofelements,1);
% for shakti: Neff = md.materials.rho_ice*md.constants.g*md.geometry.thickness-md.materials.rho_water*md.constants.g*(md.hydrology.head - md.geometry.base); % Assume initial N
Neff = md.results.TransientSolution(end).EffectivePressure;
md.friction.effective_pressure=Neff;

md.friction.coupling = 4; % 4 is fully coupled


%% Do the simulation

% Set simulation settings
md.cluster=generic('np', 10);
md.timestepping.time_step=1800/md.constants.yts; % Time step (in years)
md.timestepping.final_time=30/365; % Final time (in years)
md.settings.output_frequency = 5;

% Run the model 
md=solve(md,'Transient');

% Save
description = 'coupled wsu starting from kyagar_wsu_glads.mat, MOLHO, Budd, frictioncoeff = 1000, with 0 basal sliding and shear on edges';
save('/home/nnarayanan38/cos-lab-wchu38/neosha/outburst_outputs/wsu_coupled_glads.mat', 'md', 'description', '-v7.3')
