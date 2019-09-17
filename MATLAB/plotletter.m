fileExt = 'naa4';
filename =[fileExt, '.wav'];
[x,fs] = audioread(filename);

n = length(x);
min = 0;
max = n;

for idx = 1:n
    if abs(x(idx)) > 0.15
        min = idx;
        break;
    end
end
for idx = 1:n
    tempidx = n - idx;
    if abs(x(tempidx)) > 0.15
        max = tempidx;
        break;
    end
end
subplot(3,1,1); 
plot(x)

moan = x(min:max);
subplot(3,1,2); 
plot(moan)

tempx = [fileExt, 'x'];
data.(tempx) = moan;

t = 10*(0:1/fs:(length(moan)-1)/fs);


y = fft(moan);
temp = abs(y);
f = (0:length(y)-1)*44100/length(y);
subplot(3,1,3); 
plot(f(1:2000),temp(1:2000))

originalfilename = erase(filename, ".wav");
hgexport(gcf, sprintf(originalfilename), hgexport('factorystyle'), 'Format', 'png','Resolution',300);