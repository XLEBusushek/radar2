function outputStep = collectOutput(scenario, time)
% collectOutput - Collect simulation data for the current time step.
outputStep = collectOutputStep(scenario, time);
outputStep = splitOutputTargetsByType(outputStep);
end
