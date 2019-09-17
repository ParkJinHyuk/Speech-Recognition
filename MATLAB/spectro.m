fileExt = 'ga2';
maxFrequency = 2000;
filename = [fileExt, '.wav'];
[x, fs] = audioread(filename);

startTime = 0.2;
endTime = 0.6;

t = (startTime:1/fs:endTime);
subplot(3,1,1);
plot(t,x(fs*startTime:fs*endTime))
xlabel('Time (seconds)')
ylabel('Amplitude')

subplot(3,1,2);
s = spectrogram(x(fs*startTime:fs*endTime));
spectrogram(x, 'yaxis')

y = fft(x(fs*startTime:fs*endTime));
f = (0:length(y)-1)*fs/length(y);
subplot(3,1,3);
plot(f(1:maxFrequency), abs(y(1:maxFrequency)))
xlabel('Frequency')
ylabel('Magnitude')

data.(fileExt) = abs(y(1:maxFrequency));