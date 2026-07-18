function tf = shouldBuildLegacyOutput(config)
% shouldBuildLegacyOutput - Нужно ли runSimulation перестраивать legacy output.
arguments
    config (1, 1) struct
end

if isfield(config, 'log') && isfield(config.log, 'buildLegacyOutput')
    tf = logical(config.log.buildLegacyOutput);
else
    tf = true;
end
end
