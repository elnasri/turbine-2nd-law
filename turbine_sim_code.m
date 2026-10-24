% adiabatic air turbine, sweep efficiency, check 1st and 2nd law

clear; clc; close all;
% which plots to shw
show.power      = true;
show.entropy    = true;
show.lostwork   = true;
show.normalized = true;

% inputs
params.T1   = 1200;    % K
params.P1   = 1000;    % kPa
params.P2   = 100;     % kPa
params.k    = 1.4;
params.R    = 0.287;   % kJ/kg-K
params.cp   = params.k/(params.k - 1) * params.R;   % was 1.005, not in line with with R and K
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

if show.power,      plotPower(eta_t, results);      end
if show.entropy,    plotEntropy(eta_t, results);    end
if show.lostwork,   plotLostWork(eta_t, results);   end
if show.normalized, plotNormalized(eta_t, results); end

% ---------- functions ----------

function res = computeTurbineModel(p, eta_t)
    % isentropic exit
    res.T2s = p.T1 * (p.P2 / p.P1)^((p.k - 1) / p.k);
    res.ws  = p.cp * (p.T1 - res.T2s);

    % real exit
    res.T2      = p.T1 - eta_t .* (p.T1 - res.T2s);
    res.wActual = p.cp * (p.T1 - res.T2);
    res.power   = p.mdot .* eta_t .* res.ws;      %  eta*ws so check below isn't comparing to itself
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
    ok = true;
    if any(res.T2 < res.T2s - 1e-6) || any(res.T2 > p.T1 + 1e-6)
        warning('temperature out of bounds bro'); ok = false;
    end
    if any(res.wActual > res.ws + 1e-6) || any(res.wActual < 0)
        warning('work out of bounds bro'); ok = false;
    end
    if any(res.sgenSpecific < -1e-8)
        warning('s_gen < 0, 2nd law violated'); ok = false;
    end
    if any(abs(res.energyResidual) > 1e-6)
        warning('1st law residual is not zero'); ok = false;
    end
    if ok
        disp('validation good/ok');
    else
        disp('hahaa validation failed, see warnings');
    end
end

function plotPower(eta_t, res)
    figure('Name', 'Power', 'Color', 'w');
    plot(eta_t, res.power, 'b-', 'LineWidth', 2); grid on;
    xlabel('Turbine Isentropic Efficiency, $\eta_t$', 'Interpreter', 'latex');
    ylabel('Shaft Power, $\dot{W}_t$ [kW]', 'Interpreter', 'latex');
    title('Power vs efficiency');
end

function plotEntropy(eta_t, res)
    figure('Name', 'Entropy generation', 'Color', 'w');
    plot(eta_t, res.SgenRate, 'r-', 'LineWidth', 2); grid on;
    xlabel('Turbine Isentropic Efficiency, $\eta_t$', 'Interpreter', 'latex');
    ylabel('Entropy Generation, $\dot{S}_{gen}$ [kW/K]', 'Interpreter', 'latex');
    title('Entropy generation vs efficiency');
end

function plotLostWork(eta_t, res)
    figure('Name', 'Lost work', 'Color', 'w');
    plot(eta_t, res.exergyDestroyedRate, 'm-', 'LineWidth', 2); grid on;
    xlabel('Turbine Isentropic Efficiency, $\eta_t$', 'Interpreter', 'latex');
    ylabel('$T_0 \dot{S}_{gen}$ [kW]', 'Interpreter', 'latex');
    title('T0*S_{gen} vs efficiency');
end

function plotNormalized(eta_t, res)
    figure('Name', 'Normalized', 'Color', 'w');
    norm_work = res.wActual / res.ws;
    norm_lost = res.exergyDestroyedSpecific / max(res.exergyDestroyedSpecific);
    plot(eta_t, norm_work, 'b-', 'LineWidth', 2); hold on;
    plot(eta_t, norm_lost, 'm--', 'LineWidth', 2); grid on;
    xlabel('Turbine Isentropic Efficiency, $\eta_t$', 'Interpreter', 'latex');
    ylabel('Normalized');
    title('Work vs lost work');
    legend({'work / ideal work', 'lost work / max lost work'}, 'Location', 'best');
end
