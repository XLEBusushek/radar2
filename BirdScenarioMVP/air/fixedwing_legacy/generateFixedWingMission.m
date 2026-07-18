function mission = generateFixedWingMission(homePosition, initialHeading, config)
% generateFixedWingMission - Сгенерировать маршруты fixed-wing только внутри Safe Zone.
arguments
    homePosition (3, 1) double
    initialHeading (1, 1) double
    config (1, 1) struct
end

mission = generateSafeMission(homePosition, initialHeading, config);
end
