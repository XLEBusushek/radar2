function zones = getFixedWingZoneBounds(config)
% getFixedWingZoneBounds - Вычислить прямоугольники зон Safe, Warning и Critical.
arguments
    config (1, 1) struct
end

worldX = config.world.size(1);
worldY = config.world.size(2);
zoneCfg = config.fixedWing.zones;

safeMargin = zoneCfg.safeMargin;
warningInner = zoneCfg.warningInner;
criticalInner = zoneCfg.criticalInner;

zones.World = [0, worldX, 0, worldY];
zones.SafeZone = [safeMargin, worldX - safeMargin, safeMargin, worldY - safeMargin];
zones.WarningZone = [warningInner, worldX - warningInner, warningInner, worldY - warningInner];
zones.CriticalZone = [criticalInner, worldX - criticalInner, criticalInner, worldY - criticalInner];
zones.SafeMargin = safeMargin;
zones.WarningInner = warningInner;
zones.CriticalInner = criticalInner;
end
