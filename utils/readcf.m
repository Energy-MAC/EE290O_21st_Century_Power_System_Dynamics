function S = readcf(fname)
%Funcion para la lectura y procesamiento de un archivo *.cf, incluye rutina
%para el calculo de Ybus y almancemaniento en la estructura. Elaborado por
%Jose Daniel Lara, con guia de "Solving Power Flow Problems with a Matlab 
%Implementation of the Power System Applications Data Dictionary by Fernando L. Alvarado

%----------------------------------------------------------------------------------------
%Se definen los contadores
n=0; %numero de buses
nL =0; %numero de cargas
ng=0; %numero de generadores 
nn = 0; %numero de branches
%----------------------------------------------------------------------------------------

%Lee el el archivo en formato .cf y estructura los datos 
%Si no especifica el archivo, abre el UI para buscar. 
if nargin<1

    [fname, pname] = uigetfile('*.cf'); 
    fname=[pname fname];
end
  fcf = fopen(fname, 'r'); %Abre el archivo de formato .cf
  s = fgetl(fcf); %Encabezado 
  S.BaseMVA = sscanf(s(1,32:37), '%f');%Lee la base del sistema.  
  
%Lee la informacion de los buses
   while strcmp(s(1:min(3,length(s))), 'BUS') ~=1,
      s = fgetl(fcf); %Lee la primera linea
   end
   s = fgetl(fcf);
  while s(1) == '%', s=fgetl(fcf); end; %Con esta linea se salta los comentarios 

%Crea las estructuras donde se almacenan las listas de buses y sus status.
    %buses 
    S.Bus.SlackList=[]; S.Bus.PVList=[]; S.Bus.PQList = []; S.Bus.BlackList=[];
    S.Bus.Number= [];  
    S.Bus.Name=[]; 
    S.Bus.Voltages=sparse(n,1);S.Bus.Angles=sparse(n,1);
    S.Bus.area=[];
    S.Bus.zone=[];
    S.Bus.busType=[];
    %Lineas y Trafos
    S.Branch=[];
    %Maquinas 
    S.Machine=[];
    %Cargas
    S.Load =[];
    
    
while strcmp (s(1:4),'-999') ~=1, %Detiene la lectura hasta llegar a -999  
  
%Se da numero a los buses en la numeracion del programa.  
    n=n+1;

%Se clasifica los buses por tipo
        %0 - Unregulated (load, PQ)
        %1 - Hold MVAR generation within voltage limits, (PQ)
        %2 - Hold voltage within VAR limits (gen, PV)
        %3 - Hold voltage and angle (swing, V-Theta)
                      
      S.Bus.busType(n,1)=sscanf(s(26),'%d');
      if (s(26) == '2') || (s(26) == '3')
          if s(26) == '3', S.Bus.SlackList = [S.Bus.SlackList n];
          else S.Bus.PVList= [S.Bus.PVList n];
          end;
      else
          S.Bus.PQList = [S.Bus.PQList n];
      end;
    
%Lee el numero identificador del bus y el nombre.            
    bus =scanint (s,1,5);
    S.newBus(bus)=n; %contador de la cantidad de buses 
    S.Bus.Number(n,1) =bus; %saca el numero de la funcion. 
    S.Bus.Name(n,:) = s(7:17); %lee el nombre del bus.
    S.Bus.area(n,1) = sscanf(s(19:20) , '%d'); % numerico
    S.Bus.zone(n,:) = s(21:23);

    %Lee la informaci?n de cargas y generadores para el resto de los
    %calculos 
    
    Pg = scanreal(s,60,67); %Dato de potencia generada
    Qg = scanreal(s,68,75); %Dato de reactivo generado
    Pd = scanreal(s,41,49); %Dato de potencia demandada 
    Qd = scanreal(s,50,59); %Dato de reactivo demandado 
    
%Definir las caracteristicas de los buses de carga

      if (Pd~=0) ||(Qd ~=0) || (s(26) == '0')      
          nL=nL+1;
          S.Load.newLoad(bus,1) = nL; %buses identificados como de generacion
          S.Load.BusRef(nL,1) = bus; %Numero de bus de carga
          S.Load.MW(nL,1) =Pd; % Potencia activa de carga
          S.Load.MVAR(nL,1) = Qd; %Potencia reactiva de carga
          S.Load.Status(nL,1) =1; %status de la carga luego se puede implementar una forma de apagarla
      else
          %fprintf('se lo salto\n')
      end;
    
%Definir las caracteristicas de los buses con generador
      S.Machine.newGen(bus,1) =0;
      if (Pg~=0) ||(Qg ~=0) || (s(26) == '1') || (s(26) == '3') || (s(26) == '2'),
          ng=ng+1;
          S.Machine.newGen(bus,1)= ng; %Buses identificados como de generacion
          S.Machine.BusRef(ng,1) = bus; %Numero de bus de generacion
          S.Machine.MW(ng,1) = Pg; % Potencia activa de los generadores
          S.Machine.MVAR(ng,1) = Qg; %Potencia reactiva de los generadores
          S.Machine.Status(ng,1) =1; %status del generador luego se puede implementar una forma de apagarlo
          %obtiene los limite de Q del generador.
          if S.Machine.newGen(bus) && (ismember(bus,S.Bus.PVList) || (ismember(bus,S.Bus.SlackList)))
              S.Machine.MaxQOutput(ng,1) = scanreal(s,91,98);
              S.Machine.MinQOutput(ng,1) = scanreal(s,99,106);
          else
              S.Machine.MaxQOutput(ng,1) = -1;
              S.Machine.MinQOutput(ng,1) = -1;
                 
          end
          S.Machine.ControlledBusRef(ng,1) = scanreal(s,124,128);
      else
      end
         

%grabar la informacion de las maquinas y las cargas en los buses. 

    S.Bus.Load(n,1) = (Pd+1i*Qd)/S.BaseMVA;	  
    S.Bus.Generation(n,1) = (Pg+1i*Qg)/S.BaseMVA;
      

%obtiene la informacion de las tensiones de buses de la base de datos. 
      S.Bus.Voltages(n,1) = scanreal(s,28,33,1);
      S.Bus.Angles(n,1) =  scanreal(s,34,40);
      S.Bus.BaseKV(n,1) = scanreal(s,77,83);
      S.Bus.SchedV(n,1) = scanreal(s,85,90);
      if ismember(bus,S.Bus.PQList)
          S.Bus.ULimit(n,1)=scanreal(s,91,98);
          S.Bus.LLimit(n,1)=scanreal(s,99,106);
      else
          S.Bus.ULimit(n,1)=-1;
          S.Bus.LLimit(n,1)=-1;
      end
%obtiene los datos de las admitancias en derivacion conectados a los buses.           
      S.Bus.G(n,1) = scanreal(s,107,114);
      S.Bus.B(n,1) = scanreal(s,115,122);
      
      s= fgetl(fcf); %pasa de linea
      
      while s(1) == '%', s=fgetl(fcf); end; %brinco en caso de comentarios
  end

% variables para meter informacion de los branches. 
  minArea=min(S.Bus.area); 
  dArea=1-minArea;
   
  while ~strcmp(s(1:3), 'BRA'), s=fgetl(fcf); end
  s=fgetl(fcf);
  while s(1) == '%', s=fgetl(fcf); end;
   
  while ~strcmp(s(1:4), '-999'),
      nn=nn+1;
      R=scanreal(s,20,29); %Resistencia
      X= scanreal(s,30,40); %Reactancia
      S.Branch.From(nn,1) = S.newBus(scanint(s,1,5));
      S.Branch.To(nn,1) = S.newBus(scanint(s,6,10));
      S.Branch.Type(nn,1) = scanint(s,19,19); %Tipo de linea
      %Identificar transformadores y Lineas
      if (S.Branch.Type(nn,1) == 1) || (S.Branch.Type(nn,1) == 2), %Caso de transformador y transformador con control
          tap = scanreal(s,77,82);
          alpha = scanreal(s,84,90)*pi/180;
          c=tap^-1;
          S.Branch.Z(nn,1)=  (R+1i*X);
          S.Branch.B(nn,1) = scanreal(s,41,49);
          S.Branch.RateValue(nn,1) = scanreal(s,51,55)/S.BaseMVA; % Cargabilidad de la linea
          if (S.Branch.Type(nn,1) == 2)
              S.Branch.Control(nn,1)=scanreal(s,69,72);
              S.Branch.Control(nn,2)=scanreal(s,74,74);
              S.Branch.Control(nn,3)= S.Bus.SchedV(scanreal(s,69,72));
          else
              S.Branch.Control(nn,1)=0;
              S.Branch.Control(nn,2)=0;
              S.Branch.Control(nn,3)= 0;
          end    
              S.Branch.TAP(nn,1) = tap;
              S.Branch.MinTAP(nn,1)=scanreal(s,91,97);
              S.Branch.MaxTAP(nn,1)=scanreal(s,98,104);
              S.Branch.TAPSize(nn,1)=scanreal(s,106,111);
      else % Cualquier otro caso considerar una linea. 
              S.Branch.Z(nn,1) = (R+1i*X);
              S.Branch.B(nn,1) = scanreal(s,41,49); %capacitancia de la linea.
              S.Branch.RateValue(nn,1) = scanreal(s,51,55)/S.BaseMVA; % Cargabilidad de la linea
              S.Branch.Control(nn,1)=scanreal(s,69,72);
              S.Branch.Control(nn,2)=scanreal(s,74,74);
              S.Branch.Control(nn,3)=0;
              S.Branch.TAP(nn,1) = 1;
              S.Branch.MinTAP(nn,1)=0;
              S.Branch.MaxTAP(nn,1)=0;
              S.Branch.TAPSize(nn,1)=0;
          end;
      s = fgetl(fcf);
      while s(1) == '%', s=fgetl(fcf); end %salta comentario
      
      
  end
  
  S.Branch.Status= ones(nn,1); %estado de la linea se puede cambiar para que lea el estado desconectado
  
  kzero= find(S.Branch.RateValue == 0); %No se permite que haya un 0 en el dimensionamiento de la linea
  S.Branch.RateValue(kzero) = Inf;
 
fclose(fcf); %ya no leer el archivo
  
%para saber cuantos buses hay y sus numeros de identificacion.   
  S.Machine.BusRef = S.newBus(S.Machine.BusRef)';
  S.Load.BusRef = S.newBus(S.Load.BusRef)';

%cantidad de buses con tension controlada  
  ky = find(S.Machine.ControlledBusRef);
  kx = S.Machine.ControlledBusRef(ky); %lista de buses de tension controlada
  S.Machine.ControlledBusRef(ky) = S.newBus(kx);
  
  S.Bus.n = length(S.Bus.Voltages);
  S.Branch.nn = length(S.Branch.From);
  S.Bus.area = S.Bus.area+dArea;
  end

%----------------------------------------------------------------------------------------
 function i = scanint(s, beg, last, default) %funcion para scanear enteros 
%
if nargin <4, default =0; end
i=default;
[dummy, ns] = size(s);
if ns<beg, return; end;
if last<beg, return; end;
last = min(last, ns);
if isspace (s(beg:last)), return; end
i = sscanf(s(beg:last),'%d');
return;  
 end 
%---------------------------------------------------------------------------------------- 
function i = scanreal(s, beg, last, default) %funcion para scanear reales
%
if nargin <4, default =0; end
i=default;
[dummy, ns] = size(s);
if ns<beg, return; end;
if last<beg, return; end;
last = min(last, ns);
if isspace (s(beg:last)), return; end
i = sscanf(s(beg:last),'%f');
return; 
end 

  
      
      
      
      
          
      
      
      
      
      
  

        
       