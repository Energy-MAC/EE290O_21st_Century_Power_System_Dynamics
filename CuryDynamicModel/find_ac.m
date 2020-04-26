function x_ac = find_ac(x0,Mass_Matrix,u,param,param_limits)
% Find the equilibrium AC variables given the DC variables in x0. The AC
% variables given in x0 are used as the initial guess.
% The Mass_Matrix == 0 gives the indexes of the AC variables.
% If there are 'a' AC variables, and 'd' DC variables, then:
%   x0 is (a+d) by 1
%   x_ac is a by 1
%   y = f(x) is a by 1; x is a by 1

ind = sum(abs(Mass_Matrix)) < 1e-4; % Indexes of AC variables

% Find x_ac such that derivative of x_ac is zero given x_dc and u
opts = optimoptions('fsolve','Display','off');
[x_ac,~,exitFlag] = fsolve(@(x) f(x),x0(ind),opts);
if exitFlag < 1
    error('Could not find equilibrium AC variables')
end

function y_ac = f(x_ac)
    % x is the AC variables only
    t = x0;
    %x0(~ind) are the DC variables
    t(ind) = x_ac; %Update the AC variables
    y_ac = ode_full_system_modular(0,t,u,param, param_limits);
    y_ac = y_ac(ind); % Return only derivatives of AC variables
end
end