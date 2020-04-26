function [dxdt] = InfBus_to_2axis(t,x,params)

%Pull the params out of the params cell
SM_params = params{1};
InfBus_params = params{2};

%The Variables in all their glory (for Reference)
% w = x(1);
% delta = x(2);
% eprime_d = x(3);
% eprime_q = x(4);
% P_e= x(5);
% i_q = x(6);
% i_d = x(7);
% v_q = x(8);
% v_d = x(9);
% v_f = x(10);
% P_m = x(11);
% v_h = x(12);
% theta_h = x(13);
% P_h = x(14);
% Q_h = x(15);

dxdt = [
    twoaxisSM(x,SM_params)
    NoAVR(x(10), SM_params)
    NoGovernor(x(11),SM_params)
    InfBus(x(12:15),InfBus_params)
    ];
