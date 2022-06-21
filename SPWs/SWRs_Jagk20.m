%-------------------------------------------------------------------------%
%  this program is intended for analysis of SPW-R-complexes
%
%  As trace give the exported *.mat - file you created with spike2!
%  it should contain information about the interval and the values...
%  e.g.: [info, data, results]=SWRs_Jagk20(V120329_000_Ch1);
%
%  Version 3 of Kristina Lippmann and Jens Eilers modified Jan 15th 2021 at
%  Carl-Ludwig-Institute for Physiology, Medical Faculty, Uni Leipzig
%  based on Jan-Olliver Hollnagel´s, Anna Maslarova´s and
%  Gürsel Caliskan`s script - naming it "JagK"
%-------------------------------enjoy-------------------------------------%


function [info, data, results]=SWRs_Jagk20(trace,MyDefPar,MyDatPar)
%% Def_0: some definitions of parameters

% calculating the samplingrate [Hz] from *.mat-file
info.samplingrate = 1 / trace.interval;

% desired binsize_min, in [min] and [pts]
binsize_min = MyDefPar.Binsize_min;
binsize_pts = binsize_min * 60 * info.samplingrate;

% minimum interval in [pts] between events; new: changed from s to pts
death_pts = MyDefPar.Deathtime_s * info.samplingrate;

% timewindow in pts to look for ripples relative to max of LP-filt. signal
pre_pts   = round(info.samplingrate*MyDefPar.Timewin.Pre_ms /1000);
post_pts  = round(info.samplingrate*MyDefPar.Timewin.Post_ms/1000);

% number of bins
nofbins = ceil((trace.length*trace.interval)/(60*binsize_min));

% lower and upper limits for SPW duration
SPW_dur_lowerlimit_ms =   5;
SPW_dur_upperlimit_ms = 200;

% Counters for excluded SPWs, rows: 1=to early, 2=too late, 
% 3= not detected by cumsummax, 4=too short, 5=too long, 6=cut to long
% 7 too close after the final evaluation
Excluded_SPWs=zeros(1,6);

%% #######################################################################
% We start with SPW (omitting rippels and units)

%% SPW_0: DC removal from our data
% the median is removed from data.lowPass via low-pass filtering:
% butterlowpass(data,samplingrate,cutFrequency,order)

data.lowPass   = butterlowpass(trace.values*MyDefPar.updown,...
    info.samplingrate, MyDefPar.LP_butter.Flo,MyDefPar.LP_butter.Order);

% calculating offset
baselineOffset = median(data.lowPass);

% sustracting offset from data
data.lowPass   = data.lowPass-baselineOffset;

% release memory
clearvars baselineOffset


%% S2N_0: we prepare for calculating the mean amplitude of non-SPWs "noise"
% S2N will be the mean amplitude of SPWs divided by the mean of non-SPW noise.
% Using 'extremawithoutends' we get all (!) "events" in lp-filtered signal
% SPW events will be excluded in the section S2N_1
% The final calculation of S2N will be done in the section S2N_2
[xmax,imax,xmin,~] = extremawithoutends(data.lowPass);

% first calculation
xAmp = abs(xmax-xmin);

% release memory
clearvars xmax xmin

% boolean: events to be counted in S2N_2
what2take(1:length(imax))= true;


%% SPW_1: first estimate of start and end SPW
SPW_Cuts= []; % estimates of SPW end & start, will become a 2D vector

for ibin=1:nofbins
    % cut data from full trace into 'helpM',for indexing we create integers
    i0 = round(1+(ibin-1)*binsize_pts);
    i1 = round(   ibin   *binsize_pts);
    
    if ibin<nofbins
        helpM=data.lowPass(i0:i1);
    else    % the last one
        helpM=data.lowPass(i0:end);
    end
    
    % definition of level [mV] to be crossed by events:
    % mean of LP +/- 2.5 (default) times SD of LP
    bin_mean   = mean(helpM);
    bin_mSD    = std (helpM) * MyDatPar.MultSD;
    crosslevel = bin_mean + bin_mSD;
    info.crosslevel(ibin) = crosslevel; % store it in 'info'
    
    % all the data that lay above threshold, as indices into helpM
    whenevercrossed=(find(helpM>crosslevel));
    if isempty(whenevercrossed)     % no SWR detected
        disp(append(num2str(ibin), ' contains no SWRs'));
        continue
    end
    
    % just the data that match the deathtime criterion
    % the last point per SPW, as an index into 'whenevercrossed'
    deathtimecrossed=find(diff(whenevercrossed)>death_pts);
    if isempty(deathtimecrossed)    % no SWR with deathtime criterion detected
        disp(append(num2str(ibin), ...
            ' contains no SWRs meeting the deathtime criterion'));
        continue
    end
    
    % index2cut and SPW_Cuts:
    % info on each detected SPWs with rows, indices (1:3) are global:
    % 1=start , 2=end index, 3=index of peak
    % 4=MAGB,   5=bin_mean   (for MAGB)
    % 6=MAIB,   7=base2cross (for MAIB)
    index2cut=[];   % start from scratch
    index2cut(1:7,1:length(deathtimecrossed)+1)=NaN;
    % number of detected SPWs ('+1' because of the last SPW)
    
    % store start and end (global indices)
    % 1st pt of 1st SPW
    index2cut(1,1)       = whenevercrossed(1);  
    % 1st points of all other SWRs: last index of last SWR+1
    index2cut(1,2:end)   = whenevercrossed(deathtimecrossed+1);
    %  end of all but the last SWRs: last index of last SWR
    index2cut(2,1:end-1) = whenevercrossed(deathtimecrossed); 
    % end pt of last SPW
    index2cut(2,end)     = whenevercrossed(end); 
    
    % convert indices from being local to helpM to globals into data.lowpass
    index2cut(1:2,:) = index2cut(1:2,:) + i0;

    % store bin_mean for MAGB, will be the same per bin
    index2cut(5,:)   = bin_mean;
   
    % delete very first event(s) if the baseline is too short for pre_pts
    while index2cut(1,1) - pre_pts  < 1
        index2cut(:,1) =[];
        Excluded_SPWs(1)=Excluded_SPWs(1) + 1;
    end
    
    % delete very last event(s) if the baseline is too short to post_pts
    while index2cut(2,end) + post_pts > length(data.lowPass)
        index2cut(:,end)   =[];
        Excluded_SPWs(2)=Excluded_SPWs(2) + 1;
    end
 
    % store info of this bin
    SPW_Cuts = horzcat(SPW_Cuts,index2cut); %#ok<AGROW> 

end %end 'for ibin...'
% From now on, bins are not relevant anymode, SPW_cuts is about ALL SPWs
% release memory (helpM, i0 and i1 will be reused later)
clearvars deathtimecrossed crosslevel 
clearvars index2cut whenevercrossed bin_mean bin_mSD

%% SPW_2: refining start and stop of SPWs
% SPW_Cuts:
% 1=start , 2=end index, 3=index of peak
% 4=MAGB,   5=bin_mean   (for MAGB)
% 6=MAIB,   7=base2cross (for MAIB)

% Do some more checks!
% assure reasonably long SPWs: we want at least 3 data points!
for ii=length(SPW_Cuts):-1:1                    % all SPWs, reversed order
    if SPW_Cuts(1,ii)+2 >= SPW_Cuts(2,ii)       % less than 3 points
        SPW_Cuts(:,ii)  = [];                   % delete this entry
        Excluded_SPWs(4)=Excluded_SPWs(4) + 1;  % remember what was done
    end
end
% delete very last event(s) if the baseline is too short to post_pts
while round(SPW_Cuts(1,1) - death_pts)  < 1
    SPW_Cuts(:,1)   = [];                    % delete this entry
    Excluded_SPWs(1)= Excluded_SPWs(1) + 1;  % remember what was done
end
% delete very last event(s) if the baseline is too short to post_pts
while round(SPW_Cuts(2,end) + death_pts) > length(data.lowPass)
    SPW_Cuts(:,end) = [];                    % delete this entry
    Excluded_SPWs(2)= Excluded_SPWs(2) + 1;  % remember what was done
end

% refine start and stop
for ii=length(SPW_Cuts):-1:1    % all SPWs, reversed order
    % cut & save bandpass-filtered data
    i0 = round(SPW_Cuts(1,ii) - death_pts);  % start of cut
    i1 = round(SPW_Cuts(2,ii) + death_pts);  % end   of cut
 
    % cut the full SPW; it consists of death_pts+SPW+death_pts
    helpM = data.lowPass(i0:i1);

    % our expected baseline, the median of the pre and post death_pts
    base2cross = median(horzcat(helpM(1:death_pts),...
                                helpM(end-death_pts+1:end)));
    SPW_Cuts(7,ii) = base2cross;    % store the baseline

    % baseline crossings, search 3 pts into the SPW (we know it has 'em
    [~, Index0]=max(cumsum(       helpM(1:death_pts+3)       <base2cross));
    [~, Index1]=max(cumsum(flipud(helpM(end-death_pts-2:end))<base2cross));

    % Assure the data crossed the mean of the baseline twice
    if (Index0==1) || (Index1==1)  % no crossing(s)
        SPW_Cuts(:,ii) = [];       % delete this entry
        Excluded_SPWs(3)=Excluded_SPWs(3) + 1;
        continue
    end
    
    % adjust Index 1, which comes from the flipud'ed end of data
    Index1= length(helpM) - Index1;

    % store new start and stop indices (global)
    SPW_Cuts(1,ii) = i0 + Index0;
    SPW_Cuts(2,ii) = i0 + Index1;
end % for length(SPW_Cuts)
% release memory (helpM, i0 and i1 will be reused later)
clearvars Index0 Index1 base2cross

%% SPW_3: checking for SPWs being too short or too long:
% 1=start , 2=end index, 3=index of peak
% 4=MAGB,   5=bin_mean   (for MAGB)
% 6=MAIB,   7=base2cross (for MAIB)

for ii=length(SPW_Cuts):-1:1    % all SPWs in all bins, reverse order
    % too short
    width = SPW_Cuts(2,ii)-SPW_Cuts(1,ii);    % in pts
    width = width * 1000 / info.samplingrate; % in ms
    if width<SPW_dur_lowerlimit_ms
        SPW_Cuts(:,ii) = [];
        Excluded_SPWs(4)=Excluded_SPWs(4) + 1;
    elseif width>SPW_dur_upperlimit_ms
        SPW_Cuts(:,ii) = [];
        Excluded_SPWs(5)=Excluded_SPWs(5) + 1;
    end
end
% release memory
clearvars width

%% SPW_4: finding the maxima
% SPW_Cuts:
    % 1=start , 2=end index, 3=index of peak
    % 4=MAGB,   5=bin_mean   (for MAGB)
    % 6=MAIB,   7=base2cross (for MAIB)
for ii=1:length(SPW_Cuts)   % all SPWs in all bins
    % find the maximum and its index
    [helpMax, helpInd] = max(data.lowPass(SPW_Cuts(1,ii):SPW_Cuts(2,ii)));
    SPW_Cuts(3,ii)   = helpInd + SPW_Cuts(1,ii); %#ok<AGROW>
    SPW_Cuts(4,ii)   = helpMax - SPW_Cuts(5,ii); %#ok<AGROW>
    SPW_Cuts(6,ii)   = helpMax - SPW_Cuts(7,ii); %#ok<AGROW>
end
% release memory
clearvars helpMax helpInd

%% S2N_1: marking values belonging to 'SPWs+' as 'false' in what2take
% pre_pts and post_pts  are defined in line 29f
for ii=1:length(SPW_Cuts)  % all peak
    what2take((imax>(SPW_Cuts(3,ii)-pre_pts))&...
              (imax<(SPW_Cuts(3,ii)+post_pts)))    = false;
end

%% SPW_5: Final check for ultra rare problems
% for not-understood reasons, very very few SPWs have intervals
% shorter than the death time criterion
for ii=length(SPW_Cuts)-1:-1:1    % all but the last SPWs, reverse order
    my_pts = SPW_Cuts(3,ii+1) - SPW_Cuts(3,ii) ;
    if my_pts < death_pts
        SPW_Cuts(:,ii+1) = [];  % delete the second entry
        Excluded_SPWs(6)=Excluded_SPWs(6) + 1;
    end
end

%% SPW_6: Now we can save real data:
results.m_Duration      (1,:)=(SPW_Cuts(2,:)-SPW_Cuts(1,:))...
                                    *1000/info.samplingrate;
results.m_Amplitude_MAGB(1,:)=SPW_Cuts(4,:); % 'max. above glob. avg.'
results.m_Amplitude_MAIB(1,:)=SPW_Cuts(6,:); % 'max. above loc.  avg.'
results.m_maxtime       (1,:)=SPW_Cuts(3,:)/info.samplingrate; % in s

% instantaneous frequency for all but the first maximum
results.m_instFrequency(1)=NaN;
for ii=2:size(results.m_maxtime,2)
    results.m_instFrequency(ii)=...
        1/(results.m_maxtime(ii)-results.m_maxtime(ii-1));
end

% events per second
for ii=1:ceil(results.m_maxtime(end))
    results.m_EventsPerSecond(ii)=sum(ceil(results.m_maxtime)==ii);
end

% events per minute
for ii=1:floor(results.m_maxtime(end)/60)
    results.m_EventsPerMinute(ii)=...
        sum(results.m_EventsPerSecond((ii-1)*60+1:ii*60));
end

%% SPW_7: final data on SPWs
% amplitudes interpreted as maximum to minimum
for ii=1:length(SPW_Cuts)
    % cut & save bandpass-filtered data
    i1=SPW_Cuts(2,ii);
    
    [preAmphyper, ~]=findpeaks(data.lowPass(i1:i1+post_pts) * -1);
    if ~isempty(preAmphyper)
        results.m_Amplitude_Max2Min(:,ii)=...
            results.m_Amplitude_MAGB(:,ii)-(preAmphyper(1,1)*-1);
    else
        results.m_Amplitude_Max2Min(:,ii)=NaN;
    end
end
% release memory
clearvars preAmphyper

%% SPW_8: calculation of the area-under-the-curve using trapezoidal
% numerical integration regarding the samplingrate
for ii=1:length(SPW_Cuts)
    % cut & save bandpass-filtered data
    i0=SPW_Cuts(1,ii);
    i1=SPW_Cuts(2,ii);
    results.m_SWR_AUC(:,ii)=trapz(data.lowPass(i0:i1)-data.lowPass(i0))...
        *1000/info.samplingrate;
end


%% SPW_9: and we save a fixed-sized version of the SPW
% We save the SPW, we need the same size for all SPWs, so we rely on 
% pre_pts and post_pts around the peak of the SPW, see lines 29f
% we don't have to check for 'i0>=1' and 'i1<=end' again 
for ii=1:length(SPW_Cuts)
    data.singleslp(:,ii)=data.lowPass(SPW_Cuts(3,ii) - pre_pts:...
                                      SPW_Cuts(3,ii) + post_pts);
end

%% #######################################################################
% Now we turn to ripples and units
disp('Done with SPWs, now turning to ripples and units...')

%% BP_0: prepare by creating BD- and HP-filtered copies of the data
% butterband(data,samplingrate,1owerFrequency,upperFrequency,order)
bandPass=butterband(trace.values,info.samplingrate,...
    MyDefPar.BP_butter.Flo,MyDefPar.BP_butter.Fhi,...
    MyDefPar.BP_butter.Order);

% Multiunit activtiy
MUATrace = butterband(trace.values,info.samplingrate,...
    MyDefPar.MUA_butter.Flo,MyDefPar.MUA_butter.Fhi,...
    MyDefPar.MUA_butter.Order);
sqMUATrace = MUATrace.^2;

% threshold for the ripple detection, x times of SDs
% info.ripplethresh=3*std(bandPass);
ripplethresh= MyDatPar.MultRipplethresh*std(bandPass);
MUAthresh   = MyDatPar.MultMUAthres*std(MUATrace);

% creating variables
results.m_rippleAmplitudesalltogether   =[];
results.m_rippleFrequenciesalltogether  =[];
%results.m_rippleLocsalltogether        =[];
results.m_MUAAmplitudesalltogether      =[];
results.m_MUAFrequenciesalltogether     =[];

%% BP_1: cutting out and analysing events
for ii=1:length(SPW_Cuts)
    % cut & save bandpass-filtered data
    ThisPeak = SPW_Cuts(3,ii);
    i0 = ThisPeak-pre_pts;
    i1 = ThisPeak+post_pts;
    
    data.singlesbp   (:,ii) = bandPass    (i0:i1);
    data.singlesMUA  (:,ii) = MUATrace    (i0:i1);
    data.singlessqMUA(:,ii) = sqMUATrace  (i0:i1);
    data.singlesraw  (:,ii) = trace.values(i0:i1);
    
    % threshold for the ripple detection
    % ripplethresh=3*std(data.singlesbp(:,ii)); % currently 3 times SD of BP
    % MUAthresh   =6*std(data.singlesMUA(:,ii));% currently 6 times SD of BP
% JENS ?????? Threshold local or global, line 357f

    % calculation of rootmeansquare
    results.m_RMSsinglesbp(:,ii) = sqrt(mean(data.singlesbp(:,ii) .^2));
    results.m_RMSsinglesMUA(:,ii)= sqrt(mean(data.singlesMUA(:,ii).^2));
    
    % data are sent to "ripplecheck"-function see description
    [rippleAmp, rippleFreq, rippleInd]=ripplecheck(data.singlesbp(:,ii),...
        info.samplingrate,ripplethresh);
    [MUAAmp, MUAFreq, MUAInd]         =ripplecheck(data.singlesMUA(:,ii),...
        info.samplingrate,MUAthresh);
    
    % storing ripple Amplitude and -Frequency
    results.m_rippleAmplitudes(1:length(rippleAmp),ii)   =rippleAmp;
    results.m_rippleFrequencies(1:length(rippleFreq),ii) =rippleFreq;
    results.m_rippleLocs(1:length(rippleInd),ii)         =rippleInd;
    results.m_MUAAmplitudes(1:length(MUAAmp),ii)         =MUAAmp;
    results.m_MUAFrequencies(1:length(MUAFreq),ii)       =MUAFreq;
    results.m_MUALocs(1:length(MUAInd),ii)               =MUAInd;
    
    
    % putting all the ripple Amplitudes and -Frequencies inline
    results.m_rippleAmplitudesalltogether((1+...
        length(results.m_rippleAmplitudesalltogether)):...
        ((length(results.m_rippleAmplitudesalltogether))+...
        length(rippleAmp)),1)=rippleAmp;
    results.m_rippleFrequenciesalltogether((1+...
        length(results.m_rippleFrequenciesalltogether)):...
        ((length(results.m_rippleFrequenciesalltogether))+...
        length(rippleFreq)),1)=rippleFreq;
    results.m_MUAAmplitudesalltogether((1+...
        length(results.m_MUAAmplitudesalltogether)):...
        ((length(results.m_MUAAmplitudesalltogether))+...
        length(MUAAmp)),1)=MUAAmp;
    results.m_MUAFrequenciesalltogether((1+...
        length(results.m_MUAFrequenciesalltogether)):...
        ((length(results.m_MUAFrequenciesalltogether))+...
        length(MUAFreq)),1)=MUAFreq;
        
    %calculation of the integral of the squared MUA Trace:
 %   results.m_MUA_AUC(:,ii)=trapz(data.singlessqMUA(LPstartIndex(:,ii):LPstopIndex(:,ii),ii))*1000/info.samplingrate;
    results.m_MUA_AUC(:,ii)=trapz(sqMUATrace(SPW_Cuts(1,ii):SPW_Cuts(2,ii)))*1000/info.samplingrate;
end
clearvars rippleAmp rippleFreq rippleInd MUAAmp MUAFreq MUAInd
clearvars ripplethresh MUAthresh


%% S2N_2: calculating the signal2noise ratio but giving out only S2N
results.v_S2N(1)=mean(results.m_Amplitude_MAGB)/mean(xAmp(what2take));
clearvars what2take xAmp

%% BP_1: preliminary handling of data before collecting information
% -> replacing zeros by NaNs
results.m_rippleAmplitudes (results.m_rippleAmplitudes ==0) = NaN;
results.m_rippleFrequencies(results.m_rippleFrequencies==0) = NaN;
results.m_MUAAmplitudes    (results.m_MUAAmplitudes    ==0) = NaN;

% counting number of ripples per event
results.m_numberofripples = sum(~isnan(results.m_rippleAmplitudes),1);
results.m_numberofunits   = sum(~isnan(results.m_MUAAmplitudes),1);

%% statistics part -> mean, SD, and n
% We use the following notation for numeric data:
% v_ represents scalar (i.e., single) values
% s_ represents statistics (7 parameters)
% m_ represents a matrix
% h_ represents histogrammed data
% e_ represents the corresponding edges
% a_*_ represents an array of binned stats with * being either v,or s

% Amplitude: Max above global baseline
results.s_Amplitude_MAGB(1:7) = My7StatsRowVec(results.m_Amplitude_MAGB);

% Amplitude: Max above individual baseline
results.s_Amplitude_MAIB(1:7) = My7StatsRowVec(results.m_Amplitude_MAIB);

% Amplitude: Max minus Min
results.s_Amplitude_Max2Min(1:7)= My7StatsRowVec...
    (results.m_Amplitude_Max2Min);

% instantaneous Frequency
results.s_instFrequency(1:7)  = My7StatsRowVec(results.m_instFrequency);

% events per second
results.s_EventsPerSecond(1:7)= My7StatsRowVec(results.m_EventsPerSecond);

% events per minute
results.s_EventsPerMinute(1:7)= My7StatsRowVec(results.m_EventsPerMinute);

% number of ripples
results.v_RipplesperSWR=length(results.m_rippleAmplitudesalltogether)./length(results.m_maxtime);

% number of units
results.v_MUAperSWR=length(results.m_MUAAmplitudesalltogether)./length(results.m_maxtime);

% RMS of timewindow in which ripples are expected
results.s_RMSsinglesbp(1:7)= My7StatsRowVec(results.m_RMSsinglesbp);

% ripple Amplitudes
results.s_rippleAmplitudes(1:7)= My7StatsRowVec...
    (results.m_rippleAmplitudesalltogether.');

% ripple Frequencies
results.s_rippleFrequencies(1:7)= My7StatsRowVec...
    (results.m_rippleFrequenciesalltogether);

% area under the curve
results.s_SWR_AUC(1:7)= My7StatsRowVec(results.m_SWR_AUC);

% MUA sq Area under the curve
results.s_MUA_AUC(1:7) = My7StatsRowVec(results.m_MUA_AUC);

% SWR Duration
results.s_Duration(1:7)= My7StatsRowVec(results.m_Duration);

%% binned statistics
%
% resulting number of bins
% nofbins=floor((trace.interval*trace.length)/60/binsize_min);
% should be ceil()

% mapping events to bins
% binnedevents=ceil(ceil(results.m_maxtime/60)/binsize_min);
% this was the last active one:
% binnedevents=results.m_maxtime/(60*binsize_min);

for ii=1:nofbins
    %
    % %Amplitude: Max above global baseline
    % S=results.m_Amplitude_MAGB(:,binnedevents==ii);
    % results.a_s_Amplitude_MAGB(ii,1:7)= My7StatsColVec(S).';
    %
    % %
    % % results.a_s_Amplitude_MAGB(ii,1)=mean(results.m_Amplitude_MAGB  (:,binnedevents==ii));
    % % results.a_s_Amplitude_MAGB(ii,2)=std(results.m_Amplitude_MAGB   (:,binnedevents==ii));
    % % results.a_s_Amplitude_MAGB(ii,3)=length(results.m_Amplitude_MAGB(:,binnedevents==ii));
    % % results.a_s_Amplitude_MAGB(ii,4)=kstest(results.m_Amplitude_MAGB(:,binnedevents==ii));     %normal. test
    % % results.a_s_Amplitude_MAGB(ii,5)=median(results.m_Amplitude_MAGB(:,binnedevents==ii));     %median
    % % results.a_s_Amplitude_MAGB(ii,6)=prctile(results.m_Amplitude_MAGB(:,binnedevents==ii),25); %Q1
    % % results.a_s_Amplitude_MAGB(ii,7)=prctile(results.m_Amplitude_MAGB(:,binnedevents==ii),75); %Q3
    %
    % % Amplitude: Max above individual baseline
    % results.a_s_Amplitude_MAIB(ii,1)=mean(results.m_Amplitude_MAIB  (:,binnedevents==ii));
    % results.a_s_Amplitude_MAIB(ii,2)=std(results.m_Amplitude_MAIB   (:,binnedevents==ii));
    % results.a_s_Amplitude_MAIB(ii,3)=length(results.m_Amplitude_MAIB(:,binnedevents==ii));
    % results.a_s_Amplitude_MAIB(ii,4)=kstest(results.m_Amplitude_MAIB(:,binnedevents==ii));     %normal. test
    % results.a_s_Amplitude_MAIB(ii,5)=median(results.m_Amplitude_MAIB(:,binnedevents==ii));     %median
    % results.a_s_Amplitude_MAIB(ii,6)=prctile(results.m_Amplitude_MAIB(:,binnedevents==ii),25); %Q1
    % results.a_s_Amplitude_MAIB(ii,7)=prctile(results.m_Amplitude_MAIB(:,binnedevents==ii),75); %Q3
    %
    % % Amplitude: Max minus Min
    % helpM=results.m_Amplitude_Max2Min(:,binnedevents==ii);
    % results.a_s_Amplitude_Max2Min(ii,1)=mean  (helpM(~isnan(helpM)));
    % results.a_s_Amplitude_Max2Min(ii,2)=std   (helpM(~isnan(helpM)));
    % results.a_s_Amplitude_Max2Min(ii,3)=length(helpM(~isnan(helpM)));
    % results.a_s_Amplitude_Max2Min(ii,4)=kstest(helpM(~isnan(helpM)));      %normal. test
    % results.a_s_Amplitude_Max2Min(ii,5)=median(helpM(~isnan(helpM)));       %median
    % results.a_s_Amplitude_Max2Min(ii,6)=prctile((helpM(~isnan(helpM))),25); %Q1
    % results.a_s_Amplitude_Max2Min(ii,7)=prctile((helpM(~isnan(helpM))),75); %Q3
    %
    % % instantaneous Frequency
    % S=results.m_instFrequency(:,binnedevents==ii);
    % results.a_s_instFrequency(ii,1:7)= My7StatsColVec(S).';
    %
    % % results.a_s_instFrequency(ii,1)=mean   (results.m_instFrequency(:,binnedevents==ii));
    % % % binned event has one more point than results.m_instFrequency, so we crash
    % % results.a_s_instFrequency(ii,2)=std    (results.m_instFrequency(:,binnedevents==ii));
    % % results.a_s_instFrequency(ii,3)=length (results.m_instFrequency(:,binnedevents==ii));
    % % results.a_s_instFrequency(ii,4)=kstest (results.m_instFrequency(:,binnedevents==ii));    %normal. test
    % % results.a_s_instFrequency(ii,5)=median (results.m_instFrequency(:,binnedevents==ii));    %median
    % % results.a_s_instFrequency(ii,6)=prctile(results.m_instFrequency(:,binnedevents==ii),25); %Q1
    % % results.a_s_instFrequency(ii,7)=prctile(results.m_instFrequency(:,binnedevents==ii),75); %Q3
    %
    % % events per second
    % results.a_s_EventsPerSecond(ii,1)=mean(results.m_EventsPerSecond  (1,1+(ii-1)*60*binsize_min:ii*60*binsize_min));
    % results.a_s_EventsPerSecond(ii,2)=std(results.m_EventsPerSecond   (1,1+(ii-1)*60*binsize_min:ii*60*binsize_min));
    % results.a_s_EventsPerSecond(ii,3)=length(results.m_EventsPerSecond(1,1+(ii-1)*60*binsize_min:ii*60*binsize_min));
    % results.a_s_EventsPerSecond(ii,4)=kstest(results.m_EventsPerSecond(1,1+(ii-1)*60*binsize_min:ii*60*binsize_min));     %normal. test
    % results.a_s_EventsPerSecond(ii,5)=median(results.m_EventsPerSecond(1,1+(ii-1)*60*binsize_min:ii*60*binsize_min));     %median
    % results.a_s_EventsPerSecond(ii,6)=prctile(results.m_EventsPerSecond(1,1+(ii-1)*60*binsize_min:ii*60*binsize_min),25); %Q1
    % results.a_s_EventsPerSecond(ii,7)=prctile(results.m_EventsPerSecond(1,1+(ii-1)*60*binsize_min:ii*60*binsize_min),75); %Q3
    %
    % % % events per minute
    % % results.a_s_EventsPerMinute(ii,1)=mean  (results.m_EventsPerMinute(1,1+(ii-1)*binsize_min:ii*binsize_min));
    % % results.a_s_EventsPerMinute(ii,2)=std   (results.m_EventsPerMinute(1,1+(ii-1)*binsize_min:ii*binsize_min));
    % % results.a_s_EventsPerMinute(ii,3)=length(results.m_EventsPerMinute(1,1+(ii-1)*binsize_min:ii*binsize_min));
    %
    % % number of ripples
    % helpM=results.m_numberofripples(:,binnedevents==ii);
    % results.a_s_numberofripples(ii,1)=mean  (helpM(helpM~=0));
    % results.a_s_numberofripples(ii,2)=std   (helpM(helpM~=0));
    % results.a_s_numberofripples(ii,3)=length(helpM(helpM~=0));
    % results.a_s_numberofripples(ii,4)=kstest(helpM(helpM~=0));     %normal. test
    % results.a_s_numberofripples(ii,5)=median(helpM(helpM~=0));     %median
    % results.a_s_numberofripples(ii,6)=prctile(helpM(helpM~=0),25); %Q1
    % results.a_s_numberofripples(ii,7)=prctile(helpM(helpM~=0),75); %Q3
    %
    % % RMS of timewindow in which ripples are expected
    % results.a_s_RMSsinglesbp(ii,1)=mean  (results.m_RMSsinglesbp(:,binnedevents==ii));
    % results.a_s_RMSsinglesbp(ii,2)=std   (results.m_RMSsinglesbp(:,binnedevents==ii));
    % results.a_s_RMSsinglesbp(ii,3)=length(results.m_RMSsinglesbp(:,binnedevents==ii));
    % results.a_s_RMSsinglesbp(ii,4)=kstest(results.m_RMSsinglesbp(:,binnedevents==ii));     %normal. test
    % results.a_s_RMSsinglesbp(ii,5)=median(results.m_RMSsinglesbp(:,binnedevents==ii));     %median
    % results.a_s_RMSsinglesbp(ii,6)=prctile(results.m_RMSsinglesbp(:,binnedevents==ii),25); %Q1
    % results.a_s_RMSsinglesbp(ii,7)=prctile(results.m_RMSsinglesbp(:,binnedevents==ii),75); %Q3
    %
    % % ripple Amplitudes
    % helpM=results.m_rippleAmplitudes(:,binnedevents==ii);
    % results.a_s_rippleAmplitudes(ii,1)=mean  (helpM(~isnan(helpM)));
    % results.a_s_rippleAmplitudes(ii,2)=std   (helpM(~isnan(helpM)));
    % results.a_s_rippleAmplitudes(ii,3)=length(helpM(~isnan(helpM)));
    % results.a_s_rippleAmplitudes(ii,4)=kstest(helpM(~isnan(helpM)));       %normal. test
    % results.a_s_rippleAmplitudes(ii,5)=median(helpM(~isnan(helpM)));       %median
    % results.a_s_rippleAmplitudes(ii,6)=prctile((helpM(~isnan(helpM))),25); %Q1
    % results.a_s_rippleAmplitudes(ii,7)=prctile((helpM(~isnan(helpM))),75); %Q3
    %
    %
    % % ripple Frequencies
    %
    % helpM =results.m_rippleFrequencies(:,binnedevents==ii);
    % helpM = helpM(~isnan(helpM));
    % results.a_s_rippleFrequencies(ii,1:7)= My7StatsColVec(helpM).';
    %
    % % area under the curve
    % helpM=results.m_SWR_AUC(:,binnedevents==ii);
    % helpM = helpM(~isnan(helpM));
    %
    % results.a_s_SWR_AUC(ii,1)=mean  (helpM(~isnan(helpM)));
    % results.a_s_SWR_AUC(ii,2)=std   (helpM(~isnan(helpM)));
    % results.a_s_SWR_AUC(ii,3)=length(helpM(~isnan(helpM)));
    % results.a_s_SWR_AUC(ii,4)=kstest(helpM(~isnan(helpM)));       %normal. test
    % results.a_s_SWR_AUC(ii,5)=median(helpM(~isnan(helpM)));       %median
    % results.a_s_SWR_AUC(ii,6)=prctile((helpM(~isnan(helpM))),25); %Q1
    % results.a_s_SWR_AUC(ii,7)=prctile((helpM(~isnan(helpM))),75); %Q3
    %
    % % Duration
    % helpM=results.m_Duration(:,binnedevents==ii);
    % results.a_s_Duration(ii,1)=mean  (helpM(~isnan(helpM)));
    % results.a_s_Duration(ii,2)=std   (helpM(~isnan(helpM)));
    % results.a_s_Duration(ii,3)=length(helpM(~isnan(helpM)));
    % results.a_s_Duration(ii,4)=kstest(helpM(~isnan(helpM)));       %normal. test
    % results.a_s_Duration(ii,5)=median(helpM(~isnan(helpM)));       %median
    % results.a_s_Duration(ii,6)=prctile((helpM(~isnan(helpM))),25); %Q1
    % results.a_s_Duration(ii,7)=prctile((helpM(~isnan(helpM))),75); %Q3
    
end
%% Ripples/SWRs and MUAs/SWRs, location relativ to peak, duration
rippleMUAfindcalc; % external calculations

%% Provide some feedback
disp('SPW parameters:')
fprintf('     pre: %g ms, post: %g ms\n', ...
    MyDefPar.Timewin.Pre_ms,MyDefPar.Timewin.Post_ms);
fprintf('     death time: %g ms\n',MyDefPar.Deathtime_s*1000);
[k,ii]=min(results.m_Duration);
    fprintf('     shortest: %g ms at: %g\n',k,ii);
[k,ii]=max(results.m_Duration);
    fprintf('     longest: %g ms at: %g\n',k,ii);

% some feedback
disp('SPW detection:')
fprintf('     we have : %g SPWs\n', length(SPW_Cuts));
fprintf('     excluded: %g (too early), %g (too late)\n',...
    Excluded_SPWs(1),Excluded_SPWs(2));
fprintf('     excluded: %g (not detected by baseline crossing)\n',...
    Excluded_SPWs(3));
fprintf('     excluded: %g (too short, limit %g ms)\n',...
    Excluded_SPWs(4),SPW_dur_lowerlimit_ms);
fprintf('     excluded: %g (too long, limit, %g ms)\n',...
    Excluded_SPWs(5),SPW_dur_upperlimit_ms);
fprintf('     excluded: %g (for ultra-short inst. freq.)\n',...
    Excluded_SPWs(6));
[k,ii]=min(results.m_instFrequency);
fprintf('     Lowest inst. frequency: %g Hz at %g\n',k,ii);
[k,ii]=max(results.m_instFrequency);
fprintf('     Highest inst. frequency: %g Hz at %g\n',k,ii);


%% Plotting
%figure 1
figure, hold on;
plot(data.lowPass);
scatter(SPW_Cuts(3,:),results.m_Amplitude_MAGB);
hold off;

Tt = (1:size(data.singleslp,1))/info.samplingrate;
Tt = Tt - MyDefPar.Timewin.Pre_ms/1000;


ii=1;
while ii>0
    figure
    %subplot 1: raw and lp
    subplot(311)
    hold on
    title(strcat("SPW at ",num2str(SPW_Cuts(3,ii)/info.samplingrate)))
        plot(Tt,data.singlesraw(:,ii),'k');
        plot(Tt,data.singleslp(:,ii)*MyDefPar.updown,'r');
        yline(0)
        xline(0)
    hold off
    %     grid on
    legend('raw','low (80 Hz)')
    xlabel('time (s)')
    
    %     %subplot2: ripples
    subplot(312)
    hold on
    plot(Tt,data.singlesbp(:,ii),'k');
    yline(0)
    xline(0)
    % insert the detected ripples
    if any(results.m_rippleLocs(:,ii))
        scatter((results.m_rippleLocs(:,ii)-pre_pts)/info.samplingrate,results.m_rippleAmplitudes(:,ii),...
            'r','filled','SizeData',15);
     end
    hold off
    %     grid on
    legend('band 150-300 Hz')
    xlabel('time (s)')
    %
    %
    %     %subplot3: units
    %     %make the legend automatic for the bandpass
    subplot(313)
    hold on
    plot(Tt,data.singlesMUA(:,ii),'k')
    yline(0)
    xline(0)
    %     %insert points for the detected units
    if any(results.m_MUALocs(:,ii))
        scatter((results.m_MUALocs(:,ii)-pre_pts)/...
            info.samplingrate,results.m_MUAAmplitudes(:,ii),...
            'r','filled','SizeData',15);    
    end
    hold off
    %    grid on
    legend('band 600-3000 Hz')
    xlabel('time (s)')

    % Ask for next
    k = input(strcat(num2str(ii)," Next (0=escape): "));
    if ~isempty(k)
        ii=k-1;             % '-1' because we increase by 1 later
    end
    if ii <= 0
        break               % user break
    end
    if ii >= length(results.m_maxtime)
        beep;
        ii=0;
    end
    ii=round(ii+1);
end

end
