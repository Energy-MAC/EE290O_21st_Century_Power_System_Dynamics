function f = reactive_power_droop(iod, vod, ioq, voq, qm, params)

  %get parameters 
  
  wf = params.wf;

 f = [ 
     %d(qm)/dt = 
    -wf*ioq*vod+...
    wf*iod*voq-...
    wf*qm

    ];

end

