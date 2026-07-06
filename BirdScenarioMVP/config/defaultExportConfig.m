function config = defaultExportConfig(config)
% defaultExportConfig - Visualization and export defaults.
config.visualization.enabled = true;
config.visualization.showTrees = true;
config.visualization.showTreeCrowns = true;
config.visualization.showRoads = false;
config.visualization.showBirdIDs = true;
config.visualization.showStartEndPoints = true;
config.visualization.showStateSegments = true;
config.visualization.showInvisibleSegments = true;
config.visualization.showWorldBox = true;
config.visualization.maxTreesToDraw = 80;
config.visualization.maxGroundRoutesToDraw = 5;

config.export.enabled = true;
config.export.outputFolder = "output";
config.export.saveMat = true;
config.export.saveCsv = true;
config.export.saveFigure = true;
config.export.matFileName = "bird_scenario_output.mat";
config.export.csvFileName = "bird_scenario_tracks.csv";
config.export.figureFileName = "bird_scenario_3d.png";
config.export.fixedWingDebugCsv = false;
config.export.fixedWingDebugCsvFileName = "fixed_wing_debug.csv";
end
