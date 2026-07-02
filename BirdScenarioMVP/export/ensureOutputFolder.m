function outputFolder = ensureOutputFolder(config)
% ensureOutputFolder - Create export output folder if it does not exist.
arguments
    config (1, 1) struct
end

if ~isfield(config, 'export') || ~isfield(config.export, 'outputFolder')
    error('ensureOutputFolder:MissingConfig', 'config.export.outputFolder is required.');
end

outputFolder = char(config.export.outputFolder);
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
end
