function [x_eq,u_free] = find_eq_u(x0,Mass_Matrix,u0,u_free_ind,param,param_limits)
% Similar to find_eq, but it allows some of the u variables to be free and
% finds corresponding equilibrium inputs.
x_eq = zeros(size(x0));
ind = sum(Mass_Matrix) > 1e-4; %indices of DC variables

%Solve for DC variables and free u variables
opts = optimoptions('fsolve','Display','off');
[x_dc_and_u_free_eq,~,exitFlag] = fsolve(@(x) f(x),[x0(ind);u0(u_free_ind)],opts);
if exitFlag < 1
    error('Could not find equilibrium x and u_free');
end

% Store the equilibrium u variables (both free and fixed)
u_eq = u0;
u_free = x_dc_and_u_free_eq(sum(ind)+1:end);
u_eq(u_free_ind) = u_free;

% Store equilibrium DC variables
x_eq_dc = x_dc_and_u_free_eq(1:sum(ind));
x_eq(ind) = x_eq_dc;

% Compute and store corresponding AC variables
x_eq(~ind) = find_ac(x_eq,Mass_Matrix,u_eq,param,param_limits);

function y = f(x_dc_and_u)
    % y is the full system derivative; x_dc_and_u is a guess for the DC and
    % free input variables
    % Store temporary variable for state
    t = x0;
    % Set DC variables to input x_dc to function f(x_dc)
    t(ind) = x_dc_and_u(1:sum(ind));
    
    % Set free u variables to current guess
    u = u0;
    u(u_free_ind) = x_dc_and_u(sum(ind)+1:end);
    
    % Set AC variables to equilibrium values given DC variables (x_dc) and
    % inputs. Initial guess should be arbitary as AC variables will
    % converge
    t(~ind) = find_ac(t,Mass_Matrix,u,param,param_limits);
    
    % Compute derivative given current iteration dc variables (x_dc) and
    % the associated steady state AC variables.
    y = ode_full_system_modular(0,t,u,param, param_limits);
    
    % Return derivatives associated with DC variables
    y = y(ind);
end

end