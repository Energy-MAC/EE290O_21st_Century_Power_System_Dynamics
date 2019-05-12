function [dx_avr_dt,u_avr] = f_avr(i_field,v_ref,v_gen_bus,k_avr)
% For N generators, k_avr should be Nx1 vector of gains, v_ref an Nx1
% vector of voltage magnitudes.

u_avr = i_field;

% Calculate magnitude from dq components. 'reshape' makes bus voltages 2 x
% N with first row the 'd' and second row 'q'. Vecnorm takes the norm of
% each column, then we transpose back to a column vector.
v_gen_bus_mag = vecnorm(reshape(v_gen_bus,[2 length(v_gen_bus)/2]))';


dx_avr_dt = k_avr.*(v_ref-v_gen_bus_mag);