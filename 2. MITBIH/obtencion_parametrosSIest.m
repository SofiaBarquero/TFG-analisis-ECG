function params=obtencion_parametrosSIest (recordname)
%% Obtencion de la señal

%hallo la info de la señal a analizar
[ecg,fs,t] = rdsamp(recordname, 1);
%plot(t,ecg)

%% Deteccion de picos
params=[];
%[~,~,locs_Rf,~,~]=PamTompkins_f(ecg,fs);
seg_plot = 3*fs;
seg_plotQRS= seg_plot/fs;
plotLineQRS=seg_plotQRS:2*seg_plotQRS;
[locs_Pf,~,locs_Qf,~,locs_Rf,~,locs_Sf,~,locs_Tf,~]=PamTompkins_f(ecg, fs);

%
figure();clf
plot(t,ecg,'b'); hold on
plot(t(locs_Rf),ecg(locs_Rf),'*r')
plot(t(locs_Qf),ecg(locs_Qf),'xk')
plot(t(locs_Sf),ecg(locs_Sf),'og')
plot(t(locs_Tf),ecg(locs_Tf),'^m')
plot(t(locs_Pf),ecg(locs_Pf),'dc')
legend('ECG','R','Q','S','T','P')
xlabel('Time(s)');ylabel('Amplitude (mV)')
title("Señal ")
hold off
%}


%% PRIMER ESTUDIO: frecuencia cardiaca alta

HR_s=mean(diff(locs_Rf))/fs; %Heart rate in seconds
HR_bpm=60/HR_s; %HR in bpm

params(end+1)=HR_bpm;

%% SEGUNDO ESTUDIO: irregularidad en la frecuencia cardiaca. 
%Parametros estadísticos DE HRV: SDNN, RMSSD, PNN50
RR_intervals=diff(locs_Rf)/fs;%Hacemos la derivada discreta para obtener un vector de distancias entre los puntos 

%SDNN (desviación estándar de los intervalos RR): refleja la variabilidad total de la frecuencia cardíaca.
SDNN= std(RR_intervals)*1000;
params(end+1)=SDNN;


%RMSSD: cuadrado de la raiz media de la union de los intervalos
%RR adyacentes.
%Es un parámetro que nos informa de aquellas variaciones que se producen en 
%un corto plazo entre los intervalos RR. Gracias a la rMSSD, obtenemos una 
%información de cómo afecta el Sistema Nervioso Parasimpático (SNP) sobre 
%el sistema cardiovascular.
RMSSD = sqrt(mean(diff(RR_intervals).^2))*1000;%lo paso a ms
%DEBE SER 27+-12 (MENOR QUE 15 Y MAYOR QUE 39 MALO)
params(end+1)=RMSSD;



%PRR50:numero de intervalos consecutivos que son mayores que 50ms entre 
%todos los intervalos
PRR50 = sum(abs(diff(RR_intervals)) > 0.05*mean(RR_intervals))*100/length(RR_intervals);
params(end+1)=PRR50;


params(end+1)=length(RR_intervals);


%% asigno color segun los valores
color=0;
if(HR_bpm>100) 
    color=color+1;
end 
if(SDNN>180||SDNN<102)
    color=color+1;
end
if(RMSSD<15||RMSSD>39)
    color=color+1;
end
if PRR50>10
    color=color+1;
end

params(end+1)=color;
    
%% ESTUDIO DE LOS PARÁMETROS
%{
Ahora la variable params contiene:
    -frecuencia cardiaca (en latidos por MINUTO)
    -irregularidad de la frecuencia cardiaca
       +SDNN:   refleja la variabilidad total de la frecuencia cardíaca.
       +RMSSD:  variaciones que se producen en un corto plazo entre los intervalos RR
       +PNN50: numero de intervalos consecutivos que son mayores que 50ms entre 
               todos los intervalos  
    -Número de intervalos RR que se han detectado para el estudio
%}
end