close all;
clear;

hangul = ["gaa", "naa", "daa", "raa", "maa", "baa", "saa", "aaa", "jaa", "cha", "kaa", "taa", "faa", "haa"];
ygHangul = ["youngjae-ka", "youngjae-na", "youngjae-da", "youngjae-ra", "youngjae-ma", "youngjae-ba", "youngjae-sa", "youngjae-a", "youngjae-ja", "youngjae-cha", "youngjae-ca", "youngjae-ta", "youngjae-pa", "youngjae-ha"];
mhHangul = ["gaa", "naa", "daa", "raa", "maa", "baa", "saa", "aaa", "jaa", "cha", "kaa", "taa", "faa", "haa"];

for i = 1:14
    figure;
    count = 1;
    for j = 1:5 
        fileExt = char(mhHangul(i) + j);
        filename = [fileExt, '.wav'];
        try
            [x, fs] = audioread(filename);
        catch
            continue;
        end
        
        subplot(5,1,count);
        plot(x)
        xlabel('Time (seconds)')
        ylabel('Amplitude')
        title(fileExt);
        count = count+1;
    end
end
