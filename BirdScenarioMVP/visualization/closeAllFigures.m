function closeAllFigures()
% closeAllFigures - Закрытие всех окон графиков MATLAB.
figs = findall(0, 'Type', 'figure');
if ~isempty(figs)
    close(figs);
end
end
