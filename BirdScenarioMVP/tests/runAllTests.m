% runAllTests - Run all BirdScenarioMVP tests in order (ТЗ-06).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

testScripts = {
    'testProjectSkeleton.m'
    'testCollectOutputStructure.m'
    'testTrajectoryLogStructure.m'
    'testLegacyOutputEquivalence.m'
    'testTargetHistoryCache.m'
    'testHistoryModeEquivalence.m'
    'testDirectCsvExport.m'
    'testDefaultConfigStructure.m'
    'testSplitTargetsByType.m'
    'testTrees.m'
    'testTargets.m'
    'testBirdInitialization.m'
    'testSimulationEngine.m'
    'testHistoryUpdate.m'
    'testOutputFormat.m'
    'testBirdFSMTransitions.m'
    'testBirdFSMRandomness.m'
    'testBirdTargetTreeSelection.m'
    'testOutputFSMFields.m'
    'testBirdTakeoffMotion.m'
    'testBirdCruiseMotion.m'
    'testBirdMotionLimits.m'
    'testOutputMotionFields.m'
    'testBirdCurvedCruiseFields.m'
    'testBirdCurvedCruiseMotion.m'
    'testBirdManeuverEvents.m'
    'testBirdCurvedCruiseLimits.m'
    'testBirdLandingFields.m'
    'testBirdLandingMotion.m'
    'testBirdNoLandingTeleport.m'
    'testBirdFullCycle.m'
    'testBirdLandingLimits.m'
    'testBirdRealismFields.m'
    'testBirdRetargeting.m'
    'testBirdSharpManeuver.m'
    'testBirdCircleBeforeLanding.m'
    'testBirdRealismLimits.m'
    'testVisualization.m'
    'testExportMat.m'
    'testExportCsv.m'
    'testAnalysisPlots.m'
    'testAnalysisExport.m'
    'testBirdNoLocalCircling.m'
    'testBirdProgressToTarget.m'
    'testVisualizationWindows.m'
    'testVisualizationLegend.m'
    'testQuadcopterInitialization.m'
    'testQuadcopterMission.m'
    'testQuadcopterFSM.m'
    'testQuadcopterTakeoff.m'
    'testQuadcopterHover.m'
    'testQuadcopterScan.m'
    'testQuadcopterLimits.m'
    'testQuadcopterOutput.m'
    'testQuadcopterXYMovement.m'
    'testQuadcopterZMovement.m'
    'testQuadcopterProgressToWaypoint.m'
    'testQuadcopterForceDirect.m'
    'testQuadcopterHoverScanBalance.m'
    'testQuadcopterNavigationOutput.m'
    'testFW2Initialization.m'
    'testFW2MissionGeneration.m'
    'testFW2LegProgress.m'
    'testFW2NoWaypointAttraction.m'
    'testFW2SmoothTurns.m'
    'testFW2NoBorderFollowing.m'
    'testFW2BoundaryRecovery.m'
    'testFW2AltitudeLevels.m'
    'testFW2NoHoverStop.m'
    'testFW2RouteRegeneration.m'
    'testFW2OutputFields.m'
    'testFW2SpeedProfileInitialization.m'
    'testFW2SpeedVariation.m'
    'testFW2SpeedSmoothness.m'
    'testFW2AltitudeProfileInitialization.m'
    'testFW2AltitudeVariation.m'
    'testFW2AltitudeSmoothness.m'
    'testFW2ProfileOutputFields.m'
    'testMixedAirTargets.m'
    'testMixedTargets.m'
    'testRoadGeneration.m'
    'testGroundInitialization.m'
    'testGroundMission.m'
    'testGroundNavigation.m'
    'testGroundLeaveRoad.m'
    'testGroundReturnRoad.m'
    'testGroundSpeedLimits.m'
    'testGroundOutput.m'
    'testGroundVisualization.m'
    'testGroundRouteContinuity.m'
    'testGroundNoCornerCutting.m'
    'testGroundPurePursuitRoute.m'
    'testGroundNoTeleport.m'
    'testGroundMeaningfulStops.m'
    'testGroundVisualizationClarity.m'
    'testRoadNetworkConnectivity.m'
    'testRoadNetworkLength.m'
    'testGroundVehicleOnRoadStart.m'
    'testGroundVehicleRouteGeneration.m'
    'testGroundVehicleFollowsRoad.m'
    'testGroundVehicleNoFieldCutting.m'
    'testGroundVehicleOffRoadReturn.m'
    'testGroundVehicleSpeedLimits.m'
    'testGroundVehicleVisualization.m'
    'testGroundOutputFields.m'
    'testBehaviorProfiles.m'
    'testBehaviorRandomness.m'
    'testBehaviorRepeatability.m'
    'testBehaviorMemory.m'
    'testBehaviorCooldown.m'
    'testDecisionWeights.m'
    'testBehaviorContext.m'
    'testBehaviorOutput.m'
    'testRandomizedMainDifferentRuns.m'
    'testDeterministicRepeatability.m'
    'testRandomMetadata.m'
    'testNoRngOutsideRandomModule.m'
    'testRandomDeterministicRepeatability.m'
    'testRandomizedDifferentRuns.m'
    'testPerTargetSeeds.m'
    'testRandomMetadataExport.m'
};

failed = {};
for testIdx = 1:numel(testScripts)
    testPath = fullfile(projectRoot, 'tests', testScripts{testIdx});
    try
        runTestScript(testPath);
    catch ME
        [~, name, ~] = fileparts(testScripts{testIdx});
        failed{end + 1} = sprintf('%s: %s', name, ME.message); %#ok<AGROW>
    end
end

if ~isempty(failed)
    fprintf('Failed tests (%d):\n', numel(failed));
    for j = 1:numel(failed)
        fprintf('  %s\n', failed{j});
    end
    error('runAllTests:Failures', 'Some tests failed.');
end

disp('All tests passed.');

function runTestScript(testPath)
run(testPath);
end
