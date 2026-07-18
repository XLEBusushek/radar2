function outputStep = collectOutputStep(scenario, time)
% collectOutputStep - Собрать выходные данные шага без разделения Birds.
outputStep.Time = time;
outputStep.RandomMode = "";
outputStep.ScenarioSeed = nan;
if isfield(scenario, 'Random')
    outputStep.RandomMode = string(getStructField(scenario.Random, 'Mode', ""));
    outputStep.ScenarioSeed = getStructField(scenario.Random, 'ScenarioSeed', nan);
elseif isfield(scenario, 'Metadata')
    outputStep.RandomMode = string(getStructField(scenario.Metadata, 'RandomMode', ""));
    outputStep.ScenarioSeed = getStructField(scenario.Metadata, 'ScenarioSeed', nan);
end

if ~isfield(scenario, 'Targets') || isempty(scenario.Targets)
    outputStep.Targets = struct([]);
    return;
end

numTargets = numel(scenario.Targets);
for i = 1:numTargets
    target = scenario.Targets(i);
    targetOut = buildBaseTargetOutput(target);

    if isfield(target, 'Payload')
        targetOut = addBirdOutputFields(targetOut, target);
        targetOut = resetNavigationOutputDefaults(targetOut);

        if target.Class == "air" && ismember(target.Subtype, ["quadcopter", "fixedWingUAV"])
            targetOut = addAirOutputFields(targetOut, target);
        elseif target.Class == "ground" && target.Subtype == "vehicle"
            targetOut = addGroundOutputFields(targetOut, target);
        else
            targetOut = addDefaultNavigationOutputFields(targetOut);
        end
    end

    outputStep.Targets(i) = targetOut;
end
end
