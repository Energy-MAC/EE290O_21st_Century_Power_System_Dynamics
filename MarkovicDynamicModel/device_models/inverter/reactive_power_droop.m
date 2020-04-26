function f = reactive_power_droop(x,y, params)

    qm = x(1);

    iod = y(1); 
    vod = y(2); 
    ioq = y(3); 
    voq = y(4); 
    
  %get parameters 
  
  wf = params.wf;

 f = [ 
     %d(qm)/dt = 
    -wf*ioq*vod+...
    wf*iod*voq-...
    wf*qm

    ];

end

