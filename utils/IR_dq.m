%% Uses the reference Frame of the Kundur page 852
function IR_dq = IR_dq(d)

IR_dq = [sin(d) -cos(d);
         cos(d)  sin(d)];
end           
   
   