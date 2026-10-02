# UAV propeller BEMT trade study

MATLAB source by Aidan Law for the drone propeller portfolio project.

## Run

Open `bemt_trade_study.m` in MATLAB and run it, or execute `run('bemt_trade_study.m')`.

Tested in MATLAB R2024b. The script prints design-point and assumed maximum-RPM results and creates a four-panel dashboard. Its solver is included as a local function.

## Model

- Two blades, 7.5-inch diameter, 30 midpoint radial elements.
- Air density: 1.225 kg/m^3.
- Design speed: 8,500 RPM; assumed ceiling: 16,000 RPM.
- Hover target: 170 grams-force per motor.
- Five baseline/bullnose/elliptical configurations with prescribed pitch and camber.
- Iterative inflow, Prandtl tip/hub corrections, simplified airfoil polars and stall model.

`results.csv` records output from the supplied script; CSV export was performed after execution. Thrust is in grams-force or newtons, power is mechanical shaft power, and figure of merit is dimensionless.

## Interpretation

These are model predictions, not measured test results. Motor and ESC losses are excluded. The assumed ceiling is not a verified motor rating or structural limit. This script does not perform structural FEA or establish commercial benchmark performance. Airfoil and stall simplifications can strongly affect comparisons near stall.

[Portfolio project](https://aidanlaw.me/drone-blade-design.html)
