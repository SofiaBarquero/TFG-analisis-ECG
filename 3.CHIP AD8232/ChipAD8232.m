%% This code is used to obtain the ECG in real time via AD8232 after using the Arduino
%CODE FOR ARDUINO IDE: 
%{
    
    void setup() {
        // initialize the serial communication:
        Serial.begin(9600);
        pinMode(10, INPUT); // Setup for leads off detection LO +
        pinMode(11, INPUT); // Setup for leads off detection LO -
    }

    void loop() {
        if((digitalRead(10) == 1)||(digitalRead(11) == 1)){
            Serial.println('!');
        }
        else{
            // send the value of analog input 0:
            Serial.println(analogRead(A0));
        }
        //Wait for a bit to keep serial data from saturating
        delay(1);
    }
%}

%% Configuration of serial port
clear;clc;
delete(instrfind({'Port'},{'COM5'}));
s=serial('COM5','BaudRate',9600);

fopen(s);
%%
% Leer los datos desde Arduino
numSamples = 5000; % Number of Samples to reed
ecg = zeros(numSamples, 1); %Matrix to storage

tic;
disp('Start')
for i = 1:numSamples
    data = fscanf(s); %Reading a line of the serial port
    ecg(i) = str2double(data); %Conversion of the data to number
end

time=toc;
disp('Time:')
disp(time)

fs=round(numSamples/time);
if(fs<60)
    fs=62;
end
%fs=360;

ecg =ecg(~isnan(ecg));
%% Representation of the data
figure;
plot(ecg);
xlabel('Muestras');
ylabel('Valor');
title('Datos leídos a través del Chip AD8232');

%% Application of the Pan Tompkins Algorithm
%ecg=filtrado(ecg,fs);
[locs_Pf,~,locs_Qf,~,locs_Rf,~,locs_Sf,~,locs_Tf,~]=PamTompkins_f(ecg, fs);
t = 0:1/fs:(length(ecg)-1)/fs;

figure();clf
plot(t,ecg,'b'); hold on
plot(t(locs_Rf),ecg(locs_Rf),'*r')
plot(t(locs_Qf),ecg(locs_Qf),'xk')
plot(t(locs_Sf),ecg(locs_Sf),'og')
plot(t(locs_Tf),ecg(locs_Tf),'^m')
plot(t(locs_Pf),ecg(locs_Pf),'dc')
legend('ECG','R','Q','S','T','P')
xlabel('Time(s)');ylabel('Amplitude (mV)')
title("Detección de picos de la ECG en tiempo real")
hold off

%% Study of parameters

n_est_parameters=6;
parametros_est = cell(1,n_est_parameters);
parametros_est(1,:) = {'HR (60-100)', 'SDNN (102-180)', 'RMSSD (15-39)', 'PNN50 (<10%)', "n_intervalos" ,  "color"};
parametros_est(2,:)=num2cell(obtencion_parametrosSIest(ecg,fs));

n_NOT_est_parameters=15;
parametros_no_est=cell(1,n_NOT_est_parameters);
parametros_no_est(1,:) = {'media dur_QRS (90)', 'desviacion dur_QRS(90)','media amp_QRS(1.5)', 'desviacion amp_QRS(1.5)', 'media dur_P(110)','desviacion dur_P(110)','media amp_P(0.2)','desviacion amp_P(0.2)', 'media dur_QT(400)','desviacion dur_QT(400)', 'media amp_ST','desviacion amp_ST', 'media amp_T(0.3)','desviacion amp_(0.3)','arritmia'};
parametros_no_est(2,:)=num2cell(obtencion_parametrosNOest(ecg,fs));


%% Free buffer
% Free input buffer
flushinput(s);

% Free output buffer
flushoutput(s);

% Close serial port
fclose(s);  % Close port
delete(s);  % Delete port

display("buffer liberado");