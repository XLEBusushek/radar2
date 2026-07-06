function reportExportStep(label, tStart)
% reportExportStep - Print export step timing to the command window.
arguments
    label (1, 1) string
    tStart
end

fprintf('[BirdScenarioMVP] %s (%.1f s)\n', label, toc(tStart));
end
