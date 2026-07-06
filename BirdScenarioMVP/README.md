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

`main` runs the simulation, opens a 3D plot (if enabled), builds analysis figures, and exports results to `output/`. By default, each run uses a new randomized scenario seed. The interactive profile (`applyRunProfile(config, "interactive")`) disables legacy output rebuild and per-step validation for faster runs.

## Simulation API

`runSimulation` returns one to three outputs depending on `nargout`:

```matlab
[scenario, trajectoryLog, output] = runSimulation(config);
```

| Output | Description |
|--------|-------------|
| `scenario` | Final scenario struct (`Targets`, typed views, metadata) |
| `trajectoryLog` | Canonical per-frame log (`Frames`, `Metadata`, optional `CsvRows`) |
| `output` | Legacy step array; built only when `nargout >= 2` and `config.log.buildLegacyOutput` is `true` |

Legacy two-output form is still supported:

```matlab
[scenario, output] = runSimulation(config);  % output omitted when buildLegacyOutput=false
```

After simulation, `main` attaches target history caches and exports from the log:

```matlab
trajectoryLog = attachTargetHistoryCache(trajectoryLog);
exportFromLog(trajectoryLog, config, env);
```

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
[scenario, trajectoryLog, output] = runSimulation(config);
```

Randomized mode creates a new scenario seed on each run:

```matlab
config = defaultConfig();
config.sim.random.mode = "randomized";
[scenario, trajectoryLog, output] = runSimulation(config);
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
| `bird_scenario_output.mat` | `trajectoryLog`, legacy `output` (if built), and `config` |
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

## Log and export configuration

Trajectory recording is controlled by `config.log`:

| Flag | Default | Description |
|------|---------|-------------|
| `historyMode` | `"full"` | Per-step `target.History`: `"full"`, `"minimal"`, `"off"` (core kinematics only), `"none"` (no append) |
| `storePayload` | `true` | When `false`, `Payload` is omitted from log frames |
| `storeFullPayload` | `true` | Full vs compact payload when `storePayload` is `true` |
| `buildLegacyOutput` | `true` | Build legacy `output` inside `runSimulation` (profiles set `false`) |
| `incrementalCsv` | `false` | Append CSV rows during simulation instead of export-time build |
| `preallocateFrames` | `true` | Preallocate `trajectoryLog.Frames` |
| `legacyPerFrame` | `false` | Store per-frame legacy export snapshot in each frame |

Export flags under `config.export`:

| Flag | Default | Description |
|------|---------|-------------|
| `csvFromLog` | `true` | Build CSV from `trajectoryLog`; when `false`, uses legacy export path |
| `matIncludesLegacy` | `false` | Include legacy `output` in MAT when `buildLegacyOutput` was off |

Per-step target validation (`validateTarget` in `updateTarget`) is controlled by `config.validation.eachStep` (preferred) or `config.debug.validateEachStep`. Defaults to `true`; interactive/batch/benchmark profiles set both to `false`.

Run profiles (`applyRunProfile`): `"interactive"`, `"batch"`, `"fast"`, `"benchmark"` — tune logging, export, analysis, and validation for typical workflows.

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

- `config/` — configuration (`defaultConfig()` assembles section modules)
- `log/` — TrajectoryLog recording (`logFrame`, `createTrajectoryLog`, payload builders)
- `core/` — simulation orchestration
  - `core/output/` — modular `collectOutput` field builders
- `environment/` — trees and world
- `targets/` — universal target model (`createTargets`, `splitTargetsByType`)
- `birds/` — bird FSM, kinematics, cruise, and landing
- `air/` — air vehicle logic
  - `air/quadcopter/` — quadcopter FSM and kinematics
  - `air/fixedwing_legacy/` — legacy fixed-wing when `fixedWing2.enabled = false`
  - `air/fixedwing2/` — active fixed-wing when `fixedWing2.enabled = true`
  - `air/common/` — shared air utilities (e.g. boundary distance)
- `rcs/` — RCS assignment
- `utils/` — helper functions
- `visualization/` — 3D plotting
- `analysis/` — analytical plots from `History`
- `export/` — MAT, CSV, and figure export
- `random/` — centralized random seeds and random helper functions
- `output/` — simulation export results (created by `main`)
- `tests/` — project tests

### Fixed-wing modes

| Config | Implementation |
|--------|----------------|
| `config.fixedWing2.enabled = true` | `air/fixedwing2/` (default in `main`) |
| `config.fixedWing2.enabled = false` | legacy `air/*FixedWing*` pipeline |

`scenario.Targets` is the source of truth; typed views (`Birds`, `Quadcopters`, …) are rebuilt via `syncScenarioTargetViews` using cached `scenario.TargetIndices`.
