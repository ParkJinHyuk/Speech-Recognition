clear;
clf;

name = 'jinhyuk';
word = 'train.ga1';

path = ['./data/', name, '/'];

[data, fs] = audioread([path, word, '.wav']);

fileExt = 'aaa';
filename = [fileExt, '.wav'];

[data, fs] = audioread(filename);

peakThreshold = 0.5;
peakDistance = 1 * fs;

[~, pks] = findpeaks(data, 'MinPeakHeight', peakThreshold, 'MinPeakDistance', peakDistance);

lInterval = 0.5 * fs;
tInterval = 1.5 * fs;

nPks = size(pks, 1);
extracted = zeros(nPks, tInterval);
for cnt = 1:nPks
    extracted(cnt, :) = data(pks(cnt) - lInterval + (1:tInterval));    
    
    subplot(nPks, 3, 3 * cnt - 2)
    plot(extracted(cnt, :))    
end


interval = ceil(0.1 * fs / 2);
overlap = ceil(interval / 3 * 2);

for cnt = 1:nPks
    sIdx = ['s', num2str(cnt)];
    
    spec.(sIdx) = (abs(spectrogram(extracted(cnt, :), interval, overlap, interval)));
    
    xTick = linspace(0, size(spec.(sIdx), 2) - 1, 5);
    xTickLabel = xTick * (interval - overlap);
    subplot(nPks, 3, 3 * cnt - 1)
    imagesc(spec.(sIdx))
    set(gca, 'YDir', 'normal')
    
    cMat.(sIdx) = corrcoef(spec.(sIdx));
    subplot(nPks, 3, 3 * cnt)
    imagesc(cMat.(sIdx))
    set(gca, 'XTick', xTick, 'XTickLabel', xTickLabel);
end