function target = updateTarget(target, scenario, config, dt)
% updateTarget - Update a single target for one simulation step.
arguments
    target (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

switch string(target.Class)
    case "bird"
        target = updateBirdBehavior(target, scenario, config, dt);
        target = updateBirdKinematics(target, config, dt);
    case "air"
        if string(target.Subtype) == "quadcopter"
            target = updateQuadcopterBehavior(target, scenario, config, dt);
            target = updateQuadcopterKinematics(target, config, dt);
            if isfield(config.quadcopter, 'navigation') && config.quadcopter.navigation.enabled
                target = updateQuadcopterExcursionMetrics(target);
            end
            if string(target.State) == "Landing" && ...
                    target.Position(3) <= config.quadcopter.landingAltitudeThreshold
                target.Position(3) = 0;
                target.Velocity = zeros(3, 1);
                target.Acceleration = zeros(3, 1);
                target.Payload.MissionComplete = true;
                target = transitionQuadcopterState(target, "Idle", "landed", config);
            end
        elseif string(target.Subtype) == "fixedWingUAV"
            if isfield(config, 'fixedWing2') && config.fixedWing2.enabled
                target = fw2_updateFixedWingTarget(target, scenario, config, dt);
            else
                target = updateFixedWingBehavior(target, scenario, config, dt);
                target = updateFixedWingKinematics(target, config, dt);
                target = updateFixedWingNavigationDiagnostics(target, config);
            end
        else
            error('updateTarget:UnsupportedSubtype', ...
                'Unsupported air subtype: %s', string(target.Subtype));
        end
    case "ground"
        if string(target.Subtype) == "vehicle"
            target = updateGroundBehavior(target, scenario, config, dt);
            target = updateGroundKinematics(target, config, dt);
        else
            error('updateTarget:UnsupportedSubtype', ...
                'Unsupported ground subtype: %s', string(target.Subtype));
        end
    otherwise
        error('updateTarget:UnsupportedClass', ...
            'Unsupported target class: %s', string(target.Class));
end

target.CurrentTime = target.CurrentTime + dt;
target.TimeInState = target.TimeInState + dt;

if string(target.Class) == "bird" && string(target.State) == "Landing" && ...
        isfield(config.birds, 'landing') && config.birds.landing.enabled && ...
        isBirdLandingComplete(target, config)
    target.Payload.LandingComplete = true;
    if ~isempty(target.Payload.LandingTargetPoint)
        landingDist = norm(target.Payload.LandingTargetPoint(:) - target.Position(:));
        if landingDist > config.birds.landing.touchdownDistance
            target.Position = target.Payload.LandingTargetPoint(:);
            target.Velocity = zeros(3, 1);
            target.Acceleration = zeros(3, 1);
        end
    end
end

target.StateMatrix = computeStateMatrix(target.Position, target.Velocity);
target = appendTargetHistory(target, config);
if shouldValidateEachStep(config)
    validateTarget(target, config);
end
end
