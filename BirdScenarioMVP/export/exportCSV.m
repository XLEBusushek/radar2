function exportCSV(legacyOutput, config, outputFolder)
% exportCSV - Экспорт совместимого с legacy CSV трека из выходных данных симуляции.
arguments
    legacyOutput struct
    config (1, 1) struct
    outputFolder (1, :) char
end

exportOutputToCsv(legacyOutput, config, outputFolder);
end
