function fig = plotScenarioFromLog(trajectoryLog, env, config)
% plotScenarioFromLog - 3D scenario plot using TrajectoryLog and static env.
arguments
    trajectoryLog (1, 1) struct
    env (1, 1) struct
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

if vis.showTrees && isfield(env, 'Trees')
    plotTrees(env.Trees, config);
end

if isfield(vis, 'showRoads') && vis.showRoads && isfield(env, 'RoadNetwork')
    plotRoadNetwork(env.RoadNetwork);
end

birds = buildLogTargetsForPlot(trajectoryLog, "bird", "");
quadcopters = buildLogTargetsForPlot(trajectoryLog, "air", "quadcopter");
fixedWingUAVs = buildLogTargetsForPlot(trajectoryLog, "air", "fixedWingUAV");
groundVehicles = buildLogTargetsForPlot(trajectoryLog, "ground", "vehicle");

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

function targets = buildLogTargetsForPlot(trajectoryLog, className, subtype)
ids = getUniqueTargetIds(trajectoryLog, className, subtype);
targets = struct([]);
for i = 1:numel(ids)
    targets(i).ID = ids(i);
    targets(i).History = buildTargetHistoryFromLog(trajectoryLog, ids(i));
    if ~isempty(targets(i).History.Position)
        targets(i).Position = targets(i).History.Position(end, :);
    else
        targets(i).Position = [0, 0, 0];
    end
end
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
