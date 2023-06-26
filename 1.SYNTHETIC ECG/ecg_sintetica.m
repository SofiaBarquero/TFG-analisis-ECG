close all;clc;clear;
%load ('ecg_PT');
%ecg=ekg;
longitud=50;
fs=500;
[x,ecg]=create_clean_ecg(fs,longitud);

%señal origianl
titulo='ECG Sintética';
representar(titulo,ecg,fs);

%%
%{
 %introduzco la señal respiratoria
 [x,ecg_noise_resp]=respiracion(x,ecg);
 titulo='Señal sintética con ruido respiratorio';
 representar(titulo,ecg_noise_resp,fs);
%}
 
 %introduzco ruido aleatorio
ecg_rb = awgn (ecg, 20); %20dB de SNR
titulo='con ruido blanco con SNR=20dB';
representar(titulo,ecg_rb,fs);


%interferencia de linea base
ecg_lb=int_linea_base(x,ecg_rb);
titulo='con interferencia de linea base';
representar(titulo,ecg_lb,fs);

%interferencia de red
ecg_final = powe_line_interference(x,ecg_lb,fs);
titulo='con ruido añadido';
representar(titulo,ecg_final,fs);


%preproceso la señal
ecg_preprocesada=filtrado(ecg_final,fs);
titulo='preprocesada';
representar(titulo,ecg_preprocesada,fs);



%% 

seg_plot=fs*5;
figure();
hold on;
subplot(3,1,1);
plot(x(1:seg_plot),ecg(1:seg_plot));
%axis([7 10 -inf inf])
title("Synthetic ECG");
%subplot(4,1,2);
%plot(x,ecg_rb);
%axis([7 10 -inf inf])
%title("ecg sintética+ruido blanco");
%subplot(4,1,3);
%plot(x,ecg_lb);
%title("ecg sintética+ruido blanco+interferencia línea base");
%axis([7 10 -inf inf])
subplot(3,1,2);
plot(x(1:seg_plot),ecg_final(1:seg_plot));
title("Noisy ECG")
subplot(3,1,3);
plot(x(1:seg_plot),ecg_preprocesada(1:seg_plot));
title("Processed ECG");
%axis([7 10 -inf inf])
legend("ruido blanco","interferencia linea base","interferencia red eléctrica","sintética");




%%
%%le aplico pamtomkins
[locs_Pf,amp_Pf,locs_Qf,amp_Qf,locs_Rf,amp_Rf,locs_Sf,amp_Sf,locs_Tf,amp_Tf]=PamTompkins_f(ecg_preprocesada, fs);

seg_plot=fs*5;
figure();clf
plot(x,ecg_preprocesada,'b'); hold on
seg_plotQRS= seg_plot/fs;
plotLineQRS=seg_plotQRS:2*seg_plotQRS;
plot(x(locs_Rf),ecg_preprocesada(locs_Rf),'*r')
plot(x(locs_Qf),ecg_preprocesada(locs_Qf),'xk')
plot(x(locs_Sf),ecg_preprocesada(locs_Sf),'og')
plot(x(locs_Tf),ecg_preprocesada(locs_Tf),'^m')
plot(x(locs_Pf),ecg_preprocesada(locs_Pf),'dc')
legend('ECG','R','Q','S','T','P')
xlabel('Time(s)');ylabel('Amplitude (mV)')
title("Picos Señal sintética con ruido filtrado")
hold off
axis tight

%% CÁLCULO DE PARÁMETROS
n_parametros_est=6;
parametros_est = cell(1,n_parametros_est);
parametros_est(1,:) = {'HR (60-100)', 'SDNN (102-180)', 'RMSSD (15-39)', 'PNN50 (<10%)', "n_intervalos" ,  "color"};
parametros_est(2,:)=num2cell(obtencion_parametrosSIest(ecg,fs));

n_parametros_NO_est=15;
parametros_no_est=cell(1,n_parametros_NO_est);
parametros_no_est(1,:) = {'media dur_QRS (90)', 'desviacion dur_QRS(90)','media amp_QRS(1.5)', 'desviacion amp_QRS(1.5)', 'media dur_P(110)','desviacion dur_P(110)','media amp_P(0.2)','desviacion amp_P(0.2)', 'media dur_QT(400)','desviacion dur_QT(400)', 'media amp_ST','desviacion amp_ST', 'media amp_T(0.3)','desviacion amp_(0.3)','arritmia'};
parametros_no_est(2,:)=num2cell(obtencion_parametrosNOest(ecg,fs));


