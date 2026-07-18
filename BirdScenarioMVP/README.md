# BirdScenarioMVP

MATLAB-проект для моделирования движения птиц как ложных радиолокационных целей в 3D-мире (2000 м × 2000 м × 500 м).

## Реализованные этапы

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

На этапе 06C полёт птиц исключает локальное кружение и короткие перелёты; аналитические графики открываются в именованных окнах с чистыми легендами.

## Запуск

```matlab
cd('path/to/BirdScenarioMVP')
main
```

`main` запускает симуляцию, открывает 3D-график (если включён), строит аналитические графики и экспортирует результаты в `output/`. По умолчанию каждый запуск использует новое случайное зерно сценария. Интерактивный профиль (`applyRunProfile(config, "interactive")`) отключает пересборку legacy output и пошаговую валидацию для ускорения.

## API симуляции

`runSimulation` возвращает от одного до трёх выходных аргументов в зависимости от `nargout`:

```matlab
[scenario, trajectoryLog, output] = runSimulation(config);
```

| Выход | Описание |
|--------|-------------|
| `scenario` | Финальная структура сценария (`Targets`, типизированные представления, метаданные) |
| `trajectoryLog` | Канонический покадровый лог (`Frames`, `Metadata`, опционально `CsvRows`) |
| `output` | Legacy-массив шагов; строится только при `nargout >= 2` и `config.log.buildLegacyOutput = true` |

Поддерживается legacy-форма с двумя выходами:

```matlab
[scenario, output] = runSimulation(config);  % output опускается при buildLegacyOutput=false
```

После симуляции `main` прикрепляет кэши истории целей и экспортирует из лога:

```matlab
trajectoryLog = attachTargetHistoryCache(trajectoryLog);
exportFromLog(trajectoryLog, config, env);
```

## Режимы рандомизации

Централизованная система рандомизации находится в `config.sim.random`.

Режим демонстрации по умолчанию создаёт новый сценарий при каждом запуске:

```matlab
main
```

Детерминированный режим повторяет тот же сценарий для одного зерна:

```matlab
config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
[scenario, trajectoryLog, output] = runSimulation(config);
```

Случайный режим создаёт новое зерно сценария при каждом запуске:

```matlab
config = defaultConfig();
config.sim.random.mode = "randomized";
[scenario, trajectoryLog, output] = runSimulation(config);
```

Зерно сценария сохраняется в `scenario.Random`, `scenario.Metadata.ScenarioSeed`,
каждом шаге output и столбцах CSV. Каждая цель также получает
`Target.Metadata.RandomSeed`.

Для быстрой демонстрации со случайным сценарием запустите:

```matlab
demoRandomScenario
```

## Выходные файлы

После `main` результаты сохраняются в `output/` (настраивается через `config.export.outputFolder`):

| Файл | Описание |
|------|-------------|
| `bird_scenario_output.mat` | `trajectoryLog`, legacy `output` (если построен) и `config` |
| `bird_scenario_tracks.csv` | Таблица траекторий по временным шагам |
| `bird_scenario_3d.png` | 3D-график траекторий |
| `bird_xy.png` | Вид сверху XY траекторий и деревьев |
| `bird_altitude.png` | Высота vs время для всех птиц |
| `bird_speed.png` | Скорость vs время для всех птиц |
| `bird_states.png` | Временная шкала состояний FSM |
| `bird_visibility.png` | Временная шкала видимости |

### Аналитические графики

- `bird_xy.png` — вид сверху (деревья, траектории, начальные/конечные точки)
- `bird_altitude.png` — высота всех птиц во времени
- `bird_speed.png` — скорость всех птиц с опорными линиями min/max
- `bird_states.png` — состояния FSM (Perched, Takeoff, Cruise, Landing, Hidden)
- `bird_visibility.png` — видимые и скрытые сегменты

### Столбцы CSV

- `Time`, `ID`, `Class`, `Subtype`
- `X`, `Y`, `Z` — положение (м)
- `Vx`, `Vy`, `Vz` — скорость (м/с)
- `RCS`, `Visible`, `State`, `Mission`
- `CurrentTreeID`, `TargetTreeID`
- `TransitionCount`, `TransitionReason`

## Конфигурация лога и экспорта

Запись траектории управляется через `config.log`:

| Флаг | По умолчанию | Описание |
|------|---------|-------------|
| `historyMode` | `"full"` | Пошаговая `target.History`: `"full"`, `"minimal"`, `"off"` (только базовая кинематика), `"none"` (без добавления) |
| `storePayload` | `true` | При `false` `Payload` опускается из кадров лога |
| `storeFullPayload` | `true` | Полный vs компактный payload при `storePayload = true` |
| `buildLegacyOutput` | `true` | Строить legacy `output` внутри `runSimulation` (профили ставят `false`) |
| `incrementalCsv` | `false` | Добавлять строки CSV во время симуляции вместо построения при экспорте |
| `preallocateFrames` | `true` | Предварительно выделять `trajectoryLog.Frames` |
| `legacyPerFrame` | `false` | Хранить покадровый legacy-снимок экспорта в каждом кадре |

Флаги экспорта в `config.export`:

| Флаг | По умолчанию | Описание |
|------|---------|-------------|
| `csvFromLog` | `true` | Строить CSV из `trajectoryLog`; при `false` используется legacy-путь экспорта |
| `matIncludesLegacy` | `false` | Включать legacy `output` в MAT, когда `buildLegacyOutput` был выключен |

Пошаговая валидация целей (`validateTarget` в `updateTarget`) управляется через `config.validation.eachStep` (предпочтительно) или `config.debug.validateEachStep`. По умолчанию `true`; интерактивные/batch/benchmark-профили ставят оба в `false`.

Профили запуска (`applyRunProfile`): `"interactive"`, `"batch"`, `"fast"`, `"benchmark"` — настраивают логирование, экспорт, анализ и валидацию для типичных рабочих процессов.

## Тесты

Запуск всех тестов:

```matlab
run('tests/runAllTests.m')
```

Или отдельные тесты:

```matlab
run('tests/testProjectSkeleton.m')
run('tests/testTrees.m')
% ... полный список см. в папке tests/
run('tests/testVisualization.m')
run('tests/testExportMat.m')
run('tests/testExportCsv.m')
run('tests/testAnalysisPlots.m')
run('tests/testAnalysisExport.m')
```

## Структура

- `config/` — конфигурация (`defaultConfig()` собирает модульные секции)
- `log/` — запись TrajectoryLog (`logFrame`, `createTrajectoryLog`, построители payload)
- `core/` — оркестрация симуляции
  - `core/output/` — модульные построители полей `collectOutput`
- `environment/` — деревья и мир
- `targets/` — универсальная модель цели (`createTargets`, `splitTargetsByType`)
- `birds/` — FSM птиц, кинематика, крейсер и посадка
- `air/` — логика воздушных аппаратов
  - `air/quadcopter/` — FSM и кинематика квадрокоптера
  - `air/fixedwing_legacy/` — legacy БПЛА при `fixedWing2.enabled = false`
  - `air/fixedwing2/` — активный БПЛА при `fixedWing2.enabled = true`
  - `air/common/` — общие воздушные утилиты (напр. расстояние до границы)
- `rcs/` — назначение RCS
- `utils/` — вспомогательные функции
- `visualization/` — 3D-отрисовка
- `analysis/` — аналитические графики из `History`
- `export/` — экспорт MAT, CSV и графиков
- `random/` — централизованные зерна и функции случайных чисел
- `output/` — результаты экспорта симуляции (создаётся `main`)
- `tests/` — тесты проекта

### Режимы БПЛА с неподвижным крылом

| Конфигурация | Реализация |
|--------|----------------|
| `config.fixedWing2.enabled = true` | `air/fixedwing2/` (по умолчанию в `main`) |
| `config.fixedWing2.enabled = false` | legacy-пайплайн `air/*FixedWing*` |

`scenario.Targets` — источник истины; типизированные представления (`Birds`, `Quadcopters`, …) пересобираются через `syncScenarioTargetViews` с использованием кэшированных `scenario.TargetIndices`.
