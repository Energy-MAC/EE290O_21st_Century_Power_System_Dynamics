function [dx_turbine_dt,tau_m] = f_turbine_PI(phi,w_gen,k_droop_p, k_droop_i)
% This is a PI controller to regulate generator frequency to nominal.
% For N generators, k_droop_p and k_droop_i should be Nx1 vectors of gains
% phi is an Nx1 vector for controller state

dx_turbine_dt = k_droop_i.*(1 - w_gen);
tau_m = k_droop_p.*(1-w_gen)+phi;