function signal_filtrada=filtrado(signal,Fs)

n=(1:length(signal))/Fs;


%FILTRO1: FPA, fc=0.
N     = 20;   % Order
Fpass = 0.5;  % Passband Frequency
Apass = 1;    % Passband Ripple (dB)
Astop = 80;   % Stopband Attenuation (dB)
% Construct an FDESIGN object and call its ELLIP method.
filtro1  = fdesign.highpass('N,Fp,Ast,Ap', N, Fpass, Astop, Apass, Fs);
F1 = design(filtro1, 'ellip');
signal1=filter((1-2^-7)*[1 -1],[1 -(1-2^-6)],signal);%paso la señal original por el primer filtro


%FILTRO2
Fpass1 = 47;          % First Passband Frequency
Fstop1 = 48;          % First Stopband Frequency
Fstop2 = 52;          % Second Stopband Frequency
Fpass2 = 53;          % Second Passband Frequency
Apass1 = 0.5;         % First Passband Ripple (dB)
Astop  = 60;          % Stopband Attenuation (dB)
Apass2 = 1;           % Second Passband Ripple (dB)
match  = 'stopband';  % Band to match exactly
% Construct an FDESIGN object and call its BUTTER method.
filtro2  = fdesign.bandstop(Fpass1, Fstop1, Fstop2, Fpass2, Apass1, Astop, ...
                      Apass2, Fs);
F2 = design(filtro2, 'butter', 'MatchExactly', match);
signal2=filter(F2,signal1);

%}

%FILTRO3
%signal_final=filter(filt3.tf.num,filt3.tf.den,signal2);
Fpass = 90;              % Passband Frequency
Fstop = 100;             % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.0001;          % Stopband Attenuation
dens  = 20;              % Density Factor
% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
F3 = dfilt.dffir(b);
signal3=filter(F3,signal2);

%ESPECTRO DE LA SEÑAL Final filtrada
ECG_F_3 =fft(signal3);
ECG_F_3 =abs(ECG_F_3);
ECG_F_3 = ECG_F_3(1:ceil(end/2));
ECG_F_3 = ECG_F_3/max(ECG_F_3);
L3 = length(ECG_F_3);
f = (1:1:L3)*((Fs/2)/L3);

%{
LA PASO POR EL FILTRO WAVELET 
signal_filtrada=filtrado_Wavelet(signal3,Fs);


%OBTENCION DEL ESPECTRO DE LA SEÑAL pasada por wavelet
ECG_F_final =fft(signal_filtrada);
ECG_F_final =abs(ECG_F_final);
ECG_F_final = ECG_F_final(1:ceil(end/2));
ECG_F_final = ECG_F_final/max(ECG_F_final);
L = length(ECG_F_final);
f = (1:1:L)*((Fs/2)/L);
%}
%{
%REPRESENTACION
figure;
subplot(2,1,1);
plot(n,signal3);
title("Señal procesada");
ylabel("Amplitud (V)")
xlabel("Tiempo(s)");
xlim([0 5])
subplot(2,1,2);
plot(f, 10*log10(ECG_F_3));%logaritmo para representarlo en dB
title("Espectro señal procesada");
ylabel("Magnitud(dB)")
xlabel("Frecuencia (Hz)");
%}

%{
%REPRESENTO Y COMPARO CON Y SIN WAVELET
figure;
subplot(2,2,1);
plot(n,signal3);
title("señal antes wavelet");
subplot(2,2,2);
plot(n,signal_filtrada);
title("señal despues wavelet");
subplot(2,2,3);
plot(f,ECG_F_3);
title("Espectro señal antes wavelet");
subplot(2,2,4);
plot(f,ECG_F_final);
title("Espectro señal despues wavelet");
%}

signal_filtrada=signal3 ;
end