% FFT PARA ANÁLISIS ESPECTRAL

% Este ejemplo muestra el uso de la función FFT para el análisis espectral.
% Un uso común de las FFT es encontrar los componentes de la frecuencia de
% una señal enterrada en una señal ruidosa con dominio de tiempo.

% Primero vamos a crear algunos datos. Considerar los datosmuestreados
% en 1000 Hz

% Empezaremos formando un eje de tiempo para nuestros datos, quefuncione
% desde t=0 hasta t=25 con pasos de 1 milisegundo. Luego formamos una
% señal, x, que contenga ondas seno a 50 Hz y 120 Hz

t = 0:.001:.25;
x = sin(2*pi*50*t) + sin(2*pi*120*t);

% Adicionar algún ruido aleatorio con una desviación estandar de 2para
% producir una señal de ruido y. Dar una mirada a esta señal de ruidoy
% graficándola.
figure;
plot(x(1:50))
title ('Tiempo de Dominio de la Señal Original')


y = x + 2*rand(size(t));
figure;
plot(y(1:50))
title ('Tiempo de Dominio de la Señal Ruidosa')

% Claramente, resulta dificil identificar los componentes de lafrecuencia
% de la mirada a esta señal; es por eso que el análisis espectral estan
% popular.

% Encontrar la trnsformada discreta de Fourier de la señal ruidosa yes
% fácil; solo usar la transformada rápida de Fourier (FFT)

Y = fft(y,256);

% Computar la densidad espectral de la energía, una medida de laenergía a
% varias frecuencias, usando la compleja conjugada (CONJ). Formar uneje de
% frecuencia para los primeros 127 puntos y usarlo para diagramar el
% resultado. (Los restantes 256 puntos son asimétricos.)

Pyy = Y.*conj(Y)/256;
f = 1000/256*(0:127);
figure;
plot(f,Pyy(1:128))
title('Densidad espectral de la energía')
xlabel('Frecuencia(Hz)')

% Enfocar adentro y trazar solamente hasta los 200 Hz. Notar los picos en
% 50 Hz y 120 Hz. Esas son las frecuencias de la señal original.
figure;
plot(f(1:50),Pyy(1:50))
title('Densidad espectral de la energía')
xlabel('Frecuencia (Hz)')
