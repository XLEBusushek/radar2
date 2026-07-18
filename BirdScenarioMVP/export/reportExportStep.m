function reportExportStep(label, tStart)
% reportExportStep - Вывести время выполнения шага экспорта в командное окно.
arguments
    label (1, 1) string
    tStart
end

fprintf('[BirdScenarioMVP] %s (%.1f s)\n', label, toc(tStart));
end
