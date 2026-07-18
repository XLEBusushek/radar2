function vehicles = createGroundVehicles(config, roadNetwork, startId)
% createGroundVehicles - Фабрика совместимости (используйте createTargets).
arguments
    config (1, 1) struct
    roadNetwork (1, 1) struct
    startId (1, 1) {mustBePositive, mustBeInteger} = 1
end

if ~isfield(config, 'groundVehicle') || ~isfield(config.groundVehicle, 'count')
    error('createGroundVehicles:MissingField', 'config.groundVehicle.count is required.');
end

numVehicles = config.groundVehicle.count;
if numVehicles == 0
    vehicles = struct([]);
    return;
end

for i = 1:numVehicles
    vehicles(i) = createGroundVehicleTarget(startId + i - 1, config, roadNetwork); %#ok<AGROW>
end
end
