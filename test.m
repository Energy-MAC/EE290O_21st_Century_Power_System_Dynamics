x_abc = zeros(length(t),3);
t_sim = linspace(0,10,300);
K = sqrt(2/3)* [ 1, -1/2, -1/2; 0, sqrt(3)/2, -sqrt(3)/2 ; 1/sqrt(2), 1/sqrt(2), 1/sqrt(2)];
invK = inv(K);
for j=1:length(t_sim)
   w0 = 120*pi;
   R_rot = [ cos(w0*t_sim(j)) , -sin(w0*t_sim(j)) ; sin(w0*t_sim(j)), cos(w0*t_sim(j)) ];
   x_abc(j,:) = invK*[R_rot*[x(end, 1:2)]';0];
    
end
