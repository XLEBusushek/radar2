function runStartupTests(config)
% runStartupTests - Запуск полного набора тестов при config.tests.runOnStartup = true.
arguments
    config (1, 1) struct
end

if ~isfield(config, 'tests') || ~isfield(config.tests, 'runOnStartup') || ...
        ~config.tests.runOnStartup
    return;
end

fprintf('[BirdScenarioMVP] Running startup tests...\n');
runAllTests();
fprintf('[BirdScenarioMVP] Startup tests passed.\n');
end
