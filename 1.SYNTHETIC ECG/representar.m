function representar(nombre,signal,Fs)

n=(1:length(signal))/Fs;


ECG_F =fft(signal);
ECG_F =abs(ECG_F);
ECG_F = ECG_F(1:ceil(end/2));
ECG_F = ECG_F/max(ECG_F);
L = length(ECG_F);
f = (1:1:L)*((Fs/2)/L);
seg_plot=Fs*5;
titulo=append('Señal ', nombre);
%SEÑAL ORIGINAL
figure;
subplot(2,1,1);
plot(n(1:seg_plot),signal(1:seg_plot));
axis tight;
%axis([1 max(n)/4 min(signal) max(signal)]);
title(titulo);
ylabel("Amplitude (V)");
xlabel("Time(s)");

titulo_espectro=append('Espectro señal ', nombre);
subplot(2,1,2);
plot(f, 10*log10(ECG_F)); %.f son las frecuencias en x y sacamos el logaritmo del .P para obtener los decibelios 
axis([0 Fs/2 min(10*log10(ECG_F)) max(10*log10(ECG_F))]);
title(titulo_espectro);
ylabel("Magnitude(dB)")
xlabel("Frequency (Hz)");
end 







