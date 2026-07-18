function fig = plotScenario(scenario, config)
% plotScenario - Отображение 3D-мира с деревьями, птицами и траекториями квадрокоптеров.
arguments
    scenario (1, 1) struct
    config (1, 1) struct
end

worldSize = config.world.size;
vis = config.visualization;

fig = figure('Name', 'BirdScenario - 3D', 'NumberTitle', 'off', ...
    'Visible', scenarioFigureVisibility(config));
hold on;
grid on;
axis equal;

xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

xlim([0, worldSize(1)]);
ylim([0, worldSize(2)]);
zlim([0, worldSize(3)]);

if vis.showWorldBox
    plotWorldBox(worldSize);
end

if vis.showTrees && isfield(scenario, 'Trees')
    plotTrees(scenario.Trees, config);
end

if isfield(vis, 'showRoads') && vis.showRoads && isfield(scenario, 'RoadNetwork')
    plotRoadNetwork(scenario.RoadNetwork);
end

birds = getScenarioBirds(scenario);
quadcopters = getScenarioQuadcopters(scenario);
fixedWingUAVs = getScenarioFixedWingUAVs(scenario);
groundVehicles = getScenarioGroundVehicles(scenario);

if ~isempty(birds)
    plotBirdTrajectories(birds, config);
end

if ~isempty(quadcopters)
    plotQuadcopterTrajectories(quadcopters, config);
end

if ~isempty(fixedWingUAVs)
    plotFixedWingUAVTrajectories(fixedWingUAVs, config);
end

if ~isempty(groundVehicles)
    plotGroundVehicleTrajectories(groundVehicles, config);
end

title('BirdScenario - 3D');
view(3);
addStandardBirdLegend(gca);
hold off;
end

function visible = scenarioFigureVisibility(config)
if isfield(config, 'analysis') && isfield(config.analysis, 'showFigures') && ...
        config.analysis.showFigures
    visible = 'on';
elseif usejava('desktop')
    visible = 'on';
else
    visible = 'off';
end
end
