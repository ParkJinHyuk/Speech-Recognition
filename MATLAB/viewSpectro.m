close all;
clear;
 
accss = [];
 
for people = 1:1
    name = ["jh", "yj", "mh"];
    hangul = ["gaa", "naa", "daa", "raa", "maa", "baa", "saa", "aaa", "jaa", "cha", "kaa", "taa", "faa", "haa"];
    txtFile = ["jhData.txt", "yjData.txt", "mhData.txt"];
    path = ['./data/', char(name(people)), '/'];
    fileID = fopen([path, char(txtFile(people))], 'r');

    for i = 1:1
        for j = 1:5 
            fileExt = char(hangul(i) + j);
            filename = [fileExt, '.wav'];
      
            try
                [x, fs] = audioread([path, filename]);
            catch
                continue;
            end
            
            figure;
            spectrogram(x,256,128,256,'yaxis');
            
        end
    end
end


