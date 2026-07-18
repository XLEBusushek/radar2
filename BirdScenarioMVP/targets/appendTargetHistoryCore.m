function target = appendTargetHistoryCore(target)
% appendTargetHistoryCore - Добавляет только кинематические основные поля.
target.History.Time(end + 1, 1) = target.CurrentTime;
target.History.Position(end + 1, :) = target.Position(:).';
target.History.Velocity(end + 1, :) = target.Velocity(:).';
target.History.Acceleration(end + 1, :) = target.Acceleration(:).';
target.History.State(end + 1, 1) = string(target.State);
target.History.Visible(end + 1, 1) = logical(target.Visible);
target.History.RCS(end + 1, 1) = target.RCS;
end
