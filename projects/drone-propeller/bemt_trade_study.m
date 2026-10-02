% =========================================================================
% MASTER TRADE STUDY: UAV PROPELLER AERO-STRUCTURAL OPTIMIZATION
% Architect: Aidan Law
%
% Methodology: Iterative Blade Element Momentum Theory (BEMT) with
%              Prandtl tip/hub loss and a simplified stall model.
%
% Target Hover Thrust: 170 g per motor (680 g quad)
% Design Point: 8,500 RPM | 7.5-inch propeller
% =========================================================================

clear; clc; close all;

%% 1. GLOBAL ENVIRONMENT & OPERATING CONDITIONS

env.rho = 1.225;                   % Air density [kg/m^3]
env.nu  = 1.48e-5;                 % Kinematic viscosity [m^2/s]

RPM_design = 8500;                 % Design operating point
RPM_max    = 16000;                % Assumed maximum operating RPM

Hover_Target_g = 170;              % Required thrust [grams-force]

%% 2. GEOMETRIC DOMAIN & DISCRETIZATION

Nblades = 2;
D_inch  = 7.5;

R_tip = (D_inch * 0.0254) / 2;      % Tip radius [m]
R_hub = 0.009525;                  % Hub radius [m]

% Midpoint-evaluated radial elements
N_elem  = 30;
r_edges = linspace(R_hub, R_tip, N_elem + 1);
r       = 0.5 * (r_edges(1:end-1) + r_edges(2:end));
dr      = diff(r_edges);

% Radial stations for CAD lofting
SCALE = 1.5;

chord_ref_base = ...
    [12, 13, 14, 15, 15, 15, 14, 13, 11, 8] * SCALE * 1e-3;

chord_ref_bull = ...
    [14, 15, 16, 17, 18, 18, 19, 19, 18, 17] * SCALE * 1e-3;

chord_ref_ellip = ...
    [10, 13, 16, 18, 19, 18, 16, 13, 9, 5] * SCALE * 1e-3;

r_ref = linspace(R_hub, R_tip, 10);

c_base  = interp1(r_ref, chord_ref_base,  r, 'pchip');
c_bull  = interp1(r_ref, chord_ref_bull,  r, 'pchip');
c_ellip = interp1(r_ref, chord_ref_ellip, r, 'pchip');

%% 3. TRADE STUDY CONFIGURATION MATRIX

% Baseline
configs(1).name       = 'Base';
configs(1).chord      = c_base;
configs(1).pitch_deg  = 16.0;
configs(1).camber_pct = 1.5;
configs(1).CD0        = 0.024;
configs(1).color      = [0.58, 0.60, 0.64];

% Bullnose aggressive
configs(2).name       = 'Bull-Agg';
configs(2).chord      = c_bull;
configs(2).pitch_deg  = 18.0;
configs(2).camber_pct = 2.0;
configs(2).CD0        = 0.028;
configs(2).color      = [0.35, 0.65, 0.80];

% Bullnose efficient
configs(3).name       = 'Bull-Eff';
configs(3).chord      = c_bull;
configs(3).pitch_deg  = 14.0;
configs(3).camber_pct = 1.0;
configs(3).CD0        = 0.020;
configs(3).color      = [0.40, 0.68, 0.58];

% Elliptical aggressive
configs(4).name       = 'Ellip-Agg';
configs(4).chord      = c_ellip;
configs(4).pitch_deg  = 18.0;
configs(4).camber_pct = 2.0;
configs(4).CD0        = 0.028;
configs(4).color      = [0.62, 0.52, 0.72];

% Elliptical efficient
configs(5).name       = 'Ellip-Eff';
configs(5).chord      = c_ellip;
configs(5).pitch_deg  = 14.0;
configs(5).camber_pct = 1.0;
configs(5).CD0        = 0.020;
configs(5).color      = [0.85, 0.58, 0.35];

%% 4. EXECUTE BEMT SOLVER

num_cfg = length(configs);

clear res_design res_max;

for i = num_cfg:-1:1
    res_design(i) = solve_BEMT( ...
        configs(i), RPM_design, r, dr, ...
        R_hub, R_tip, Nblades, env);

    res_max(i) = solve_BEMT( ...
        configs(i), RPM_max, r, dr, ...
        R_hub, R_tip, Nblades, env);
end

%% 5. CONSOLE REPORT & HEADROOM ASSESSMENT

fprintf('========================================================================================\n');
fprintf('                BEMT TRADE STUDY RESULTS @ DESIGN POINT (%d RPM)\n', RPM_design);
fprintf('========================================================================================\n');

fprintf('%-10s | %10s | %10s | %10s | %12s | %8s\n', ...
    'Config', 'Thrust(g)', 'Thrust(N)', ...
    '% Target', 'Shaft Pwr(W)', 'FM');

fprintf('----------------------------------------------------------------------------------------\n');

for i = 1:num_cfg
    fprintf('%-10s | %10.1f | %10.2f | %9.0f%% | %12.2f | %8.3f\n', ...
        configs(i).name, ...
        res_design(i).Thrust_g, ...
        res_design(i).Thrust_N, ...
        (res_design(i).Thrust_g / Hover_Target_g) * 100, ...
        res_design(i).Power_W, ...
        res_design(i).FM);
end

fprintf('\n========================================================================================\n');
fprintf('                 MOTOR HEADROOM & CEILING AUDIT @ MAX RPM (%d RPM)\n', RPM_max);
fprintf('========================================================================================\n');

fprintf('%-10s | %12s | %18s | %14s\n', ...
    'Config', 'Max Thrust(g)', 'Target as %Max', 'Max Power(W)');

fprintf('----------------------------------------------------------------------------------------\n');

for i = 1:num_cfg
    pct_max = (Hover_Target_g / res_max(i).Thrust_g) * 100;

    fprintf('%-10s | %12.1f | %17.1f%% | %14.1f\n', ...
        configs(i).name, ...
        res_max(i).Thrust_g, ...
        pct_max, ...
        res_max(i).Power_W);
end

fprintf('========================================================================================\n\n');

%% 6. DASHBOARD

bg_fig  = [0.098, 0.106, 0.122];
bg_axis = [0.098, 0.106, 0.122];
grid_c  = [1, 1, 1];
txt_dim = [0.66, 0.68, 0.72];
txt_hi  = [0.95, 0.96, 0.98];

fig = figure( ...
    'Name', 'BEMT UAV Propeller Aero-Structural Optimization', ...
    'Color', bg_fig, ...
    'Position', [60, 60, 1200, 820]);

t = tiledlayout(fig, 2, 2, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

sgtitle(t, sprintf( ...
    'BEMT Trade Study - 7.5" UAV Rotor Analysis (%d RPM)', RPM_design), ...
    'Color', txt_hi, ...
    'FontSize', 15, ...
    'FontWeight', 'bold', ...
    'FontName', 'Helvetica');

format_clean = @(ax) set(ax, ...
    'Color', bg_axis, ...
    'XColor', txt_dim, ...
    'YColor', txt_dim, ...
    'GridColor', grid_c, ...
    'GridAlpha', 0.08, ...
    'FontName', 'Helvetica', ...
    'FontSize', 9.5, ...
    'Box', 'off', ...
    'LineWidth', 0.75, ...
    'TickLength', [0, 0], ...
    'XGrid', 'on', ...
    'YGrid', 'on');

% Tile 1: Chord distributions
ax1 = nexttile(t, 1);
hold(ax1, 'on');

plot(ax1, r * 1000, c_base * 1000, '-', ...
    'LineWidth', 2.0, 'Color', configs(1).color);

plot(ax1, r * 1000, c_bull * 1000, '-', ...
    'LineWidth', 2.0, 'Color', configs(2).color);

plot(ax1, r * 1000, c_ellip * 1000, '-', ...
    'LineWidth', 2.0, 'Color', configs(4).color);

format_clean(ax1);

title(ax1, 'Chord Schedules (mm)', ...
    'Color', txt_hi, 'FontSize', 11);

xlabel(ax1, 'Radial Position r (mm)', 'Color', txt_dim);
ylabel(ax1, 'Chord c (mm)', 'Color', txt_dim);

lgd1 = legend(ax1, ...
    'Baseline', 'Bullnose', 'Elliptical', ...
    'Location', 'SouthEast');

set(lgd1, ...
    'TextColor', txt_hi, ...
    'Color', bg_axis, ...
    'EdgeColor', [0.25, 0.27, 0.32]);

% Tile 2: Spanwise angle of attack
ax2 = nexttile(t, 2);
hold(ax2, 'on');

compare_idx = [1, 2, 5];
h_alpha = gobjects(1, length(compare_idx));

for k = 1:length(compare_idx)
    i = compare_idx(k);

    h_alpha(k) = plot(ax2, ...
        r * 1000, res_design(i).alpha_deg, '-', ...
        'LineWidth', 1.8, ...
        'Color', configs(i).color);
end

yline(ax2, 12, '--', 'Reference: 12 deg', ...
    'LabelHorizontalAlignment', 'left', ...
    'Color', [0.85, 0.35, 0.35], ...
    'FontSize', 8.5);

format_clean(ax2);

title(ax2, 'Spanwise Angle of Attack \alpha(r)', ...
    'Color', txt_hi, 'FontSize', 11);

xlabel(ax2, 'Radial Position r (mm)', 'Color', txt_dim);
ylabel(ax2, 'Angle of Attack \alpha (deg)', 'Color', txt_dim);

lgd2 = legend(ax2, h_alpha, ...
    {configs(compare_idx).name}, ...
    'Location', 'NorthEast');

set(lgd2, ...
    'TextColor', txt_hi, ...
    'Color', bg_axis, ...
    'EdgeColor', [0.25, 0.27, 0.32]);

% Tile 3: Sectional thrust loading across all blades
ax3 = nexttile(t, 3);
hold(ax3, 'on');

for i = 1:num_cfg
    line_style = '-';

    if contains(configs(i).name, 'Eff')
        line_style = '--';
    end

    plot(ax3, r * 1000, res_design(i).dT_dr, line_style, ...
        'LineWidth', 1.8, ...
        'Color', configs(i).color);
end

format_clean(ax3);

title(ax3, 'Sectional Thrust dT/dr (N/m, All Blades)', ...
    'Color', txt_hi, 'FontSize', 11);

xlabel(ax3, 'Radial Position r (mm)', 'Color', txt_dim);
ylabel(ax3, 'Force Density (N/m)', 'Color', txt_dim);

lgd3 = legend(ax3, {configs.name}, ...
    'Location', 'NorthWest');

set(lgd3, ...
    'TextColor', txt_hi, ...
    'Color', bg_axis, ...
    'EdgeColor', [0.25, 0.27, 0.32], ...
    'FontSize', 8);

% Tile 4: Thrust and shaft power
ax4 = nexttile(t, 4);

yyaxis(ax4, 'left');
hold(ax4, 'on');

all_thrusts = [res_design.Thrust_g];
all_powers  = [res_design.Power_W];

b = bar(ax4, 1:num_cfg, all_thrusts, 0.45, ...
    'FaceColor', 'flat', ...
    'EdgeColor', 'none');

for i = 1:num_cfg
    b.CData(i, :) = configs(i).color;
end

yline(ax4, Hover_Target_g, '--', ...
    sprintf('Target: %d g', Hover_Target_g), ...
    'Color', txt_dim, ...
    'LineWidth', 1.1, ...
    'LabelHorizontalAlignment', 'left', ...
    'FontSize', 8.5);

ylabel(ax4, 'Total Thrust (grams-force)', 'Color', txt_dim);
ylim(ax4, [0, max([all_thrusts, Hover_Target_g]) * 1.3]);

yyaxis(ax4, 'right');

plot(ax4, 1:num_cfg, all_powers, '-d', ...
    'Color', [0.9, 0.9, 0.95], ...
    'LineWidth', 1.8, ...
    'MarkerFaceColor', [0.9, 0.9, 0.95], ...
    'MarkerSize', 6);

ylabel(ax4, 'Shaft Power (W)', 'Color', [0.9, 0.9, 0.95]);
ylim(ax4, [0, max(all_powers) * 1.4]);

format_clean(ax4);

ax4.YAxis(1).Color = txt_dim;
ax4.YAxis(2).Color = [0.9, 0.9, 0.95];

set(ax4, ...
    'XTick', 1:num_cfg, ...
    'XTickLabel', {configs.name});

title(ax4, 'Hover Performance & Power Draw', ...
    'Color', txt_hi, 'FontSize', 11);

%% =========================================================================
% BEMT SOLVER FUNCTION
% =========================================================================

function out = solve_BEMT(cfg, RPM, r, dr, R_hub, R_tip, Nb, env)

    omega = RPM * (2 * pi / 60);
    theta = deg2rad(cfg.pitch_deg);

    % Simplified airfoil polar
    alpha_0 = deg2rad(-1.15 * cfg.camber_pct);
    Cla = 2 * pi * 0.90;

    % Preallocate sectional arrays
    N = length(r);

    phi       = zeros(1, N);
    alpha     = zeros(1, N);
    Cl        = zeros(1, N);
    Cd        = zeros(1, N);
    dT        = zeros(1, N);
    dQ        = zeros(1, N);
    F_prandtl = zeros(1, N);

    for j = 1:N
        rj = r(j);
        cj = cfg.chord(j);

        sigma_local = (Nb * cj) / (2 * pi * rj);

        phi_guess = 0.05;
        max_iter  = 100;
        tol       = 1e-6;

        for iter = 1:max_iter

            % Local angle of attack
            alpha_j   = theta - phi_guess;
            alpha_eff = alpha_j - alpha_0;

            % Linear pre-stall / simplified post-stall polar
            if alpha_eff < deg2rad(12) && alpha_eff > deg2rad(-8)
                Cl_j = Cla * alpha_eff;
                Cd_j = cfg.CD0 + 1.2 * (Cl_j / (pi * 3.5))^2;
            else
                Cl_j = 1.1 * sin(2 * alpha_eff);
                Cd_j = cfg.CD0 + 2.0 * sin(alpha_eff)^2;
            end

            % Prandtl tip loss
            f_tip = (Nb / 2) * (R_tip - rj) / ...
                (rj * max(sin(phi_guess), 1e-4));

            F_tip = (2 / pi) * acos(exp(-min(f_tip, 20)));

            % Prandtl hub loss
            f_hub = (Nb / 2) * (rj - R_hub) / ...
                (R_hub * max(sin(phi_guess), 1e-4));

            F_hub = (2 / pi) * acos(exp(-min(f_hub, 20)));

            F_total = max(F_tip * F_hub, 1e-4);

            % Thrust-direction force coefficient
            Cy = Cl_j * cos(phi_guess) - Cd_j * sin(phi_guess);

            % Annular momentum balance
            sin_phi_new_sq = (sigma_local * Cy) / (8 * F_total);

            if sin_phi_new_sq > 0
                phi_next = asin(min(sqrt(sin_phi_new_sq), 0.95));
            else
                phi_next = 1e-4;
            end

            if abs(phi_next - phi_guess) < tol
                phi_guess = phi_next;
                break;
            end

            phi_guess = 0.6 * phi_guess + 0.4 * phi_next;
        end

        % Final sectional state
        phi(j)   = phi_guess;
        alpha(j) = theta - phi_guess;

        % Reevaluate polar at the final inflow angle
        alpha_eff = alpha(j) - alpha_0;

        if alpha_eff < deg2rad(12) && alpha_eff > deg2rad(-8)
            Cl(j) = Cla * alpha_eff;
            Cd(j) = cfg.CD0 + 1.2 * (Cl(j) / (pi * 3.5))^2;
        else
            Cl(j) = 1.1 * sin(2 * alpha_eff);
            Cd(j) = cfg.CD0 + 2.0 * sin(alpha_eff)^2;
        end

        F_prandtl(j) = F_total;

        % Relative velocity and dynamic pressure
        V_rel = (omega * rj) / cos(phi(j));
        q_dyn = 0.5 * env.rho * V_rel^2;

        % Lift and drag on one blade element
        dL = q_dyn * Cl(j) * cj * dr(j);
        dD = q_dyn * Cd(j) * cj * dr(j);

        % Thrust and torque across all blades
        dT(j) = Nb * (dL * cos(phi(j)) - dD * sin(phi(j)));

        dF_tan = dL * sin(phi(j)) + dD * cos(phi(j));
        dQ(j)  = Nb * dF_tan * rj;
    end

    % Midpoint integration: element forces already include dr
    out.Thrust_N  = sum(dT);
    out.Thrust_g  = out.Thrust_N * 101.9716;
    out.Torque_Nm = sum(dQ);
    out.Power_W   = out.Torque_Nm * omega;

    % Hover figure of merit
    Disk_Area = pi * R_tip^2;

    P_ideal = out.Thrust_N^1.5 / ...
        sqrt(2 * env.rho * Disk_Area);

    out.FM = P_ideal / max(out.Power_W, 1e-3);

    % Spanwise distributions
    out.r         = r;
    out.dT_dr     = dT ./ dr;
    out.alpha_deg = rad2deg(alpha);
    out.phi_deg   = rad2deg(phi);
    out.Cl        = Cl;
    out.Cd        = Cd;
end