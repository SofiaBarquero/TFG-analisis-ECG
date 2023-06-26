function [locs_Pf,amp_Pf,locs_Qf,amp_Qf,locs_Rf,amp_Rf,locs_Sf,amp_Sf,locs_Tf,amp_Tf]=PamTompkins_f(ekg, fs)
%% Pan-Tompkins algorithm
% QRS Detection
% 1. Bandpass filter
% 2. Derivative filter
% 3. Square filter
% 4. MA filter
% 5. Threshold
% 6. Detection
%clear;close all;clc

if fs==200
    ekg = ekg -mean(ekg);    %to get rid of the DC offset (which appears at f=0)
end
seg_plot = 5*fs;
plotLine = seg_plot:2*seg_plot; %fs gives the samples per second so we are taking samples from 5s to 10s to plot our signal (we are removing the initial samples that may have incorrect values)

t = 0:1/fs:(length(ekg)-1)/fs;
% 1. Bandpass filter
[z,p] = butter(5,[1 30]/(fs/2));
ekg_band = filtfilt(z,p,ekg);
ekg_band=ekg_band/max(abs(ekg_band));
%{
figure();
subplot(221)
plot(t,ekg_band)
title('Bandpass filter');xlabel('Time(s)');ylabel('Amplitude')
%}

% 2. Derivative Filter
% First order derivative
%b = [1 -1];
b = [-1 -2 0 2 1]/8;
ekg_der = filtfilt(b,1,ekg_band);
ekg_der=ekg_der/max(ekg_der);
%{
subplot(222)
plot(t(plotLine),ekg_der(plotLine))
title('Derivative filter');xlabel('Time(s)');ylabel('Amplitude')
%}
% 3.Squaring
ekg_sq = ekg_der.^2;
%{
subplot(223)
plot(t(plotLine),ekg_sq(plotLine))
title('Square');xlabel('Time(s)');ylabel('Amplitude')
%}
% 4. Moving Average
%originalmente, si fs=200Hz, t_ma=150ms
%
t_ma = 150;%150*fs/200; %ms. Window %300
L = round(t_ma*10^-3*fs);
b = ones (1 ,L)/L;
ekg_ma = filtfilt(b,1,ekg_sq);
%}

%{
%subplot(224)
figure();
plot(t,ekg_ma)
title('MA filter');xlabel('Time(s)');ylabel('Amplitude')
%}
%{
%representacion polos y ceros
figure(2);
zplane(z,p)
title('Polos y ceros bandpass filter');

%representaicon original y filtrada
representar('original',ekg,fs);
representar('filtrada paso banda',ekg_band,fs);

%calculo de las fft y representacion de espectros superpuestos
[ekg_fft,f1]=calculoFFT(ekg,fs);
[ekg_band_fft,f2]=calculoFFT(ekg_band,fs);
[ekg_der_fft,f3]=calculoFFT(ekg_der,fs);
[ekg_sq_fft,f4]=calculoFFT(ekg_sq,fs);
[ekg_ma_fft,f5]=calculoFFT(ekg_ma,fs);

figure(3);
plot(f1, 10*log10(ekg_fft));
hold on;
plot(f2, 10*log10(ekg_band_fft));
plot(f3, 10*log10(ekg_der_fft));
plot(f4, 10*log10(ekg_sq_fft));
plot(f5, 10*log10(ekg_ma_fft));
legend('señal original','señal filtrada paso banda','señal filtrada derivativo','señal tras funcion cuadratica','señal tras ventana deslizante');
ylabel("Magnitud(dB)")
xlabel("Frecuencia (Hz)");
title('Espectros');

%}

%% 5. Threshold

ekg_nor = ekg_ma/max(ekg_ma); %normalizacion de la señal con respecto al maximo 
%ecg_m = conv(ekg_nor ,ones(1 ,round(0.150*fs))/round(0.150*fs));

%% representación Maria
% Non-adaptive threshold or Initial guess on the threshold for the adaptive
thr = 0.4;
 % This piece selects the indices of the chunks over the threshold (vector with 0 or 1 indicating above or below the threshold
%{
 t_thr =(ekg_nor>thr)';

left = find(diff([0 t_thr])==1);    %We keep the position where the difference is a 1 (left side of the chunk above threshold)
right = find(diff([t_thr 0])==-1);  %We keep the position where the difference is a -1 (right side of the chunk above threshold)

R_loc = zeros(length(left),1);
R_value = zeros(length(left),1);
Q_loc = zeros(length(left),1);
Q_value = zeros(length(left),1);
S_loc = zeros(length(left),1);
S_value = zeros(length(left),1);
T_loc = zeros(length(left),1);
T_value = zeros(length(left),1);
P_loc = zeros(length(left),1);
P_value = zeros(length(left),1);

for i=1:(length(left)-1)     %-1 needed to avoid exceeding array when looking for the P and T waves
    
     [R_value(i),R_loc(i)] = max( ekg(left(i):right(i)) );    %We look in the ECG signal the max value between the left and right of the chunk which is the R peak from the QRS
     R_loc(i) = R_loc(i)-1+left(i); % add offset since we are looking in a vector of values given by left(i):right(i) so we need to add the positions of left(i)

     [Q_value(i),Q_loc(i)] = min( ekg(left(i):R_loc(i)) );    %We look in the ECG signal the min value between the left and R peak of the chunk
     Q_loc(i) = Q_loc(i)-1+left(i); % add offset

     [S_value(i),S_loc(i)] = min( ekg(R_loc(i):right(i)) );   %We look for the other min from the R peak to the right of the chunk
     S_loc(i) = S_loc(i)-1+R_loc(i); % add offset
     
     [T_value(i),T_loc(i)] = max( ekg(right(i):(floor(0.5*(right(i)+left(i+1)))))); %T should be in the first half between the right part of the chunk and the next left
     T_loc(i) = T_loc(i)-1+right(i); % add offset

     if i==(length(left)-1)
         [R_value(i+1),R_loc(i+1)] = max( ekg(left(i+1):right(i+1)) );    
         R_loc(i+1) = R_loc(i+1)-1+left(i+1); % add offset 

         [Q_value(i+1),Q_loc(i+1)] = min( ekg(left(i+1):R_loc(i+1)) );   
         Q_loc(i+1) = Q_loc(i+1)-1+left(i+1); % add offset

         [S_value(i+1),S_loc(i+1)] = min( ekg(R_loc(i+1):right(i+1)) );   
         S_loc(i+1) = S_loc(i+1)-1+R_loc(i+1); % add offset

         [T_value(i+1),T_loc(i+1)] = max(ekg(right(i+1):length(ekg))); %Last T should be after last right chunk
         T_loc(i+1) = T_loc(i+1)-1+right(i+1); % add offset
     end

     if i==1
         [P_value(i),P_loc(i)] = max(ekg(floor(0.25*(Q_loc(i))):Q_loc(i))); %First P wave should be before the first Q, get rid of first quarter to assure we don't start with a QRS complex
         P_loc(i)=P_loc(i)-1+floor(0.25*(Q_loc(i)));

     end
     
     [P_value(i+1),P_loc(i+1)] = max(ekg((floor(0.5*(right(i)+left(i+1))):left(i+1)))); %P should be in the second half between right chunk and the next left chunk
     P_loc(i+1) = P_loc(i+1)-1+floor(0.5*(right(i)+left(i+1))); % add offset
     
end
 %}
%{
figure();clf
plot(t(seg_plot:(3*seg_plot)+fs),ekg(seg_plot:(3*seg_plot)+fs),'b'); hold on
seg_plotQRS= seg_plot/fs;
plot(t(R_loc(seg_plotQRS:3*(seg_plotQRS-1))),ekg(R_loc(seg_plotQRS:3*(seg_plotQRS-1))),'*r')
plot(t(Q_loc(seg_plotQRS:3*(seg_plotQRS-1))),ekg(Q_loc(seg_plotQRS:3*(seg_plotQRS-1))),'xk')
plot(t(S_loc(seg_plotQRS:3*(seg_plotQRS-1))),ekg(S_loc(seg_plotQRS:3*(seg_plotQRS-1))),'og')
plot(t(T_loc(seg_plotQRS:3*(seg_plotQRS-1))),ekg(T_loc(seg_plotQRS:3*(seg_plotQRS-1))),'^m')
plot(t(P_loc(seg_plotQRS:3*(seg_plotQRS-1))),ekg(P_loc(seg_plotQRS:3*(seg_plotQRS-1))),'dc')
legend('ECG','R','Q','S','T','P')
xlabel('Time(s)');ylabel('Amplitude (mV)')
title("Representacion Maria")
hold off
%}
%{
figure();clf
plot(t,ekg,'b'); hold on
seg_plotQRS= seg_plot/fs;
plot(t(R_loc),ekg(R_loc),'*r')
plot(t(Q_loc),ekg(Q_loc),'xk')
plot(t(S_loc),ekg(S_loc),'og')
plot(t(T_loc),ekg(T_loc),'^m')
plot(t(P_loc),ekg(P_loc),'dc')
legend('ECG','R','Q','S','T','P')
xlabel('Time(s)');ylabel('Amplitude (mV)')
title("Representacion Maria")
hold off
%}


%% Representación 
[locs_Pf,amp_Pf,locs_Qf,amp_Qf,locs_Rf,amp_Rf,locs_Sf,amp_Sf,locs_Tf,amp_Tf]=thresholds_PT(ekg,ekg_ma,ekg_band,fs);
%{
figure();clf
plot(t,ekg,'b'); hold on
seg_plotQRS= seg_plot/fs;
plot(t(locs_Rf),ekg(locs_Rf),'*r')
plot(t(locs_Qf),ekg(locs_Qf),'xk')
plot(t(locs_Sf),ekg(locs_Sf),'og')
plot(t(locs_Tf),ekg(locs_Tf),'^m')
plot(t(locs_Pf),ekg(locs_Pf),'dc')
legend('ECG','R','Q','S','T','P')
xlabel('Time(s)');ylabel('Amplitude (mV)')
title("Representacion Mia")
hold off
%}

%{
figure();clf
plot(t(plotLine),ekg(plotLine),'b'); hold on
seg_plotQRS= seg_plot/fs;
plotLineQRS=seg_plotQRS:2*seg_plotQRS;
plot(t(locs_Rf(plotLineQRS)),ekg(locs_Rf(plotLineQRS)),'*r')
plot(t(locs_Qf(plotLineQRS)),ekg(locs_Qf(plotLineQRS)),'xk')
plot(t(locs_Sf(plotLineQRS)),ekg(locs_Sf(plotLineQRS)),'og')
plot(t(locs_Tf(plotLineQRS)),ekg(locs_Tf(plotLineQRS)),'^m')
plot(t(locs_Pf(plotLineQRS)),ekg(locs_Pf(plotLineQRS)),'dc')
legend('ECG','R','Q','S','T','P')
xlabel('Time(s)');ylabel('Amplitude (mV)')
title("Representacion Mia")
hold off
axis tight


figure();clf
plot(t(2500:5000),ekg(2500:5000),'b'); hold on
seg_plotQRS= seg_plot/fs;
plotLineQRS=seg_plotQRS:2*seg_plotQRS;
plot(t(locs_Rf(5:8)),ekg(locs_Rf(5:8)),'*r')
plot(t(locs_Qf(5:8)),ekg(locs_Qf(5:8)),'xk')
plot(t(locs_Sf(5:8)),ekg(locs_Sf(5:8)),'og')
plot(t(locs_Tf(5:8)),ekg(locs_Tf(5:8)),'^m')
plot(t(locs_Pf(5:8)),ekg(locs_Pf(5:8)),'dc')
legend('ECG','R','Q','S','T','P')
xlabel('Time(s)');ylabel('Amplitude (mV)')
title("Representacion Mia")
hold off
axis tight

%}

%{
%% comparacion erroes de ambos metodos de deteccion
rerror=immse(R_loc,locs_Rf(1:length(R_loc)).');
R_error=(rerror);

qerror=immse(Q_loc,locs_Qf(1:length(Q_loc)).');
Q_error=(qerror);

serror=immse(S_loc,locs_Sf(1:length(S_loc)).');
S_error=(serror);

terror=immse(T_loc,locs_Tf(1:length(T_loc)).');
T_error=(terror);

perror=immse(P_loc,locs_Pf(1:length(P_loc)).');
P_error=(perror);

figure;
bar(1,R_error);
hold on;
bar(2,Q_error);
bar(3,S_error);
bar(4,T_error);
bar(5,P_error);
legend("Error R","Error Q", "Error S", "Error T", "Error P");
title("Error de los picos detectados entre ambos metodos");
%}


%% Extracting the data
%{
HR_s=mean(diff(locs_Rf))/fs; %Heart rate in seconds
HR_bpm=60/HR_s; %HR in bpm
dPR_seconds=mean((R_loc(2:length(R_loc))-P_loc(2:length(P_loc))))/fs;  %Don't take into account the first P wave since it is a source of error due to a not so accurate detection
dRT_seconds=mean(T_loc(1:(length(T_loc)-1))-R_loc(1:(length(R_loc)-1)))/fs; %Don't take into account the last T wave since it is a source of error due to a not so accurate detection
dPT_seconds=mean(T_loc(2:(length(T_loc)-1))-P_loc(2:(length(P_loc)-1)))/fs; %Don't take into account the first and last T wave due to being a source of error

%Irregular beats (when the data differs in more than 50% as the chosen parameter)
irregular_loc=[];
count=1;
for i=1:(length(R_loc)-1)
    beat=(R_loc(i+1)-R_loc(i))/fs;
    PR=(R_loc(i)-P_loc(i))/fs;
    RT=(T_loc(i)-R_loc(i))/fs;
    PT=(T_loc(i)-P_loc(i))/fs;
    if beat>(1.5*HR_s)||beat<(0.5*HR_s)||PR>(1.5*dPR_seconds)||PR<(0.5*dPR_seconds)||RT>(1.5*dRT_seconds)||RT<(0.5*dRT_seconds)||PT>(1.5*dPT_seconds)||PT<(0.5*dPT_seconds)
        irregular_loc(count)=i;
        count=count+1;
    end
    if i==(length(R_loc)-1)
        PR=(R_loc(i+1)-P_loc(i+1))/fs;
        RT=(T_loc(i+1)-R_loc(i+1))/fs;
        PT=(T_loc(i+1)-P_loc(i+1))/fs;
        if beat>(1.5*HR_s)||beat<(0.5*HR_s)||PR>(1.5*dPR_seconds)||PR<(0.5*dPR_seconds)||RT>(1.5*dRT_seconds)||RT<(0.5*dRT_seconds)||PT>(1.5*dPT_seconds)||PT<(0.5*dPT_seconds)
            irregular_loc(count)=i+1;
            count=count+1;
        end
    end

end
%}
end









