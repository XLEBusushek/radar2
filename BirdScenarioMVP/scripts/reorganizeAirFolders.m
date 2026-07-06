% reorganizeAirFolders - One-time air/ folder layout (TZ structure refactor).
airRoot = fileparts(fileparts(mfilename('fullpath')));
airDir = fullfile(airRoot, 'air');

subdirs = {'quadcopter', 'fixedwing_legacy', 'common'};
for i = 1:numel(subdirs)
    targetDir = fullfile(airDir, subdirs{i});
    if ~isfolder(targetDir)
        mkdir(targetDir);
    end
end

quadcopterFiles = {
    'advanceQuadcopterWaypoint.m'
    'applyQuadcopterMotionLimits.m'
    'computeQuadcopterDesiredVelocity.m'
    'createQuadcopterTarget.m'
    'enforceQuadcopterWaypointDistance.m'
    'generateQuadcopterMission.m'
    'initializeQuadcopterHover.m'
    'initializeQuadcopterLanding.m'
    'initializeQuadcopterReturn.m'
    'initializeQuadcopterScan.m'
    'initializeQuadcopterTakeoff.m'
    'isQuadcopterTransitionAllowed.m'
    'quadcopterDecisionEngine.m'
    'resetQuadcopterNavigationFlags.m'
    'selectNextQuadcopterWaypoint.m'
    'shouldForceQuadcopterTransit.m'
    'transitionQuadcopterState.m'
    'updateQuadcopterBehavior.m'
    'updateQuadcopterExcursionMetrics.m'
    'updateQuadcopterKinematics.m'
    'updateQuadcopterMotionCommand.m'
    'updateQuadcopterNavigationProgress.m'
};

commonFiles = {'computeDistanceToWorldBoundary.m'};

moveListedFiles(airDir, fullfile(airDir, 'quadcopter'), quadcopterFiles);
moveListedFiles(airDir, fullfile(airDir, 'common'), commonFiles);

remaining = dir(fullfile(airDir, '*.m'));
legacyDir = fullfile(airDir, 'fixedwing_legacy');
for i = 1:numel(remaining)
    src = fullfile(airDir, remaining(i).name);
    movefile(src, fullfile(legacyDir, remaining(i).name));
end

fprintf('air/ reorganization complete.\n');

function moveListedFiles(sourceDir, destDir, fileNames)
for i = 1:numel(fileNames)
    src = fullfile(sourceDir, fileNames{i});
    if isfile(src)
        movefile(src, fullfile(destDir, fileNames{i}));
    end
end
end
