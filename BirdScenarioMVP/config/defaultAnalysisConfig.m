function config = defaultAnalysisConfig(config)
% defaultAnalysisConfig - Значения по умолчанию для фигур анализа.
config.analysis.enabled = true;
config.analysis.xyFigure = true;
config.analysis.altitudeFigure = true;
config.analysis.speedFigure = true;
config.analysis.stateFigure = true;
config.analysis.visibilityFigure = true;
config.analysis.saveFigures = true;
config.analysis.showFigures = false;
config.analysis.show3D = false;
config.analysis.showXY = true;
config.analysis.showAltitude = true;
config.analysis.showSpeed = true;
config.analysis.showStates = true;
config.analysis.showVisibility = true;
config.analysis.xyFile = "bird_xy.png";
config.analysis.altitudeFile = "bird_altitude.png";
config.analysis.speedFile = "bird_speed.png";
config.analysis.stateFile = "bird_states.png";
config.analysis.visibilityFile = "bird_visibility.png";
config.analysis.fixedWingNavigationDebug = false;
config.analysis.fixedWingNavigationDebugFile = "fixed_wing_navigation_debug.png";
end
