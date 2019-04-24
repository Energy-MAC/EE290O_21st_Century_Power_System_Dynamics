%% Uses the reference Frame of the Kundur page 852
function dq_IR = dq_IR(d)

    dq_IR =  [sin(d)  cos(d); 
             -cos(d)  sin(d)];    

end   

