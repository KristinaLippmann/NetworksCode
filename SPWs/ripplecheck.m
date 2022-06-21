%------------------------------ripplecheck--------------------------------%
% according to the treshold level for ripple detection (ripplethresh) the %
% program evaluates the ripples "\/" of an event laying in the timewindow %

function [Amp, Freq, Ind]=ripplecheck(trace,samplingrate,ripplethresh)

% finding extrema [endpoints are not taken into account]
[helpmaxMag,helpmaxLoc,helpminMag,helpminLoc]=extremawithoutends(trace);


for ii=1:(length(helpmaxLoc)-1)

% lefthandsides of all the ripples -> \
preAmp(ii,1)=helpmaxMag(ii,1)-helpminMag(find(helpminLoc(:,1)>helpmaxLoc(ii,1),1)); %#ok<AGROW>

% righthandsides of all the ripples -> /
preAmp(ii,2)=helpmaxMag(ii+1,1)-helpminMag(find(helpminLoc(:,1)>helpmaxLoc(ii,1),1)); %#ok<AGROW>

% verifies that sides of ripples are at least 25% of each other
ampsidethresh(ii,1)=preAmp(ii,1)/preAmp(ii,2)>0.25 & preAmp(ii,2)/preAmp(ii,1)>0.25; %#ok<AGROW>

end

% verifies that amplitudes are higher than ripplethresh and
% both sides of a ripple are at least 25% of each other
threshcrossed(:,1)=sum(preAmp,2)/2>ripplethresh & ampsidethresh==1;

% amplitudes of all the ripples
allAmps=sum(preAmp,2)/2;

% amplitudes of ripples that matched criteria
%Amp= allAmps(threshcrossed==1);
Amp= allAmps(threshcrossed==1);
Ind= helpmaxLoc(threshcrossed==1); 

% indices of ripples minima
minima2take=helpminLoc(helpminLoc>helpmaxLoc(1) & helpminLoc < helpmaxLoc(end));

% preliminary table of frequencies
preFreq=samplingrate./diff(minima2take);

% some workaround for next step
threshcrossed2=double(threshcrossed);
threshcrossed2(threshcrossed2==0)=NaN;

% frequencies are stored only if subsequent pairs of ripples exist
Freq=preFreq((diff(threshcrossed2)==0),:);

end