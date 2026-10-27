% Run a series of outburst floods given all preconditions
% Neosha Narayanan, October 2026

% From Google Gemini: 
% Specify your folder path

clear('all')
myFolder = '/home/nnarayanan38/cos-lab-wchu38/neosha/outburst_outputs/ParamSweep2_EnglInp/Preconditions'; 

% Get a list of all files matching a specific pattern (e.g., all files: '*.*')
filePattern = fullfile(myFolder, '*.mat');
theFiles = dir(filePattern);

for k = 1 : length(theFiles)
	% Skip if it's a directory (avoids '.' and '..')
	if theFiles(k).isdir
        	continue;
	end
    
	baseFileName = theFiles(k).name;
 	fullFileName = fullfile(theFiles(k).folder, baseFileName);
 	
	fprintf('Now processing: %s\n', fullFileName);
    	
	load(fullFileName)
	md_precond = md;
	
	% Get englacial input and round to the nearest 0.5
	mean_englinp = mean(md_precond.hydrology.englacial_input, 'all');
	rounded_englinp = round(mean_englinp*4)/4;

	% Define lake location
	lake_x = 500; % lake size will be 75 segments
	RunOutburst(md_precond, lake_x, rounded_englinp);
	disp('saved')

end
