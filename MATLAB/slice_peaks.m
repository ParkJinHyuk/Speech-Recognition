projectdir = '~/MATLAB/R2019a/bin/mh';
    dirinfo = dir(fullfile(projectdir, 'baa.wav'));
    numfils = length(dirinfo);
    
    for K = 1 : numfils
        filename = fullfile(projectdir, dirinfo(K).name);

        info = audioinfo(filename);
        [y,Fs] = audioread(filename);

        t = 0:seconds(1/Fs):seconds(info.Duration);
        t = t(1:end-1);
%         
%         subplot(numfils,1,K);
        
%         plot(t,y);

%         xlabel('Time');
%         ylabel('Audio Signal');

        [pks, locs] = findpeaks(y, 'MinPeakDistance', 1 * Fs, 'MinPeakHeight', 0.1);

        originfilename = erase(filename, ".wav");
        
        tmp = zeros(size(locs, 1), 2 * Fs);
        for cnt = 1:size(locs, 1)
            try
                tmp(cnt, :) = y(locs(cnt) + (-Fs + 1:Fs));    
            catch
                continue;
            end
            audiowrite(originfilename + "" + cnt + ".wav", tmp(cnt, :).', Fs);
        end
    end