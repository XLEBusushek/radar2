function log = appendCsvRowsFromScenario(scenario, log, time, config)
% appendCsvRowsFromScenario - Добавить строки треков CSV из текущего состояния сценария.
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
    log.CsvRowCount = log.CsvRowCount + 1;
    rowIndex = log.CsvRowCount;

    if rowIndex == 1 && isfield(log, 'CsvRowCapacity') && log.CsvRowCapacity > 0
        log.CsvRows = repmat(row, log.CsvRowCapacity, 1);
    elseif rowIndex > numel(log.CsvRows)
        log.CsvRows(rowIndex, 1) = row;
    else
        log.CsvRows(rowIndex) = row;
    end
end
end
