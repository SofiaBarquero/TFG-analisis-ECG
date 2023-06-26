function [locs_Pf,amp_Pf,locs_Qf,amp_Qf,locs_Rf,amp_Rf,locs_Sf,amp_Sf,locs_Tf,amp_Tf]=thresholds_PT (signal,signal_i, signal_f,fs)
%{
function [qrs_f_i]=thresholds_PT (signal,signal_i, signal_f,fs)
%Las variables que finalizan en “I” hacen referencia a la se˜nal integrada y “F” hacen referencia a la se˜nal filtrada.

%signal--> señal ecg original (preprocesada)
%signal_i--> señal ecg integrada
%signal_f--> señal ecg pasada por el filtro paso banda

%integration waveform:
%PEAKI is the overall peak,
%SPKI is the running estimate of the signal peak,
%NPKI is the running estimate of the noise peak,
%THRESHOLD Il is the first threshold applied
%THRESHOLD I2 is the second threshold applied

%filtered ECG:
%PEAKF is the overall peak,
%SPKF is the running estimate of the signal peak,
%NPKF is the running estimate of the noise peak,
%THRESHOLD Fl is the first threshold applied, and
%THRESHOLD F2 is the second threshold applied.
%}


[pks_i,loc_i]=findpeaks(signal_i,'MINPEAKDISTANCE',round(0.2*fs));%picos de la señal integrada

                     
%INICIALIZACIONES
picos =length(pks_i); %numero de picos de la señal original

%variables de los intervalors
RR1=0; %mean of the eight most-recent sequential RR intervals regardless of their values.
RR2=0; %average is based on selected beats of the most recent RR interval that fell between the acceptable low and high RR-interval limits
RRll=0; %low limit
RRhl=0; %high limit
RRml=0; % If a QRS complex is not found during the interval specified by the RR MISSED LIMIT, the maximal peak reserved between the -two established thresholds is considered to be a QRS candidate.
RRn=[]; %los intervalos RR más recientes (solo necesito 8)
RR_paraRR2=[]; %para guardar los intervalos que caigan dentro de los valores aceptados de RR2
%matrices de dos columnas (amplitud y localizacion) para almacenar los
%picos
qrs_peaks_i=zeros(1,picos); %almacena los picos que se detectan como complejos QRS en la señal integrada
qrs_i_i=zeros(1,picos); %index de los picos pertenecientes al complejo qrs
noise_peak=zeros(1,picos); %almacena los picos que se detectan como ruido
noise_i=zeros(1,picos);%index de los picos ruido

qrs_peaks_f=zeros(1,picos); %almacenara los picos qrs detectados
qrs_f_i=zeros(1,picos); %almacena las posiciones de los picos qrs en la señal filtrada


fila_n=1;
beat=0; 
beat_f=0;

%-----------------------inicializaciones
PEAKI =max(signal_i(1:(2*fs)));
SPKI = PEAKI*(1/3); 
NPKI=mean(signal_i(1:2*fs))*1/2; %0.5 of the mean signal is considered to be noise
PEAKF =max (signal_f(1:(2*fs)));
SPKF = PEAKF*(1/3); 
NPKF=mean(signal_f(1:2*fs))*1/2;
    
THRESHOLDI1=SPKI;
THRESHOLDI2=NPKI;
THRESHOLDF1=SPKF;
THRESHOLDF2=NPKF;

onda_t=0;


for i=1:picos
  
    PEAKI=pks_i(i);
    
    
    %creacion de la ventana de trabajo con respecto a la señal filtrada
    if loc_i(i)-round(0.15*fs)>=1 && loc_i(i)<=length(signal_f)
       [PEAKF,x] = max(signal_f(loc_i(i)-round(0.150*fs):loc_i(i))); %se selecciona el pico que haya desde la localizacion del pico en cuestion menos 0.15ms hasta la localizacion del pico en cuestion
       x=x+loc_i(i)-round(0.150*fs);
    else
        if i==1
            [PEAKF,x]=max(signal_f(1:loc_i(i))); %primera muestra
        elseif loc_i(i)>=length(signal_f) %ultima
            [PEAKF,x]=max(signal_f(loc_i(i)-round(0.150*fs):end));
            x=x+loc_i(i)-round(0.150*fs);
        end
    end
     
    
    %comparo umbrales
    if PEAKI>=THRESHOLDI1 %PEAKI is part of the possible QRS peaks
        
        %Antes de comporbar el siguiente, si no hay pico en 360ms del
        %anterior, ver si es una onda T
        if beat_f>=3
            %IDENTIFICACION ONDA T
            if loc_i(i)-qrs_f_i(beat_f)<=round(0.36*fs)
                %comparo la pendiente del pico que se esta estudiando con
                %respecto al ultimo guardado
                pendiente1 = mean(diff(signal_i(loc_i(i)-round(0.075*fs):loc_i(i))));
                pendiente2 = mean(diff(signal_i(qrs_f_i(beat_f)-round(0.075*fs):qrs_f_i(beat_f))));
                if abs(pendiente1)<=abs(0.5*pendiente2) %onda t detectado
                    noise_peak(fila_n)=PEAKI;
                    noise_i(fila_n)=loc_i(i);
                    fila_n=fila_n+1;

                    %hay que ajustar los thresholds de ruido
                    NPKI=0.125*PEAKI+0.875*NPKI;
                    NPKF=0.125*PEAKF+0.875*NPKF;
                    
                    onda_t=1;
                else %es complejo qrs
                    beat=beat+1;
                    qrs_i_i(beat)=loc_i(i);
                    qrs_peaks_i(beat)=PEAKI;
                    
                    onda_t=0;
                    
                end
            end
        end   
        
        if onda_t==0 %no se detecto onda T
            %comprobaciones umbral señal filtrada
            if PEAKF>THRESHOLDF1 %peak IS part of the QRS peaks
                beat_f=beat_f+1;
                qrs_f_i(beat_f)=x; %guardo la posicion (coordenada x) del pico qrs
                qrs_peaks_f(beat_f)=PEAKF; %guardo la amplitud del pico
                SPKF = 0.125*PEAKF+0.875*SPKF; %actualizo los parametros
            end
            SPKI = 0.125*PEAKI+0.875*SPKI;
        end
    else %RUIDO: PEAKI<THRESHOLDI1
        if PEAKI>=THRESHOLDI2 %mayor que el umbral de ruido de la integrada
            %{
            NPKI = 0.125 * PEAKI + 0.875* NPKI;
            NPKF = 0.125 * PEAKF + 0.875* NPKF; 
            %}
            if beat_f>0
                [PEAKI2,iPEAKI2] = max(signal_i(qrs_f_i(beat_f)+ round(0.200*fs):loc_i(i)-round(0.200*fs))); % search back and locate the max in the maximal interval
                iPEAKI2= qrs_f_i(beat_f)+ round(0.200*fs) + iPEAKI2;
                if PEAKI2>THRESHOLDI2
                    beat=beat+1;
                    qrs_peaks_i(beat)=PEAKI2;
                    qrs_i_i(beat)=iPEAKI2;

                    if iPEAKI2<length(signal_f)
                        [PEAKF2,iPEAKF2]=max(signal_f(iPEAKI2-round(0.15*fs):iPEAKI2));
                        iPEAKF2=iPEAKF2+iPEAKI2-round(0.15*fs);
                    else
                        [PEAKF2,iPEAKF2]=max(signal_f(iPEAKI2-round(0.15*fs):end));
                        iPEAKF2=iPEAKF2+iPEAKI2-round(0.15*fs);
                    end

                    if PEAKF2>THRESHOLDF2
                        beat_f=beat_f+1;
                        qrs_peaks_f(beat_f)=PEAKF2;
                        qrs_f_i(beat_f)=iPEAKF2;

                        SPKF = 0.25*PEAKF2+0.75*SPKF;
                    end
                    SPKI = 0.25*PEAKI+0.75*SPKI;
                end
            else
                
                
            end
        else %menor que el umbral de ruido de la integrada (PEAKI<THRESHOLDI2)
                noise_peak(fila_n)=PEAKI;
                noise_i(fila_n)=loc_i(i);
                fila_n=fila_n+1;
                
                NPKI = 0.125 * PEAKI + 0.875* NPKI;
                NPKF = 0.125 * PEAKF + 0.875* NPKF; 
        end
    end
    
    %UPDATE HEART RATE
    if beat_f>=9 %cuando ya tenemos ocho picos (ocho intervalos, nueve latidos)
        RRn=qrs_f_i((beat_f-8):beat_f);
        
        RR1=mean(diff(RRn)); %media de los ultimos ocho intervalos

        RR_actual=qrs_f_i(beat_f)-qrs_f_i(beat_f-1); %intervalo del complejo actual
        if beat_f==9
            RRll=0.92*RR1; 
            RRhl=1.16*RR1;
            RRml=1.16*RR1;
        end
        
        if RR_actual<=RRll|| RR_actual >= RRhl %intervalo irregular
            THRESHOLDI1=0.5*THRESHOLDI1;
            THRESHOLDF1=0.5*THRESHOLDF1;
        else %REGULAR HEART RATE
            RR_paraRR2 = vertcat(RR_paraRR2,RR_actual);
            %RR2=RR1;
            if length(RR_paraRR2)>8
                RR2=mean(diff(RR_paraRR2(end-8:end)));
            end
        end
        
        if RR2
            RRll=0.92*RR2; 
            RRhl=1.16*RR2;
            RRml=1.16*RR2;
        end
          
        
        %SEARCH-BACK
        %comprobar si no se ha detectado ningun pico en el 166% de la media
        %actual desde el ultimo pico detectado (limite RRml, RR missed limit)
        if(loc_i(i)-qrs_f_i(beat_f))>=RRml 
            %nueva ventana 
            [PEAKI2,iPEAKI2] = max(signal_i(qrs_f_i(beat_f)+ round(0.200*fs):loc_i(i)-round(0.200*fs))); % search back and locate the max in the maximal interval
            iPEAKI2= qrs_f_i(beat_f)+ round(0.200*fs) + iPEAKI2;
            if PEAKI2>THRESHOLDI2
                beat=beat+1;
                qrs_peaks_i(beat)=PEAKI2;
                qrs_i_i(beat)=iPEAKI2;

                if iPEAKI2<length(signal_f)
                    [PEAKF2,iPEAKF2]=max(signal_f(iPEAKI2-round(0.15*fs):iPEAKI2));
                    iPEAKF2=iPEAKF2+iPEAKI2-round(0.15*fs);
                else
                    [PEAKF2,iPEAKF2]=max(signal_f(iPEAKI2-round(0.15*fs):end));
                    iPEAKF2=iPEAKF2+iPEAKI2-round(0.15*fs);
                end

                if PEAKF2>THRESHOLDF2
                    beat_f=beat_f+1;
                    qrs_peaks_f(beat_f)=PEAKF2;
                    qrs_f_i(beat_f)=iPEAKF2;

                    SPKF = 0.25*PEAKF2+0.75*SPKF;
                end
                SPKI = 0.25*PEAKI2+0.75*SPKI;
            end
        end  
     end
    
    %{
    %ajuste de los umbrales
    %umbrales señal integrada
    if NPKI~=0 || SPKI~=0
        THRESHOLDI1=NPKI+0.25*abs(SPKI-NPKI); %threshold de la señal integrada
        THRESHOLDI2=0.5*THRESHOLDI1;
    end
    %umbrales señal filtrada
    if NPKF~=0 || SPKF~=0
        THRESHOLDF1 = NPKF + 0.25 * abs(SPKF - NPKF);%threshold de la señal filtrada
        THRESHOLDF2=0.5*THRESHOLDF1;
    end
      %}  
    %
    THRESHOLDI1=NPKI+0.25*(SPKI-NPKI); %threshold de la señal integrada
    THRESHOLDI2=0.5*THRESHOLDI1;
    THRESHOLDF1 = NPKF + 0.25 * (SPKF - NPKF);%threshold de la señal filtrada
    THRESHOLDF2=0.5*THRESHOLDF1;
    %}
    
    %reset de parametros
    %PEAKF=0;
    
end

qrs_f_i=qrs_f_i(1:beat_f); %para eliminar los ceros que puedan sobrar al final
amp_Rf=qrs_peaks_f(1:beat_f);
[locs_Pf,amp_Pf,locs_Qf,amp_Qf,locs_Rf,locs_Sf,amp_Sf,locs_Tf,amp_Tf]=peaks_detection(signal,fs,qrs_f_i);




end