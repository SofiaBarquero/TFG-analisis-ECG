function [noisy_ecg] = int_linea_base(x,ecg)
bw = 0.05*sin(2*pi*0.05*x); % Baseline wander signal
noisy_ecg = ecg + bw; % Add baseline wander to the clean ECG

% Plot the clean and noisy ECG signals
figure;
plot(x, ecg);
hold on;
plot(x, noisy_ecg);
legend('Clean ECG', 'Noisy ECG with Baseline Wander');
xlabel('Time (s)');
ylabel('Amplitude (mV)');


end

