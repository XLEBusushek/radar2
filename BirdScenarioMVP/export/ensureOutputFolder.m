function outputFolder = ensureOutputFolder(config)
% ensureOutputFolder - Создать папку вывода экспорта, если она не существует.
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
