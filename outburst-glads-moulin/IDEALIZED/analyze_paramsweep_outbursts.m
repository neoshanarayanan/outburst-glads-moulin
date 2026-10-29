% Analyze all outburst results

myFolder = '/home/nnarayanan38/cos-lab-wchu38/neosha/outburst_outputs/ParamSweep2_EnglInp/Outbursts'; 

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

    load(fullFileName);
    ei = englinp;
    
    % Retrieve information
    [meandeltaN, maxVelDropx, maxVelDrop] = AnalyzeParamSweepOutburst(md, 15, 60);
    meandeltaNs(k) = (englinp, meandeltaN);
    maxVelDropxs(k) = (englinp, maxVelDropx);
    maxVelDrops(k) = (englinp, maxVelDrop);
    
end

save("data_outbursts.mat", 'meanDeltaNs', 'maxVelDropxs', 'maxVelDrops', '-v7.3')