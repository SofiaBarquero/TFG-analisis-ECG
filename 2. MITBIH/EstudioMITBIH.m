%% 
%This code is used to Obtain and study the signals in the mitbih database
%and use the functions developed to obtain the parameters of study.

%%
close all;
clc;
clear;

%paths
data_dir = [pwd filesep 'database' filesep 'mitdb' filesep];
file_dir= [pwd filesep 'mit-bih-arrhythmia-database-1.0.0' filesep 'mit-bih-arrhythmia-database-1.0.0' filesep];

%Load the list of records in the validation set.
fid = fopen([file_dir filesep 'RECORDS'],'r');
if(fid ~= -1)
    RECLIST = textscan(fid,'%s');
    disp(['Could not open ' data_dir 'RECORDS for scoring. Exiting...']);
end
fclose(fid);
RECORDS = RECLIST{1};


n_parametros_est=7;
parametros_est = cell(length(RECORDS),n_parametros_est);
parametros_est(1,:) = {'N_Entrada','HR', 'SDNN', 'RMSSD', 'PNN50', "n_intervalos" ,  "color"};

n_parametros_NO_est=14;
parametros_no_est=cell(length(RECORDS),n_parametros_NO_est);
parametros_no_est(1,:) = {'N_Entrada','media dur_QRS', 'desviacion dur_QRS','media amp_QRS', 'desviacion amp_QRS', 'media dur_P','desviacion dur_P','media amp_P','desviacion amp_P', 'media dur_QT','desviacion dur_QT', 'media amp_T','desviacion amp_T','arritmia'};
    
n_ecg=length(RECORDS);
anotaciones=zeros(n_ecg,3);

%% 
for i =1:n_ecg
    if (i~=27 && i~=29)
        fname = RECORDS{i};
        fname=strcat(fname);  
        parametros_est(i+1,1)=num2cell(str2double(fname));
        parametros_no_est(i+1,1)=num2cell(str2double(fname));
        fprintf('\nEstudiando entrada %d de %d', i, n_ecg);
        %stadistic parameters
        %parametros_est(i+1,2:end) = num2cell(deteccionMITBIH(['mitdb/' fname]));
        %NOT stadistic parameters
        parametros_no_est(i+1,2:end) = num2cell(obtencion_parametrosNOest(['mitdb/' fname]));
        %[ann,type,subtype] = rdann(['mitdb/' fname],'atr');
    end
end

%% Statistic analysis representation
color=cell2mat(parametros_est(2:(end),n_parametros_est));

c = {};
for i = 1:length(color)
    if color(i) == 0 || color(i) == 1
        c{i} = 'green';
    elseif color(i)==2 
        c{i} = [1 0.5 0]; %orange
    elseif color(i) == 4 || color(i) == 3
        c{i} = 'red';
    end
    
end

%HR vs SDNN
figure;
for i=1:length(color)
    plot(cell2mat(parametros_est(i+1,2)), cell2mat(parametros_est(i+1,3)), 'o', 'Color',c{i},'MarkerFaceColor',c{i});
    hold on;
end
yline(180);
yline(102);
xline(60);
xline(100);
title('Comparación HR y SDNN')
ylabel('SDNN')
xlabel('HR')

%HR vs RMSSD
figure;
for i=1:length(color)
    plot(cell2mat(parametros_est(i+1,2)), cell2mat(parametros_est(i+1,4)), 'o', 'Color',c{i},'MarkerFaceColor',c{i});
    hold on;
end
title('Comparación HR y RMSSD')
yline(39);
yline(15)
xline(60);
xline(100);
ylabel('RMSSD')
xlabel('HR')

%HR vs PNN50
figure;
for i=1:length(color)
    plot(cell2mat(parametros_est(i+1,2)), cell2mat(parametros_est(i+1,5)), 'o', 'Color',c{i},'MarkerFaceColor',c{i});
    hold on;
end
title('Comparación HR y PNN50')
yline(10);
xline(60);
xline(100);
ylabel('PNN50')
xlabel('HR')



%% representation of NOT statistic parameters
color2=cell2mat(parametros_no_est(2:(end),n_parametros_NO_est));

c2 = {};
for i = 1:length(color2)

    if color2(i)<= 5
        c2{i} = 'green';
    elseif color2(i)>5 && color2(i)<=10
        c2{i} = [1 0.5 0]; %orange
    elseif color2(i) > 10 
        c2{i} = 'red';
    end
    
end

figure; %complejo QRS
for i =2:length(color2)
    subplot(1,2,1)
    plot(cell2mat(parametros_no_est(i,2)), cell2mat(parametros_no_est(i,3)), 'o', 'Color',c2{i},'MarkerFaceColor',c2{i});
    hold on;
    yline(110); %valor estandar duración QRS
    xline(110);
    title('Duración del complejo QRS (ms)')
    xlabel('Media')
    ylabel('Desviación')
    
    subplot(1,2,2)
    plot(cell2mat(parametros_no_est(i,4)), cell2mat(parametros_no_est(i,5)), 'o', 'Color',c2{i},'MarkerFaceColor',c2{i});
    hold on;
    xline(2);%valor estandar amplitud QRS
    yline(2);
    title('Amplitud del complejo QRS (mV)')
    xlabel('Media')
    ylabel('Desviación')
end

%onda P
figure;
for i =2:length(color2)
    subplot(1,2,1)
    plot(cell2mat(parametros_no_est(i,6)), cell2mat(parametros_no_est(i,7)), 'o', 'Color',c2{i},'MarkerFaceColor',c2{i});
    hold on;
    yline(120); %valor estandar duración P
    xline(120);
    title('Duración de la onda P (ms)')
    xlabel('Media')
    ylabel('Desviación')
    
    subplot(1,2,2)
    plot(cell2mat(parametros_no_est(i,8)), cell2mat(parametros_no_est(i,9)), 'o', 'Color',c2{i},'MarkerFaceColor',c2{i});
    hold on;
    xline(0.25);%valor estandar amplitud onda P
    yline(0.25);
    title('Amplmitud de la onda P (mV)')
    xlabel('Media')
    ylabel('Desviación')
end
%intervao QT
figure;
for i =2:length(color2)
    plot(cell2mat(parametros_no_est(i,10)), cell2mat(parametros_no_est(i,11)), 'o', 'Color',c2{i},'MarkerFaceColor',c2{i});
    hold on;
    yline(440);%valor estandar duración intervalo QT
    xline(440);
    title('Duración del intervalo QT (ms)')
    xlabel('Media')
    ylabel('Desviación')
end

%{
%intervalo ST
figure;
for i =2:length(color2)
    plot(cell2mat(parametros_no_est(i,12)), cell2mat(parametros_no_est(i,13)), 'o', 'Color',c2{i},'MarkerFaceColor',c{i});
    hold on;
    yline(0.2)
    xline(0.2);
    title('Amplitud del intervalo ST (mV)')
    xlabel('Media')
    ylabel('Desviación')
end

%}

%onda T
figure;
for i =2:length(color2)
    plot(cell2mat(parametros_no_est(i,13)), cell2mat(parametros_no_est(i,14)), 'o', 'Color',c2{i},'MarkerFaceColor',c2{i});
    hold on;
    yline(0.5)
    xline(0.5);
    title('Amplitud del intervalo T (mV)')
    xlabel('Media')
    ylabel('Desviación')
    
end


