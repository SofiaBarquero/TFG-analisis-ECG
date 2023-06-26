function [noisy_ecg] = powe_line_interference(x,ecg,fs)

% Add power line interference
pli = 100*sin(2*pi*50*x*fs); % Power line interference signal
noisy_ecg = ecg + pli; % Add power line interference to the clean ECG

% Plot the clean and noisy ECG signals
figure;
plot(x, ecg);
hold on;
plot(x, noisy_ecg);
legend('Clean ECG', 'Noisy ECG with Power Line Interference');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

end

