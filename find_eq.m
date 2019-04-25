function x_eq = find_eq(x0,Mass_Matrix,u,param,param_limits)
% Find equilibirum of DC *and* AC variables given u
% Diagonals of Mass_Matrix == 1 gives DC; 0 gives AC
% If there are 'a' AC variables and 'd' DC variables, x_eq is (a+d) by 1
%
% We have to solve for the DC and AC variables separately because they are
% on different time scales. The process is done with fsolve: Given a guess
% of the DC variables and (fixed) inputs u, find the corresponding values
% of the AC variables. Given those AC variables, the guess of the DC
% variables, and fixed input, compute the derivatives of the DC variables.
% Update guesses and iterate until derivative of DC variables are zero,
% which also implies the derivatives of the AC variables are zero.
%
% Note that this will likely not converge unless 'u' is carefully chosen to
% admit an equilibrium. See 'find_eq_u' for a version where elements of 'u'
% can be free so as to admit an equilibrium.

%Preallocate for solution
x_eq = zeros(size(x0));

ind = sum(Mass_Matrix) > 1e-4; %indices of DC variables

% Solve for DC variables.
opts = optimoptions('fsolve','Display','off');
[x_eq_dc,~,exitFlag] = fsolve(@(x) f(x),x0(ind),opts);
if exitFlag < 1
    error('Could not find equilibrium. Fsolve did not converge');
end

% Set DC variable part of solution
x_eq(ind) = x_eq_dc;

% Given eq. DC variables and u, calculate the corresponding AC variables. 
% Note this repeats part of the calculation in y = f(x_dc) below, namely
% the line: t(~ind) = find_ac(t,Mass_Matrix,u,param,param_limits);
x_eq(~ind) = find_ac(x_eq,Mass_Matrix,u,param,param_limits);

function y_dc = f(x_dc)
    % x_dc are values of DC variables
    % y is the derivatives of those DC variables given x_dc, u, and the
    %   equilibrium AC variables for x_dc and u.
    
    % Store temporary variable for state
    t = x0;
    % Set DC variables to input x_dc to function f(x_dc)
    t(ind) = x_dc;
    
    % Set AC variables to equilibrium values given DC variables (x_dc) and
    % inputs. Initial guess should be arbitary as AC variables will
    % converge
    t(~ind) = find_ac(t,Mass_Matrix,u,param,param_limits);
    
    % Compute derivative given current iteration dc variables (x_dc) and
    % the associated steady state AC variables.
    y_dc = ode_full_system_modular(0,t,u,param, param_limits);
    
    % Return derivatives associated with DC variables
    y_dc = y_dc(ind);
end

end