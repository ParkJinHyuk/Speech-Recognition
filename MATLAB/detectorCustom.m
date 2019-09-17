fileExt = 'train.ga1';
filename = [fileExt, '.wav'];
[x, fs] = audioread(filename);

[beginf, endf] = setup_endpoints(x,fs, 20, 5, 7, 30);
plot(x);
hold on
stem(beginf, 1, 'r');
stem(endf, 1, 'r');
hold off

function [beginf, endf] = setup_endpoints(xin,fs,Lm,Rm,ethresh,zcthresh)
% analysis parameters; 
% Lmsec is analysis frame window duration in msec (40); L is analysis frame
% window duration in samples (computed from sampling rate)
% Rmsec is analysis frame window shift in msec (10); R is analysis frame
% window shift in samples (computed from sampling rate)
    L=round(Lm*fs/1000);
    R=round(Rm*fs/1000);
    
% compute log energy and zero crossings contours
    [loge,zc,nfrm]=analysis(xin,L,R,fs);
    
% compute endpoints
    [beginf,endf]=endpoints(nfrm,loge,zc,xin,fs,R,L,ethresh,zcthresh);
end

function [beginf,endf]=endpoints(nfrm,loge,zc,y,fs,R,L,ethresh,zcthresh)
%
% function to find endpoints of a speech utterance
%
% Inputs
%   nfrm: number of frames in log energy and zero crossings parameters
%   loge: log energy contour (1:nfrm)
%   zc: zero crossing rate contour (1:nfrm)
%   y: input speech (highpass filtered)
%   fs: sampling rate in Hz
%   R=frame shift in samples
%   L=frame duration in samples
%   ethresh=initial threshold on log energy contour
%   zcthresh=threshold on zero crossing rate contour
%
% Outputs
%   beginf: estimate of initial frame
%   endf: estimate of final frame

% clear peak1 and peak2 arrays
    clear peak1 peak2;

% normalize log energy contour so that peak is at 0 db
    logem=max(loge);
    loge(find(loge < logem - 60))=logem-60;
    logen=loge-logem;
    
% force first frame to be below threshold
    if (logen(1) > -ethresh-1) logen(1)=-ethresh-1;
    end
    
% force last frame to be below threshold
    if (logen(nfrm) > -ethresh-1) logen(nfrm)=-ethresh-1;
    end
    
% using threshold of 0 (dB) -thresh, find the strongest centroid and zero
% out the region for future checks
% peak1 is the lower peak, peak2 is the higher peak
    peak=find(logen == 0);
    peaklow=find(logen(1:peak(1)-1) < -ethresh);
    peak1(1)=peaklow(length(peaklow));
    peakhi=find(logen(peak(1)+1:nfrm) < -ethresh);
    peak2(1)=peakhi(1)+peak(1);
    
% zero out the energy pulse region
    logen(peak1(1):peak2(1))=-100;
    
% save regions in terms of peak1 and peak2
    isav=1;
    iend=0;
    
% iterate search for additional energy centroids
    while (iend == 0)
        logem=max(logen);
        if (logem < -ethresh) iend=1;
        else
            isav=isav+1;
            peak=find(logen == logem);
            peaklow=find(logen(1:peak(1)-1) < -ethresh);
            peak1(isav)=peaklow(length(peaklow));
            
            peakhi=find(logen(peak(1)+1:nfrm) < -ethresh);
            peak2(isav)=peakhi(1)+peak(1);
            
            if (peak2(isav)-peak1(isav) < 5)
                peak1(isav)=0;
                peak2(isav)=0;
                isav=isav-1;
                iend=1;
            else
                logen(peak1(isav):peak2(isav))=-100;
            end
        end
    end
    
% search for high zero crossings regions
    iend=0;
    isav1=isav;
    zcs=zc;
    while (iend == 0)
        zcm=max(zcs);
        peak=find(zcs == zcm);
        if (zcm < zcthresh || peak(1) < 5 || peak(1) > nfrm-5) 
            iend=1;
        else
            isav=isav+1;
            peaklow=find(zcs(1:peak(1)-1) < zcthresh);
            peak1(isav)=peaklow(length(peaklow));
            peakhi=find(zcs(peak(1)+1:nfrm) < zcthresh);
            peak2(isav)=peakhi(1)+peak(1);
            if (peak2(isav)-peak1(isav) < 5)
                peak1(isav)=0;
                peak2(isav)=0;
                isav=isav-1;
                iend=1;
            else
                zcs(peak1(isav):peak2(isav))=0;
            end
        end
    end
    
% determine final endpoints
    peak1s=sort(peak1(1:isav));
    peak2s=sort(peak2(1:isav));
    beginf=peak1s(1);
    endf=peak2s(isav);
    
    beginf=(beginf-1)*R+1;
    endf=(endf-1)*R+L-1;
end

function [energy,zerocrossings,nfrm]=analysis(xin,L,R,fs)
%
% function to compute log energy and zero crossing contours of speech file
%
% Inputs:
%   xin=input speech array
%   L=size of analysis frame in samples
%   R=size of analysis frame shift in samples
%   fs=speech signal sampling frequency in Hertz
%
% Outputs:
%   energy=log energy contour of full utterance
%   zerocrossings = normalized (per 10 msec) zero crossings contour for utterance
%   nfrm=number of frames in original utterance
% perform computation of short-time log energy and zero crossing rate
    nsamples=length(xin);
    ss=1;
    energy=[];
    zerocrossings=[];
    while (ss+L-1 <= nsamples)
        frame=xin(ss:ss+L-1).*hamming(L);
        energy=[energy 10*log10(sum(frame.^2))];
        zerocrossings=[zerocrossings sum(abs(diff(sign(frame))))];
        ss=ss+R;
    end
    nfrm=length(energy);
    zerocrossings=zerocrossings*fs/(200*L);
end