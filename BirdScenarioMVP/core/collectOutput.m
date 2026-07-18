function outputStep = collectOutput(scenario, time)
% collectOutput - Собрать данные симуляции для текущего шага по времени.
outputStep = collectOutputStep(scenario, time);
outputStep = splitOutputTargetsByType(outputStep);
end
