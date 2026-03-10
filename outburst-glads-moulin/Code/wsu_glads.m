% Trying a glads run 
% Neosha Narayanan, January 2026


% Some examples
% 1. https://github.com/SFUGG/ISSM-GlaDS-tests/blob/main/box-steady/runme.m
% from Tim Hill

md = triangle(model, '../Exp/kyagar14.exp', 40);
md=setmask(md,'','');
md=parameterize(md,'kyagar.par');


%% Hydrological params
md.hydrology = hydrologyglads;

md.hydrology.bump_height = 0.2*ones(md.mesh.numberofvertices, 1);
md.hydrology.cavity_spacing = 2; % from tim hill
md.hydrology.bump_height = 0.1*ones(md.mesh.numberofvertices, 1);
md.hydrology.melt_flag = 1;


md.hydrology.rheology_B_base = 3*ones(md.mesh.numberofvertices, 1);
md.hydrology.ischannels = 1;
md.hydrology.sheet_conductivity = 0.001*ones(md.mesh.numberofvertices, 1);
md.hydrology.channel_conductivity = 1e-3*ones(md.mesh.numberofvertices, 1);
md.hydrology.moulin_input = zeros(md.mesh.numberofelements, 1);
md.hydrology.neumannflux = zeros(md.mesh.numberofelements, 1);
md.hydrology.spcphi = NaN(md.mesh.numberofvertices, 1); % from tim hill

ic_head = md.materials.rho_ice/md.materials.rho_freshwater*md.geometry.thickness + md.geometry.base;
%md.initialization.waterfraction = 0.1*ones(md.mesh.numberofvertices, 1); %
%tim did not have waterfraction
md.initialization.watercolumn = 0.1*md.hydrology.bump_height.*ones(md.mesh.numberofvertices, 1);
md.initialization.hydraulic_potential = md.constants.g*md.materials.rho_freshwater*md.geometry.base;
md.initialization.channelarea = 0.01*ones(md.mesh.numberofedges, 1);

md.basalforcings.groundedice_melting_rate = 0.05*ones(md.mesh.numberofvertices, 1);
md.basalforcings.geothermalflux = 50;

%% timing
md.timestepping.start_time = 0/365;
md.timestepping.final_time = 1/365;
md.timestepping.time_step = 1800/md.constants.yts;

%% Solve

md.cluster = generic('np', 10);
md.settings.output_frequency = 1;

md.transient=deactivateall(md.transient);
md.verbose.solution=1;
%md.transient.ishydrology = 1;
md = solve(md, 'transient');

save('/home/nnarayanan38/cos-lab-wchu38/neosha/outburst_outputs/kyagar_wsu_glads.mat', 'md', '-v7.3')

%% Plot solution from Tim Hill
figure('Units', 'inches', 'Position', [2, 2, 10, 5])
plotmodel(md,'data',md.results.TransientSolution(1).HydraulicPotential,'title','Initial hydraulic potential [Pa]',...
    'data',md.results.TransientSolution(end).HydraulicPotential,'title','Final hydraulic potential [Pa]',...
    'data',md.results.TransientSolution(1).HydrologySheetThickness,'title','Initial sheet thickness [m]',...
    'data',md.results.TransientSolution(end).HydrologySheetThickness,'title','Final sheet thickness [m]')


%% get_variables from Tim Hill

h_sheet = [md.results.TransientSolution.HydrologySheetThickness];
phi = [md.results.TransientSolution.HydraulicPotential];
Q = abs([md.results.TransientSolution.ChannelDischarge]);
S = [md.results.TransientSolution.ChannelArea];
tt = [md.results.TransientSolution.time];

figure
plot(tt, mean(h_sheet, 1))
title('h sheet')

figure
plot(tt, mean(phi, 1))
title('phi')

figure
plot(tt, max(Q, [], 1))
title('Q channel')

figure
plot(tt, sum(S, 1))
