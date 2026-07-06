function closeAllFigures()
% closeAllFigures - Close every MATLAB figure window.
figs = findall(0, 'Type', 'figure');
if ~isempty(figs)
    close(figs);
end
end
