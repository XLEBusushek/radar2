function configureScenarioFigure(fig, config)
% configureScenarioFigure - Apply renderer settings for 3D scenario figures.
arguments
    fig
    config (1, 1) struct
end

if ~isgraphics(fig, 'figure')
    return;
end

if isFast3DVisualization(config)
  fig.GraphicsSmoothing = 'off';
  ax = findobj(fig, 'Type', 'axes');
  for i = 1:numel(ax)
      ax(i).SortMethod = 'childorder';
  end
end
end
