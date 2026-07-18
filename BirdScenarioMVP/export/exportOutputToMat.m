function exportOutputToMat(scenario, output, config, outputFolder)
% exportOutputToMat - Сохранить scenario, output и config в MAT-файл.
arguments
    scenario (1, 1) struct
    output struct
    config (1, 1) struct
    outputFolder (1, :) char
end

matPath = fullfile(outputFolder, config.export.matFileName);
save(matPath, 'scenario', 'output', 'config');
end
