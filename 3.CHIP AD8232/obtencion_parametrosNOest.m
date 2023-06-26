function paramNOest=obtencion_parametrosNOest(ecg,fs)

    [locs_Pf,amp_Pf,locs_Qf,amp_Qf,locs_Rf,amp_Rf,locs_Sf,amp_Sf,locs_Tf,amp_Tf]=PamTompkins_f(ecg, fs);
    %{
    PARAMETROS A ESTIMAR:
    duracion complejo QRS:60-110ms +
    amplitud complejo QRS: 0.5-2mV
    duracion onda P: 80-120ms +
    amplitud onda P: 0.1-0.25mV
    duracion intervalo QT: 360-440ms +
    amplitud onda T: 0.1-0.5mV
    amplitud segmento ST: 0.1-0.3mV+
    %}
    paramNOest=[];
    dur_QRS=[];
    dur_P=[];
    amp_P=amp_Pf;
    dur_QT=[];
    amp_ST=amp_Sf;
    amp_T=amp_Tf;
    for i=round(length(ecg)/(fs*4)):round(3*length(ecg)/(4*fs))

        % Cálculo de los parámetros
        %duracion complejo QRS
        if locs_Tf(i)>locs_Rf(i) && locs_Tf(i)<round(3*length(ecg)/(4*fs))
            dur_QRS(i) = locs_Sf(i) - locs_Qf(i); % Duración del complejo QRS
        else
            dur_QRS(i) = locs_Sf(i+1) - locs_Qf(i);
        end
        
        %duracion onda P
        if locs_Pf(i)<locs_Rf(i) && locs_Rf(i)<round(3*length(ecg)/(4*fs))
            dur_P(i) = locs_Rf(i) - locs_Pf(i); % Duración de la onda P
        else
            dur_P(i) = locs_Rf(i+1) - locs_Pf(i);
        end

        %duración intervalo QT
        if locs_Tf(i)>locs_Qf(i) && locs_Tf(i)<round(3*length(ecg)/(4*fs))
            dur_QT(i) = locs_Tf(i) - locs_Qf(i); % Duración del intervalo QT
        else
            dur_QT(i) = locs_Tf(i+1) - locs_Qf(i);
        end

        %amplitud intervalo ST
        if locs_Tf(i)>locs_Rf(i) && locs_Tf(i)<round(3*length(ecg)/(4*fs))
            amp_ST(i) = amp_Tf(i) - amp_Sf(i); % Amplitud del segmento ST
        else
            amp_ST(i) = amp_Tf(i+1) - amp_Sf(i); % Amplitud del segmento ST
        end
        
        amp_QRS(i)=abs(amp_Rf(i))-abs(amp_Qf(i));
        
    end
    
    media_dur_QRS=mean(dur_QRS*fs)/1000;
    desviacion_dur_QRS=std(dur_QRS*fs)/1000;
    
    media_dur_P=mean(dur_P*fs)/1000;
    desviacion_dur_P=std(dur_P*fs)/1000;
    
    media_dur_QT=mean(dur_QT*fs)/1000;
    desviacion_dur_QT=std(dur_QT*fs)/1000;
    
    media_amp_ST=mean(amp_ST);
    desviacion_amp_ST=std(amp_ST); 
    
    media_amp_P=mean(amp_P);
    desviacion_amp_P=std(amp_P);
    
    media_amp_QRS=mean(amp_QRS);
    desviacion_amp_QRS=std(amp_QRS);
    
    media_amp_T=mean(amp_T);
    desviacion_amp_T=std(amp_T);
    % Comparación de los valores obtenidos con valores de referencia
    %(se supone que ya se tienen los valores de referencia para cada parámetro)
    limit_dur_QRS = [60,110];%ms % Límite para la duración del complejo QRS
    limit_dur_P = [80,120]; % Límite para la duración de la onda P
    limit_dur_QT = [360,440]; %ms. Límite para la duración del intervalo QT
    limit_amp_P= [0.1,0.25];%Límite para la amplitud de la onda P
    limit_amp_QRS=[0.5,2];%Límite para la amplitud del complejo QRS
    limit_amp_T=[0.1,0.3];%Límite para la amplitud de la onda T
   arritmia=0;
    if media_dur_QRS > limit_dur_QRS(2) || media_dur_QRS < limit_dur_QRS(1) 
        arritmia=arritmia+1;
        fprintf('\n\tLa duración media del complejo QRS indica arritmia');
    end

    if desviacion_dur_QRS > limit_dur_QRS(2) || desviacion_dur_QRS < limit_dur_QRS(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa desviación de la duración del complejo QRS indica arritmia');
    end

    if media_dur_P > limit_dur_P(2) || media_dur_P < limit_dur_P(1) 
        arritmia=arritmia+1;
        fprintf('\n\tLa duración media de la onda P indica arritmia');
    end
    if desviacion_dur_P > limit_dur_P(2) || desviacion_dur_P < limit_dur_P(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa desviacion duración de la onda P indica arritmia');
    end

    if media_dur_QT > limit_dur_QT(2) || media_dur_QT < limit_dur_QT(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa duración media del intervalo QT indica arritmia');
    end
    if desviacion_dur_QT > limit_dur_QT(2) || desviacion_dur_QT < limit_dur_QT(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa desviacion de duración del intervalo QT indica arritmia');
    end

    %{
    if media_amp_ST > limit_amp_ST || media_amp_ST < limit_amp_ST(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa amplitud media del segmento ST indica arritmia');
    end
    if desviacion_amp_ST > limit_amp_ST || desviacion_amp_ST < limit_amp_ST(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa desviacion amplitud del segmento ST indica arritmia');
    end
    %}
    
    if media_amp_P > limit_amp_P(2)|| media_amp_P < limit_amp_P(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa amplitud media de la onda P indica arritmia');
    end
    if desviacion_amp_P > limit_amp_P(2)|| desviacion_amp_P < limit_amp_P(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa desviacion amplitud de la onda P indica arritmia ');
    end
    
    if media_amp_QRS > limit_amp_QRS(2)|| media_amp_QRS < limit_amp_QRS(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa amplitud media del complejo QRS indica arritmia');
    end
    if desviacion_amp_QRS > limit_amp_QRS(2)|| desviacion_amp_QRS < limit_amp_QRS(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa desviacion amplitud del complejo QRS indica arritmia en ');
    end
    
    if media_amp_T > limit_amp_T(2)|| media_amp_T < limit_amp_T(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa amplitud media de la onda T indica arritmia');
    end
    if desviacion_amp_T > limit_amp_T(2)|| desviacion_amp_T < limit_amp_T(1)
        arritmia=arritmia+1;
        fprintf('\n\tLa desviacion amplitud de la onda T indica arritmia en ');
    end


    %arritmia=arritmia*100/4; %porcentaje
    paramNOest=[abs(media_dur_QRS) abs(desviacion_dur_QRS) abs(media_amp_QRS) abs(desviacion_amp_QRS) abs(media_dur_P) abs(desviacion_dur_P) abs(media_amp_P) abs(desviacion_amp_P) abs(media_dur_QT) abs(desviacion_dur_QT) abs(media_amp_ST) abs(desviacion_amp_ST) abs(media_amp_T) abs(desviacion_amp_T) arritmia];
    
end