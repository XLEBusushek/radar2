function log = appendCsvRowsFromScenario(scenario, log, time, config)
% appendCsvRowsFromScenario - Append CSV track rows from live scenario state.
arguments
    scenario (1, 1) struct
    log (1, 1) struct
    time (1, 1) double
    config (1, 1) struct
end

if ~shouldIncrementalCsv(config)
    return;
end

step = collectOutputStep(scenario, time);
if ~isfield(step, 'Targets') || isempty(step.Targets)
    return;
end

if ~isfield(log, 'CsvRowCount')
    log.CsvRowCount = 0;
end

randomMode = string(step.RandomMode);
scenarioSeed = step.ScenarioSeed;
for i = 1:numel(step.Targets)
    row = buildCsvRowFromTargetOutput( ...
        time, randomMode, scenarioSeed, step.Targets(i));
    if ~isfield(log, 'CsvRows') || isempty(log.CsvRows)
        log.CsvRows = row;
        log.CsvRowCount = 1;
    else
        log.CsvRowCount = log.CsvRowCount + 1;
        log.CsvRows(log.CsvRowCount) = row;
    end
end
end
