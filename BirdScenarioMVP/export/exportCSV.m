function exportCSV(legacyOutput, config, outputFolder)
% exportCSV - Export legacy-compatible track CSV from simulation output.
arguments
    legacyOutput struct
    config (1, 1) struct
    outputFolder (1, :) char
end

exportOutputToCsv(legacyOutput, config, outputFolder);
end
