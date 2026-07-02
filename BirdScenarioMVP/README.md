# BirdScenarioMVP

MATLAB project for simulating bird movement as false radar targets in a 3D world (2000 m × 2000 m × 500 m).

## Implemented stages

- ТЗ-01 Project Skeleton
- ТЗ-02 Environment Trees
- ТЗ-03 Target Model + Bird Initialization
- ТЗ-04 Simulation Engine + History + Output
- ТЗ-05A Bird Probabilistic FSM
- ТЗ-05B Bird Takeoff + Basic Kinematics
- ТЗ-05C Bird Curved Cruise
- ТЗ-05D Bird Landing + Hidden + Full Tree-to-Tree Cycle
- ТЗ-05E Bird Realism Polish
- ТЗ-06 Visualization + Export
- ТЗ-06B Analysis Visualization
- ТЗ-06C Bird Behavior & Visualization Fix
- ТЗ-R01 Global Randomization Fix

At stage 06C, bird flight avoids local circling and short hops, and analysis figures open in named windows with clean legends.

## Run

```matlab
cd('path/to/BirdScenarioMVP')
main
```

`main` runs the simulation, opens a 3D plot (if enabled), builds analysis figures, and exports results to `output/`. By default, each run uses a new randomized scenario seed.

## Randomization modes

The simulation has a centralized randomization system under `config.sim.random`.

Default demonstration mode creates a new scenario each time:

```matlab
main
```

Deterministic mode repeats the same scenario for the same seed:

```matlab
config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
[scenario, output] = runSimulation(config);
```

Randomized mode creates a new scenario seed on each run:

```matlab
config = defaultConfig();
config.sim.random.mode = "randomized";
[scenario, output] = runSimulation(config);
```

The scenario seed is saved in `scenario.Random`, `scenario.Metadata.ScenarioSeed`,
each output step, and CSV columns. Each target also receives
`Target.Metadata.RandomSeed`.

For a quick randomized demo, run:

```matlab
demoRandomScenario
```

## Output files

After `main`, results are saved under `output/` (configurable via `config.export.outputFolder`):

| File | Description |
|------|-------------|
| `bird_scenario_output.mat` | Full `scenario`, `output`, and `config` structs |
| `bird_scenario_tracks.csv` | Per-timestep track table |
| `bird_scenario_3d.png` | 3D trajectory figure |
| `bird_xy.png` | Top-down XY view of trajectories and trees |
| `bird_altitude.png` | Altitude vs time for all birds |
| `bird_speed.png` | Speed vs time for all birds |
| `bird_states.png` | FSM state timeline |
| `bird_visibility.png` | Visibility timeline |

### Analysis figures

- `bird_xy.png` — top-down view (trees, trajectories, start/end points)
- `bird_altitude.png` — altitude of all birds over time
- `bird_speed.png` — speed of all birds with reference lines at min/max speed
- `bird_states.png` — FSM states (Perched, Takeoff, Cruise, Landing, Hidden)
- `bird_visibility.png` — visible vs hidden segments

### CSV columns

- `Time`, `ID`, `Class`, `Subtype`
- `X`, `Y`, `Z` — position (m)
- `Vx`, `Vy`, `Vz` — velocity (m/s)
- `RCS`, `Visible`, `State`, `Mission`
- `CurrentTreeID`, `TargetTreeID`
- `TransitionCount`, `TransitionReason`

## Tests

Run all tests:

```matlab
run('tests/runAllTests.m')
```

Or run individual tests:

```matlab
run('tests/testProjectSkeleton.m')
run('tests/testTrees.m')
% ... see tests/ folder for full list
run('tests/testVisualization.m')
run('tests/testExportMat.m')
run('tests/testExportCsv.m')
run('tests/testAnalysisPlots.m')
run('tests/testAnalysisExport.m')
```

## Structure

- `config/` — configuration
- `core/` — simulation orchestration
- `environment/` — trees and world
- `targets/` — universal target model
- `birds/` — bird FSM, kinematics, cruise, and landing
- `rcs/` — RCS assignment
- `utils/` — helper functions
- `visualization/` — 3D plotting
- `analysis/` — analytical plots from `History`
- `export/` — MAT, CSV, and figure export
- `random/` — centralized random seeds and random helper functions
- `output/` — simulation export results (created by `main`)
- `tests/` — project tests
