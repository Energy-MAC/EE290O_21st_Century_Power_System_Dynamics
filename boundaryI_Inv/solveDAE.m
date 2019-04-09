% have not run this yet, still fixing up
y0 = [1; 0; 0];
tspan = [0 4*logspace(-6,6)];
M=eye(10); % mass matrix to define which eqs are diff vs. alg eqs
M(7,7)=0; % alg eq
M(10,10)=0; % alg eq

options = odeset('Mass',M,'RelTol',1e-4,'AbsTol',[1e-6 1e-10 1e-6]);
[t,y] = ode15s(@inverter_dxdt,tspan,y0,options);

