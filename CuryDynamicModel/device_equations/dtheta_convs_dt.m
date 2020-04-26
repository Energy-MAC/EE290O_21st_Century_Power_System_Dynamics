function dthetacdt = dtheta_convs_dt(vdc, omega0, kmc, vdcref)
%This function represents generator dynamics based off Equations (24c) and 25 in Curi Paper
wc = kmc*(vdc - vdcref) + 1; % 1 is normalized frequency
dthetacdt = omega0*(wc - 1); % 1 is normalized frequency, dont actually need omega0