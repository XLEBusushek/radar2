function R = getFixedWingDesiredTurnRadius(config)
% getFixedWingDesiredTurnRadius - Единый минимальный радиус разворота для fixed-wing UAV.
arguments
    config (1, 1) struct
end

fw = config.fixedWing;
candidates = 220;

if isfield(fw, 'navigation')
    nav = fw.navigation;
    if isfield(nav, 'desiredTurnRadius')
        candidates(end + 1) = nav.desiredTurnRadius; %#ok<AGROW>
    end
    if isfield(nav, 'arcTurnMinRadius')
        candidates(end + 1) = nav.arcTurnMinRadius; %#ok<AGROW>
    end
end

if isfield(fw, 'turn') && isfield(fw.turn, 'minTurnRadius')
    candidates(end + 1) = fw.turn.minTurnRadius; %#ok<AGROW>
end

if isfield(fw, 'antiBounce') && isfield(fw.antiBounce, 'minTurnRadius')
    candidates(end + 1) = fw.antiBounce.minTurnRadius; %#ok<AGROW>
end

if isfield(fw, 'minTurnRadius')
    candidates(end + 1) = fw.minTurnRadius; %#ok<AGROW>
end

R = max(candidates);
end
