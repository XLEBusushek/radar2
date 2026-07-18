function style = getStatePlotStyle(state)
% getStatePlotStyle - Возврат стиля отображения для состояния FSM птицы.
arguments
    state (1, 1) string
end

state = string(state);

switch state
    case "Perched"
        style.LineStyle = 'none';
        style.LineWidth = 1;
        style.Marker = 'o';
        style.Color = [0.55, 0.27, 0.07];
        style.DisplayName = 'Perched';
    case "Takeoff"
        style.LineStyle = ':';
        style.LineWidth = 1.5;
        style.Marker = 'none';
        style.Color = [0.85, 0.33, 0.10];
        style.DisplayName = 'Takeoff';
    case "Cruise"
        style.LineStyle = '-';
        style.LineWidth = 2;
        style.Marker = 'none';
        style.Color = [0.00, 0.45, 0.74];
        style.DisplayName = 'Cruise';
    case "Landing"
        style.LineStyle = '-.';
        style.LineWidth = 1.5;
        style.Marker = 'none';
        style.Color = [0.47, 0.67, 0.19];
        style.DisplayName = 'Landing';
    case "Hidden"
        style.LineStyle = '-';
        style.LineWidth = 0.5;
        style.Marker = 'none';
        style.Color = [0.6, 0.6, 0.6];
        style.DisplayName = 'Hidden';
    otherwise
        style.LineStyle = '-';
        style.LineWidth = 1;
        style.Marker = 'none';
        style.Color = [0.5, 0.5, 0.5];
        style.DisplayName = char(state);
end
end
