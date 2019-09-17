fileExt = 'gae';
maxFrequency = 2000;
filename = [fileExt, '.wav'];
[x, fs] = audioread(filename);

startTime = 0.2;
endTime = 0.6;

t = (startTime:1/fs:endTime);
subplot(2,1,1);
plot(t,x(fs*startTime:fs*endTime))
xlabel('Time (seconds)')
ylabel('Amplitude')

y = fft(x(fs*startTime:fs*endTime));
f = (0:length(y)-1)*fs/length(y);
subplot(2,1,2);
plot(f(1:maxFrequency), abs(y(1:maxFrequency)))
xlabel('Frequency')
ylabel('Magnitude')

gaedata.(fileExt) = abs(y(1:maxFrequency));