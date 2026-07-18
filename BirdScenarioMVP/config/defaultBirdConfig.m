function config = defaultBirdConfig(config)
% defaultBirdConfig - Значения по умолчанию для поведения и движения птиц.
config.birds.count = 10;
config.birds.rcsRange = [0.001, 0.03];
config.birds.initialState = "Perched";
config.birds.initialVisible = false;
config.birds.initialMission = "TreeToTree";
config.birds.perchTimeRange = [5, 60];
config.birds.hiddenTimeRange = [2, 20];
config.birds.takeoffTimeRange = [2, 8];

config.birds.motion.speedRange = [5, 15];
config.birds.motion.cruiseSpeedRange = [7, 13];
config.birds.motion.takeoffSpeedRange = [3, 8];
config.birds.motion.maxAcceleration = 6;
config.birds.motion.maxVerticalSpeed = 3;
config.birds.motion.takeoffClimbRateRange = [1.0, 3.0];
config.birds.motion.takeoffAltitudeGainRange = [8, 20];
config.birds.motion.cruiseAltitudeRange = [20, 120];
config.birds.motion.arrivalRadius = 25;
config.birds.motion.directionBlend = 0.15;

config.birds.curvedCruise.enabled = true;
config.birds.curvedCruise.lateralAmplitudeRange = [10, 35];
config.birds.curvedCruise.verticalAmplitudeRange = [3, 12];
config.birds.curvedCruise.maneuverDistanceRange = [20, 50];
config.birds.curvedCruise.maneuverAngleRangeDeg = [-35, 35];
config.birds.curvedCruise.curveBlend = 0.25;
config.birds.curvedCruise.noiseStrength = 0.08;
config.birds.curvedCruise.altitudeChangeProbability = 0.08;
config.birds.curvedCruise.directionChangeProbability = 0.06;
config.birds.curvedCruise.minCruiseAltitude = 10;
config.birds.curvedCruise.maxCruiseAltitude = 120;

config.birds.landing.enabled = true;
config.birds.landing.approachRadius = 80;
config.birds.landing.finalRadius = 8;
config.birds.landing.speedRange = [2, 7];
config.birds.landing.finalSpeed = 1.5;
config.birds.landing.descentRateRange = [0.5, 2.5];
config.birds.landing.maxVerticalSpeed = 2.5;
config.birds.landing.targetJitterRadius = 2.0;
config.birds.landing.touchdownDistance = 3.0;
config.birds.landing.maxLandingTime = 25;
config.birds.landing.abortIfTooFar = false;

config.birds.fsm.enabled = true;
config.birds.fsm.perched.minTime = 5;
config.birds.fsm.perched.maxTime = 60;
config.birds.fsm.perched.takeoffProbability = 0.05;

config.birds.fsm.takeoff.minTime = 2;
config.birds.fsm.takeoff.maxTime = 8;
config.birds.fsm.takeoff.cruiseProbability = 0.35;

config.birds.fsm.cruise.minTime = 10;
config.birds.fsm.cruise.maxTime = 80;
config.birds.fsm.cruise.landingProbability = 0.08;

config.birds.fsm.landing.minTime = 2;
config.birds.fsm.landing.maxTime = 10;
config.birds.fsm.landing.hiddenProbability = 0.40;

config.birds.fsm.hidden.minTime = 2;
config.birds.fsm.hidden.maxTime = 20;
config.birds.fsm.hidden.perchedProbability = 0.25;

config.birds.realism.enabled = true;

config.birds.realism.retargetProbability = 0.03;
config.birds.realism.flyByProbability = 0.08;
config.birds.realism.circleBeforeLandingProbability = 0.05;

config.birds.realism.sharpManeuverProbability = 0.04;
config.birds.realism.sharpManeuverAngleRangeDeg = [-60, 60];
config.birds.realism.sharpManeuverDurationRange = [1, 4];

config.birds.realism.straightFlightProbability = 0.20;
config.birds.realism.strongCurveProbability = 0.20;

config.birds.realism.sameTreeAvoidanceProbability = 0.95;
config.birds.realism.nearTreePreferenceProbability = 0.65;
config.birds.realism.nearTreeRadius = 400;

config.birds.realism.circleRadiusRange = [15, 35];
config.birds.realism.circleDurationRange = [3, 8];

config.birds.realism.randomPauseInPerchedProbability = 0.10;
config.birds.realism.minTargetTreeDistance = 250;
config.birds.realism.maxTargetSelectionAttempts = 30;
config.birds.realism.noProgressTimeLimit = 12;
config.birds.realism.directCourseBlend = 0.9;
config.birds.realism.maxSequentialFlyBy = 1;
end
