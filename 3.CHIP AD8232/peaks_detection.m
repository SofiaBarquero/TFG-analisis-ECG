function [locs_Pf,amp_Pf,locs_Qf,amp_Qf,locs_Rf,locs_Sf,amp_Sf,locs_Tf,amp_Tf]=peaks_detection(signal,fs,locsR)
%% Explicacion de la función
%{
-->La funcion recibe como parámetro la señal ecg preprocesada, la frecuencia
de muestreo y los picos R detectados por el algoritmo de Pan Tompkins
-->Se detecta cada pico en función de la posición que deban tomar en
funcion a los picos R ya detectados buscando un máximo o mínimo según corresponda 
desde dicha posicion de los picos R hasta cierto offset
%}

%% 
delay = round(0.0150*fs)/2;
%locsR = locsR - round(delay);
signal = (reshape(signal,1,length(signal)));

%-------------------------R PEAKS----------------------------
%UBICACIONES FINALES DE LOS PICOS R
locs_Rf = unique(locsR); %para eliminar duplicados


%-------------------------Q PEAKS----------------------------
%localizo los picos Q antes de cada pico R
locs_Q = locs_Rf;
search_offsetQ =  round(0.1*fs);
check_loc2 = find(locs_Q>=length(signal) | locs_Q - search_offsetQ <=0);
locs_Q((check_loc2)) = [];

locs_Qfround1 = locs_Q - search_offsetQ; % searching offset.6
locs_Qf = zeros(1,length(locs_Q));
amp_Qf = zeros(1,length(locs_Q));
for k = 1:length(locs_Q)
    %busco los minimos entre el offset restado a las ubicaciones de los
    %picos R hasta las ubicaciones de dichos picos R
    [amp_Qf(k),locs_Qf(k)] =  min(signal(locs_Qfround1(k):locs_Q(k)));
    locs_Qf(k) = locs_Qf(k) + locs_Qfround1(k);
end 

%Ubicaciones finales de los picos Q
locs_Qf = unique(locs_Qf);



%--------------------------S PEAKS----------------------------
%busco los picos S DESPUES de los picos R hallados
locs_S = locs_Rf;
search_offsetS = round(0.1*fs); %round(0.1*fs); %offset de busqueda despues del pico R
check_loc3 =  find(locs_S>=length(signal) | locs_S + search_offsetS >=length(signal));
locs_S((check_loc3)) = [];
locs_Sfround1 = locs_S + search_offsetS;
locs_Sf=zeros(1,length(locs_S));
amp_Sf=zeros(1,length(locs_S));

for k = 1:length(locs_S)
    %busco un minimo entre el pico R hasta el offset
    [amp_Sf(k),locs_Sf(k)] =  min(signal(locs_S(k):locs_Sfround1(k)));
    locs_Sf(k) = locs_Sf(k) + locs_S(k);
    %locs_Sf(k) =  find(signal == min(signal(locs_S(k):locs_Sfround1(k))));
end

%Ubicaciones finales de los picos S
locs_Sf = unique(locs_Sf);


%----------------------------T PEAKS------------------------------
%localizo los picos T buscando un máximo detrás de cada pico S
locs_Tf1 = locs_Sf;

search_offsetT = round(0.3*fs); %offset con respecto al pico S anterior
check_loc4 = find(locs_Tf1>=length(signal) | locs_Tf1 + search_offsetT >=length(signal));

flag_T=0;
locs_Tf=zeros(1,length(locs_Tf1));
amp_Tf=zeros(1,length(locs_Tf1));
if ~isempty(check_loc4)
    for k = 1:length(check_loc4)
        %locs_Tf(check_loc4(k)) = find(signal == max(signal((locs_Tf1(check_loc4(k))) : length(signal))),1);
        [amp_Tf(check_loc4(k)),locs_Tf(check_loc4(k))]= max(signal((locs_Tf1(check_loc4(k))) : length(signal)));%maximo entre S y el offset
        %locs_Tf(k)=locs_Tf(k)+locs_Tf1(check_loc4(k));
        if locs_Tf(check_loc4(k))>length(signal)
            locs_Tf(check_loc4(k))=locs_Tf(check_loc4(k))-1;
        end
    end
    flag_T = 1;
end 

locs_Tfround = locs_Tf1 + search_offsetT;
locsTfinale = find(locs_Tfround>=length(signal));
locs_Tfround((locsTfinale)) = length(signal);

if flag_T==0
    for k=1:length(locs_Tf1)
        [amp_Tf(k),locs_Tf(k)]= max(signal(locs_Tf1(k):locs_Tfround(k)));%maximo entre S y el offset
        locs_Tf(k)=locs_Tf(k)+locs_Tf1(k);
    end
elseif flag_T==1
    for k=1:length(locs_Tf1)-length(check_loc4)
        [amp_Tf(k),locs_Tf(k)]= max(signal(locs_Tf1(k):locs_Tfround(k)));%maximo entre S y el offset
        locs_Tf(k)=locs_Tf(k)+locs_Tf1(k);
        if locs_Tf(k)>length(signal)
            locs_Tf(k)=locs_Tf(k)-1;
        end
    end
    
end
%ubicaciones finales de los picos T
locs_Tf = unique(locs_Tf);


%-----------------------------P PEAKS-----------------------------
%Busco los picos P antes de los picos Q ya detectados
locs_Pf1 = locs_Qf;
locs_Pf = zeros(1,length(locs_Pf1)); %vector final
amp_Pf = zeros(1,length(locs_Pf1)); %vector final
search_offsetP = round(0.15*fs);
check_loc5 = find((locs_Pf1 - search_offsetP) <=0);

flag_P = 0;
if ~isempty(check_loc5)
    for k = 1:length(check_loc5)
        %locs_Pf(check_loc5(k)) = find(signal == max(signal((1:locs_Pf1(check_loc5(k))))));
        [amp_Pf(k),locs_Pf(k)]=max(signal((1:locs_Pf1(check_loc5(k)))));
    end 
        flag_P = 1;
end 

locs_Pfround=locs_Pf1-search_offsetP;
locsfinale = find(locs_Pfround<=0);
locs_Pfround((locsfinale)) = 1;

if flag_P==0
    
    for k=1:length(locs_Pf1)
        %locs_Pf(k) =  find(signal == max(signal(locs_Pfround(k):locs_Pf1(k))));
        [amp_Pf(k),locs_Pf(k)]=max(signal(locs_Pfround(k):locs_Pf1(k)));
        locs_Pf(k)=locs_Pf(k)+locs_Pfround(k);
    end
elseif flag_P==1
    for k = 2:length(locs_Pf1)
        %locs_Pf(k) =  find(signal == max(signal(locs_Pfround(k):locs_Pf1(k))));
        [amp_Pf(k),locs_Pf(k)]=max(signal(locs_Pfround(k):locs_Pf1(k)));
        locs_Pf(k)=locs_Pf(k)+locs_Pfround(k);
    end
end
%ubicaciones finales picos P
locs_Pf=unique(locs_Pf);

end