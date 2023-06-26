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

%{
figure();
plot(t,ekg)
title('Bandpass filter');xlabel('Time(s)');ylabel('Amplitude')
%}
% 1. Bandpass filter
[z,p] = butter(5,[1 30]/(fs/2));
ekg_band = filtfilt(z,p,ekg);
ekg_band=ekg_band/max(abs(ekg_band));
%{
figure();
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
figure;
plot(t,ekg_der)
title('Derivative filter');xlabel('Time(s)');ylabel('Amplitude')
%}
% 3.Squaring
ekg_sq = ekg_der.^2;
%{
figure
plot(t,ekg_sq)
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
figure();
plot(t,ekg_ma)
title('MA filter');xlabel('Time(s)');ylabel('Amplitude')
%}

%% 5. Threshold

ekg_nor = ekg_ma/max(ekg_ma); %normalizacion de la señal con respecto al maximo 
%ecg_m = conv(ekg_nor ,ones(1 ,round(0.150*fs))/round(0.150*fs));

%% representación Maria
% Non-adaptive threshold or Initial guess on the threshold for the adaptive
thr = 0.4;


%% Representación 
[locs_Pf,amp_Pf,locs_Qf,amp_Qf,locs_Rf,amp_Rf,locs_Sf,amp_Sf,locs_Tf,amp_Tf]=thresholds_PT(ekg,ekg_ma,ekg_band,fs);








