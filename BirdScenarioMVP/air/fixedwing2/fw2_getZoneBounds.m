function zones = fw2_getZoneBounds(config)
% fw2_getZoneBounds - Safe, warning, and critical zone rectangles.
worldX = config.world.size(1);
worldY = config.world.size(2);
fw2 = config.fixedWing2;
safeM = fw2.safeZone.margin;
warnM = fw2.warningZone.margin;
critM = fw2.criticalZone.margin;
zones.World = [0, worldX, 0, worldY];
zones.SafeZone = [safeM, worldX - safeM, safeM, worldY - safeM];
zones.WarningZone = [warnM, worldX - warnM, warnM, worldY - warnM];
zones.CriticalZone = [critM, worldX - critM, critM, worldY - critM];
zones.SafeMargin = safeM;
zones.WarningMargin = warnM;
zones.CriticalMargin = critM;
end
