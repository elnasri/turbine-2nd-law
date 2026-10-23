% adiabatic air turbine, sweep efficiency, check 1st and 2nd law

clear; clc; close all;

% inputs
params.T1   = 1200;    % K
params.P1   = 1000;    % kPa
params.P2   = 100;     % kPa
params.k    = 1.4;
params.cp   = 1.005;   % kJ/kg-K
params.R    = 0.287;   % kJ/kg-K
params.T0   = 298.15;  % K
params.mdot = 1.0;     % kg/s

eta_t = linspace(0.50, 1.00, 101);

results = computeTurbineModel(params, eta_t);
validateModel(results, params);

% table
sample_eta = [0.60, 0.70, 0.80, 0.90, 1.00];
idx = arrayfun(@(e) find(abs(eta_t - e) < 1e-4, 1), sample_eta);

fprintf('eta_t   T2s [K]   T2 [K]   w_s    w_act   w_lost   s_gen     T0*s_gen   residual\n');
for i = idx
    fprintf('%4.2f   %7.2f  %7.2f  %7.2f  %7.2f  %7.2f  %9.4f  %8.2f  %9.2e\n', ...
        eta_t(i), results.T2s, results.T2(i), results.ws, ...
        results.wActual(i), results.lostWork(i), results.sgenSpecific(i), ...
        results.exergyDestroyedSpecific(i), results.energyResidual(i));
end

generatePlots(eta_t, results);


% ---------- functions ----------

function res = computeTurbineModel(p, eta_t)
    % isentropic exit
    res.T2s = p.T1 * (p.P2 / p.P1)^((p.k - 1) / p.k);
    res.ws  = p.cp * (p.T1 - res.T2s);

    % real exit
    res.T2      = p.T1 - eta_t .* (p.T1 - res.T2s);
    res.wActual = p.cp * (p.T1 - res.T2);
    res.power   = p.mdot .* res.wActual;

    res.lostWork = res.ws - res.wActual;

    % 1st law check
    res.energyResidual = p.mdot .* p.cp .* (p.T1 - res.T2) - res.power;

    % entropy change = entropy generated (adiabatic)
    res.sgenSpecific = p.cp .* log(res.T2 ./ p.T1) - p.R .* log(p.P2 / p.P1);
    res.sgenSpecific(abs(res.sgenSpecific) < 1e-12) = 0;
    res.SgenRate = p.mdot .* res.sgenSpecific;

    % T0 * sgen
    res.exergyDestroyedSpecific = p.T0 .* res.sgenSpecific;
    res.exergyDestroyedRate     = p.T0 .* res.SgenRate;
end

function validateModel(res, p)
    if any(res.T2 < res.T2s - 1e-6) || any(res.T2 > p.T1 + 1e-6)
        warning('temperature out of bounds');
    end
    if any(res.wActual > res.ws + 1e-6) || any(res.wActual < 0)
        warning('work out of bounds');
    end
    if any(res.sgenSpecific < -1e-8)
        warning('s_gen < 0, 2nd law violated');
    end
    if any(abs(res.energyResidual) > 1e-6)
        warning('1st law residual not zero');
    end
    disp('validation done');
end

function generatePlots(eta_t, res)
    figure('Name', 'Turbine', 'Color', 'w', 'Position', [150, 150, 1000, 700]);

    subplot(2,2,1);
    plot(eta_t, res.power, 'b-', 'LineWidth', 2); grid on;
    xlabel('\eta_t'); ylabel('Power [kW]');
    title('Power vs efficiency');

    subplot(2,2,2);
    plot(eta_t, res.SgenRate, 'r-', 'LineWidth', 2); grid on;
    xlabel('\eta_t'); ylabel('S_{gen} [kW/K]');
    title('Entropy generation vs efficiency');

    subplot(2,2,3);
    plot(eta_t, res.exergyDestroyedRate, 'm-', 'LineWidth', 2); grid on;
    xlabel('\eta_t'); ylabel('T0 * S_{gen} [kW]');
    title('T0*S_{gen} vs efficiency');

    subplot(2,2,4);
    norm_work   = res.wActual / res.ws;
    norm_exergy = res.exergyDestroyedSpecific / max(res.exergyDestroyedSpecific);
    plot(eta_t, norm_work, 'b-', 'LineWidth', 2); hold on;
    plot(eta_t, norm_exergy, 'm--', 'LineWidth', 2); grid on;
    xlabel('\eta_t'); ylabel('normalized');
    title('work vs lost work');
    legend('work', 'T0*S_{gen}', 'Location', 'best');
end