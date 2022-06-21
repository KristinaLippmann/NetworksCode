%% this script calculates data for the plots created in rippleMUAfindfig

%% ripple peak distance from swr trough (1)
rippleLoc_total = reshape(results.m_rippleLocs',[],1); 
ripplePeak2SWRpeak = rippleLoc_total(rippleLoc_total ~= 0);
ripplePeak2SWRpeak = ripplePeak2SWRpeak- pre_pts;
ripplePeak2SWRpeak = (ripplePeak2SWRpeak./info.samplingrate).*1000;
%converts it in ms

MyEdges = linspace(MyDefPar.ripplePeak2SWRpeak.sBin, ...
    MyDefPar.ripplePeak2SWRpeak.eBin, MyDefPar.ripplePeak2SWRpeak.nBin);
%define edges and # of bins for histogram
[N, edges] = histcounts(ripplePeak2SWRpeak,MyEdges);
%calculate ripple counts/time point relative to SWR peak
Nnorm = N/sum(N);  % Normalization
edges(end) = [];   % Cut end
results.h_r_ripplePeak2SWRpeak=N;
% Storage of # of ripples/time point
results.h_n_ripplePeak2SWRpeak=Nnorm;
% Storage of normalized # of ripples/time point
results.e_h_ripplePeak2SWRpeak=edges;
% Storage of edges of ripplePeak2SWRpeak

% Calculating the t Location-Scale distribution
pd = fitdist(ripplePeak2SWRpeak,'tLocationScale');
results.v_locfac_ripplePeak2SWRpeak = pd.mu;    %location factor of t Location fit
results.v_scale_ripplePeak2SWRpeak  = pd.sigma; %scale factor of t Location fit
results.v_kappa_ripplePeak2SWRpeak  = pd.nu;    %shape factor of t Location fit
%location factor describes mean of fit, shape factor describes skewness,
%scale factor how stretched or shrinked the distribution of the data is

%provides edges of tLoc fit
results.e_f_ripplePeak2SWRpeak = linspace(MyDefPar.ripplePeak2SWRpeak.sBin,...
    MyDefPar.ripplePeak2SWRpeak.eBin,MyDefPar.ripplePeak2SWRpeak.fBin);

%provides yfit data of tLoc pdf
results.h_f_ripplePeak2SWRpeak = pdf('tLocationScale',...
    results.e_f_ripplePeak2SWRpeak,results.v_locfac_ripplePeak2SWRpeak,...
    results.v_scale_ripplePeak2SWRpeak,results.v_kappa_ripplePeak2SWRpeak);

%scales the fit to the number of bins
results.e_s_ripplePeak2SWRpeak = (MyDefPar.ripplePeak2SWRpeak.eBin-...
    MyDefPar.ripplePeak2SWRpeak.sBin)./MyDefPar.ripplePeak2SWRpeak.nBin;

% stats of ripple peak to SWR peak
results.s_ripplePeak2SWRpeak(1:7)= My7StatsRowVec(ripplePeak2SWRpeak);

%save data in results for histogramming group analysis
results.m_ripplePeak2SWRpeak=ripplePeak2SWRpeak';

%% MUA peak distance from SWR trough (2)

MUALoc_total    = reshape(results.m_MUALocs',[],1);
MUAPeak2SWRpeak = MUALoc_total(MUALoc_total ~= 0);
MUAPeak2SWRpeak = MUAPeak2SWRpeak- pre_pts;
MUAPeak2SWRpeak = (MUAPeak2SWRpeak./info.samplingrate).*1000;
%converts it in ms

MyEdges = linspace(MyDefPar.MUAPeak2SWRpeak.sBin, ...
    MyDefPar.MUAPeak2SWRpeak.eBin, MyDefPar.MUAPeak2SWRpeak.nBin);
%define edges and # of bins for histogram
[N, edges] = histcounts(MUAPeak2SWRpeak,MyEdges);
%calculate MUA counts/time point relative to SWR peak
Nnorm = N/sum(N);  % Normalization
edges(end) = [];   % Cut end
results.h_r_MUAPeak2SWRpeak=N;
% Storage of # of MUAs/time point
results.h_n_MUAPeak2SWRpeak=Nnorm;
% Storage of normalized # of MUAs/time point
results.e_h_MUAPeak2SWRpeak=edges;
% Storage of edges of MUAPeak2SWRpeak

% Calculating the t Location-Scale distribution
pd = fitdist(MUAPeak2SWRpeak,'tLocationScale');
results.v_locfac_MUAPeak2SWRpeak = pd.mu;    %location factor of t Location fit
results.v_scale_MUAPeak2SWRpeak  = pd.sigma; %scale factor of t Location fit
results.v_kappa_MUAPeak2SWRpeak  = pd.nu;    %shape factor of t Location fit
%location factor describes mean of fit, shape factor describes skewness,
%scale factor how stretched or shrinked the distribution of the data is

%provides edges of tLoc fit
results.e_f_MUAPeak2SWRpeak = linspace(MyDefPar.MUAPeak2SWRpeak.sBin,...
    MyDefPar.MUAPeak2SWRpeak.eBin,MyDefPar.MUAPeak2SWRpeak.fBin);

%provides yfit data of tLoc pdf
results.h_f_MUAPeak2SWRpeak = pdf('tLocationScale',...
    results.e_f_MUAPeak2SWRpeak,results.v_locfac_MUAPeak2SWRpeak,...
    results.v_scale_MUAPeak2SWRpeak,results.v_kappa_MUAPeak2SWRpeak);

%scales the fit to the number of bins
results.e_s_MUAPeak2SWRpeak = (MyDefPar.MUAPeak2SWRpeak.eBin-...
    MyDefPar.MUAPeak2SWRpeak.sBin)./MyDefPar.MUAPeak2SWRpeak.nBin;

%stats of unit peak to SWR peak
results.s_MUAPeak2SWRpeak(1:7)= My7StatsRowVec(MUAPeak2SWRpeak);

%save data in results for histogramming group analysis                           <                                                                                    -
results.m_MUAPeak2SWRpeak=MUAPeak2SWRpeak';

%% how many ripples per SWRs (3 & 4)
% including SWRs without ripples (AllripplesPerAllsw) and only those with
% ripples (NzRipplesPerNzSW)
RipAboZero= results.m_rippleLocs>0;
AllripplesPerAllsw=(sum(RipAboZero,1))';
results.v_AllripplesPerAllsw = sum(AllripplesPerAllsw)/...
    length(AllripplesPerAllsw);

NzRipplesPerNzSW = nonzeros(AllripplesPerAllsw);
%calculates the # of ripples/SWR only for SWR where ripples exist
results.v_NzRipplesPerNzSW = ...
    sum(NzRipplesPerNzSW)/length(NzRipplesPerNzSW);

MyEdges = linspace(MyDefPar.AllripplesPerAllsw.sBin, ...
    MyDefPar.AllripplesPerAllsw.eBin, MyDefPar.AllripplesPerAllsw.nBin);

%define edges and # of bins for histogram for AllripplesPerAllsw
[N, edges] = histcounts(AllripplesPerAllsw,MyEdges);
%calculate ripple counts/SWR peak
Nnorm = N/sum(N);  % Normalization
edges(end)=[];
results.h_r_AllripplesPerAllsw=N;
% Storage of # of ripples/SWR
results.h_n_AllripplesPerAllsw=Nnorm;
% Storage of normalized # of ripples/SWR
results.e_h_AllripplesPerAllsw=edges;
% Storage of edges of AllripplesPerAllsw

% Calculating the gamma distribution for AllripplesPerAllsw
[phat] = gamfit(AllripplesPerAllsw);
results.v_kappa_AllripplesPerAllsw = phat(1); %shape factor of gamfit
results.v_scale_AllripplesPerAllsw = phat(2); %scale factor of gamfit
%shape factor describes skewness, scale factor how stretched or shrinked
%the distribution of the data is

%define edges and # of bins for histogram for NzRipplesPerNzSW
[N, edges] = histcounts(NzRipplesPerNzSW,MyEdges);
%calculate ripple counts/SWR peak
Nnorm = N/sum(N);  % Normalization
edges(end)=[];
results.h_r_NzRipplesPerNzSW=N;
% Storage of # of NonZero ripples/SWR
results.h_n_NzRipplesPerNzSW=Nnorm;
% Storage of normalized # of NonZero ripples/SWR
results.e_h_NzRipplesPerNzSW=edges;
% Storage of edges of NzRipplesPerNzSW

% Calculating the gamma distribution for NzRipplesPerNzSW
[phat] = gamfit(NzRipplesPerNzSW);
results.v_kappa_NzRipplesPerNzSW = phat(1); %shape factor of gamfit
results.v_scale_NzRipplesPerNzSW = phat(2); %scale factor of gamfit
%shape factor describes skewness, scale factor how stretched or shrinked
%the distribution of the data is

%provides edges of gamfit for AllripplesPerAllsw and NzRipplesPerNzSW
results.e_f_AllripplesPerAllsw = linspace(MyDefPar.AllripplesPerAllsw.sBin,...
    MyDefPar.AllripplesPerAllsw.eBin,MyDefPar.AllripplesPerAllsw.fBin);

%provides yfit data of gampdf for AllripplesPerAllsw
results.h_f_AllripplesPerAllsw = gampdf(results.e_f_AllripplesPerAllsw,...
    results.v_kappa_AllripplesPerAllsw,results.v_scale_AllripplesPerAllsw);

%provides yfit data of gampdf for NzRipplesPerNzSW
results.h_f_NzRipplesPerNzSW  = gampdf(results.e_f_AllripplesPerAllsw,...
    results.v_kappa_NzRipplesPerNzSW,results.v_scale_NzRipplesPerNzSW);

%scales the fit to the number of bins
results.e_s_AllripplesPerAllsw = (MyDefPar.AllripplesPerAllsw.eBin-...
    MyDefPar.AllripplesPerAllsw.sBin)./MyDefPar.AllripplesPerAllsw.nBin;

% stats of Ripples
results.s_AllripplesPerAllsw(1:7)= My7StatsRowVec(AllripplesPerAllsw);
results.s_NzRipplesPerNzSW(1:7)= My7StatsRowVec(NzRipplesPerNzSW);

%% how many units per SWRs (5 & 6)
% including SWRs without units (AllMUAPerAllsw) and only those with
% units (NzMUAPerNzSW)
MUAabZero= results.m_MUALocs>0;
AllMUAPerAllsw=(sum(MUAabZero,1))';
results.v_AllMUAPerAllsw = sum(AllMUAPerAllsw)/length(AllMUAPerAllsw);

NzMUAPerNzSW = nonzeros(AllMUAPerAllsw);
%calculates the # of Units/SWR only for SWR where Units exist
results.v_NzMUAPerNzSW = sum(NzMUAPerNzSW)/length(NzMUAPerNzSW);

MyEdges = linspace(MyDefPar.AllMUAPerAllsw.sBin, ...
    MyDefPar.AllMUAPerAllsw.eBin, MyDefPar.AllMUAPerAllsw.nBin);
%define edges and # of bins for histogram
[N, edges] = histcounts(AllMUAPerAllsw,MyEdges);
%calculate unit counts/SWR peak
Nnorm = N/sum(N);  % Normalization
edges(end)=[];
results.h_r_AllMUAPerAllsw=N;
% Storage of # of Units/SWR
results.h_n_AllMUAPerAllsw=Nnorm;
% Storage of normalized # of all Units/SWR
results.e_h_AllMUAPerAllsw=edges;
% Storage of edges of AllMUAPerAllsw

% Calculating the gamma distribution all units/SWRs
[phat] = gamfit(AllMUAPerAllsw);
results.v_kappa_AllMUAPerAllsw = phat(1); %shape factor of gamfit
results.v_scale_AllMUAPerAllsw = phat(2); %scale factor of gamfit
%shape factor describes skewness, scale factor how stretched or shrinked
%the distribution of the data is

%define edges and # of bins for histogram for NzMUAPerNzSW
[N, edges] = histcounts(NzMUAPerNzSW,MyEdges);
%calculate unit counts/SWR peak
Nnorm = N/sum(N);  % Normalization
edges(end)=[];
results.h_r_NzMUAPerNzSW=N;
% Storage of # of NonZero Units/SWR
results.h_n_NzMUAPerNzSW=Nnorm;
% Storage of normalized # of NonZero Units/SWR
results.e_h_NzMUAPerNzSW=edges;
% Storage of edges of NzMUAPerNzSW

% Calculating the gamma distribution for NzMUAPerNzSW
[phat] = gamfit(NzMUAPerNzSW);
results.v_kappa_NzMUAPerNzSW = phat(1); %shape factor of gamfit
results.v_scale_NzMUAPerNzSW = phat(2); %scale factor of gamfit
%shape factor describes skewness, scale factor how stretched or shrinked
%the distribution of the data is

%provides edges of gamfit for AllMUAPerAllsw and NzMUAPerNzSW
results.e_f_AllMUAPerAllsw = linspace(MyDefPar.AllMUAPerAllsw.sBin,...
    MyDefPar.AllMUAPerAllsw.eBin,MyDefPar.AllMUAPerAllsw.fBin);

%provides yfit data of gampdf for AllMUAPerAllsw
results.h_f_AllMUAPerAllsw = gampdf(results.e_f_AllMUAPerAllsw,...
    results.v_kappa_AllMUAPerAllsw,results.v_scale_AllMUAPerAllsw);

%provides yfit data of gampdf for NzMUAPerNzSW
results.h_f_NzMUAPerNzSW = gampdf(results.e_f_AllMUAPerAllsw,...
    results.v_kappa_NzMUAPerNzSW,results.v_scale_NzMUAPerNzSW);

%scales the fit to the number of bins
results.e_s_AllMUAPerAllsw = (MyDefPar.AllMUAPerAllsw.eBin-...
    MyDefPar.AllMUAPerAllsw.sBin)./MyDefPar.AllMUAPerAllsw.nBin;

% stats of MUAs
results.s_AllMUAPerAllsw(1:7) = My7StatsRowVec(AllMUAPerAllsw);
results.s_NzMUAPerNzSW(1:7)   = My7StatsRowVec(NzMUAPerNzSW);

%% SWR duration (5)

MyEdges = linspace(MyDefPar.SWRDuration.sBin, ...
    MyDefPar.SWRDuration.eBin, MyDefPar.SWRDuration.nBin);
%define edges and # of bins for histogram
[N, edges] = histcounts(results.m_Duration,MyEdges);
%calculate ripple counts/SWR peak
Nnorm = N/sum(N);  % Normalization
edges(end)=[];
results.h_r_SWRDuration=N;
% Storage of # of SWR duration
results.h_n_SWRDuration=Nnorm;
% Storage of normalized SWR duration
results.e_h_SWRDuration=edges;
% Storage of edges of SWR duration

% Calculating the t Location-Scale distribution
pd = fitdist(results.m_Duration','tLocationScale');
results.v_locfac_SWRDuration = pd.mu; %location factor of t Location fit
results.v_scale_SWRDuration  = pd.sigma; %scale factor of t Location fit
results.v_kappa_SWRDuration  = pd.nu;    %shape factor of t Location fit
%location factor describes mean of fit, shape factor describes skewness,
%scale factor how stretched or shrinked the distribution of the data is

%provides edges of tLoc fit
results.e_f_SWRDuration = linspace(MyDefPar.SWRDuration.sBin,...
    MyDefPar.SWRDuration.eBin,MyDefPar.SWRDuration.fBin);

%provides yfit data of tLoc pdf
results.h_f_SWRDuration = pdf('tLocationScale',results.e_f_SWRDuration,...
    results.v_locfac_SWRDuration,results.v_scale_SWRDuration,...
    results.v_kappa_SWRDuration);

%scales the fit to the number of bins
results.e_s_SWRDuration = (MyDefPar.SWRDuration.eBin-...
    MyDefPar.SWRDuration.sBin)./MyDefPar.SWRDuration.nBin;

% stats of SWR duration
results.s_SWRDuration(1:7) = My7StatsRowVec(results.m_Duration);

%extracts the fractions of SWR Durations longer than 75 ms
Long=find(results.e_h_SWRDuration>64,1);
Long=results.h_n_SWRDuration(Long:end);
results.v_FracSWRLongDur=sum(Long);

%% duration first to last ripple (6)
B=results.m_rippleLocs;
B(:,~any(B,1)) = []; %deletes the columns without ripples

% rip_dur=(0*B(1,:))';
for ii=1:size(B,2)
    C = B(:,ii);
    C = C(C~=0);
    RipDur(ii,:) = C(end)-C(1); %#ok<SAGROW>
end

RipDur = RipDur(RipDur~=0);
RippleDuration=(RipDur./info.samplingrate).*1000;
%converts it in ms.

MyEdges = linspace(MyDefPar.RippleDuration.sBin, ...
    MyDefPar.RippleDuration.eBin, MyDefPar.RippleDuration.nBin);
%define edges and # of bins for histogram
[N, edges] = histcounts(RippleDuration,MyEdges);
%calculate ripple counts/SWR peak
Nnorm = N/sum(N);  % Normalization
edges(end)=[];
%edges = edges(1:end-1)+ edges(2:end)./2; % shifts edges to middle of value
%but somehow adds 50% of duration to the scale, so I skipped it
results.h_r_RippleDuration=N;
% Storage of raw ripple duration
results.h_n_RippleDuration=Nnorm;
% Storage of normalized ripple duration
results.e_h_RippleDuration=edges;
% Storage of edges of ripple duration

% Fits the Lognormal distribution to the data
pd = fitdist(RippleDuration,'Lognormal');
results.v_logNmean_RippleDuration = pd.mu;  %mean of logarithmic values
results.v_logNSD_RippleDuration   = pd.sigma; %SD of logarithmic values

%provides edges of Lognormal fit
results.e_f_RippleDuration = linspace(MyDefPar.RippleDuration.sBin,...
    MyDefPar.RippleDuration.eBin,MyDefPar.RippleDuration.fBin);

%provides yfit data of lognormal pdf
results.h_f_RippleDuration = pdf('Lognormal',results.e_f_RippleDuration,...
    results.v_logNmean_RippleDuration,results.v_logNSD_RippleDuration);

%scales the fit to the number of bins
results.e_s_RippleDuration = (MyDefPar.RippleDuration.eBin-...
    MyDefPar.RippleDuration.sBin)./MyDefPar.RippleDuration.nBin;

% stats of duration first to last ripple/SWR
results.s_RippleDuration(1:7)= My7StatsRowVec(RippleDuration);

%extracts the fractions of RippleDurations longer than 100 ms
Long=find(results.e_h_RippleDuration>99,1);
Long=results.h_n_RippleDuration(Long:end);
results.v_FracRipLongDur=sum(Long);

%saves data in results for histogramming group analysis                          <                                                                                    -
results.m_RippleDuration=RippleDuration';  

%% duration first to last Unit (7)
B=results.m_MUALocs;
B(:,~any(B,1)) = []; %deletes the columns without Units

% rip_dur=(0*B(1,:))';
for ii=1:size(B,2)
    C = B(:,ii);
    C = C(C~=0);
    MUADur(ii,:) = C(end)-C(1); %#ok<SAGROW>
end

MUADur = MUADur(MUADur~=0);
MUADuration=(MUADur./info.samplingrate).*1000; %converts it in ms

MyEdges = linspace(MyDefPar.MUADuration.sBin, ...
    MyDefPar.MUADuration.eBin, MyDefPar.MUADuration.nBin);
%define edges and # of bins for histogram
[N, edges] = histcounts(MUADuration,MyEdges);
%calculate ripple counts/SWR peak
Nnorm = N/sum(N);  % Normalization
edges(end)=[];
%edges = edges(1:end-1)+ edges(2:end)./2; % shifts edges to middle of value
results.h_r_MUADuration=N;
% Storage of raw unit duration
results.h_n_MUADuration=Nnorm;
% Storage of normalized unit duration
results.e_h_MUADuration=edges;
% Storage of edges of unit duration

% Fits the Lognormal distribution to the data
pd = fitdist(MUADuration,'Lognormal');
results.v_logNmean_MUADuration = pd.mu;  %mean of logarithmic values
results.v_logNSD_MUADuration   = pd.sigma; %SD of logarithmic values

%provides edges of Lognormal fit
results.e_f_MUADuration = linspace(MyDefPar.MUADuration.sBin,...
    MyDefPar.MUADuration.eBin,MyDefPar.MUADuration.fBin);

%provides yfit data of lognormal pdf
results.h_f_MUADuration = pdf('Lognormal',results.e_f_MUADuration,...
    results.v_logNmean_MUADuration,results.v_logNSD_MUADuration);

%scales the fit to the number of bins
results.e_s_MUADuration = (MyDefPar.MUADuration.eBin-...
    MyDefPar.MUADuration.sBin)./MyDefPar.MUADuration.nBin;

% stats of duration first to last unit/SWR
results.s_MUADuration(1:7)= My7StatsRowVec(MUADuration);

%extracts the fractions of MUADurations longer than 100 ms
Long=find(results.e_h_MUADuration>99,1);
Long=results.h_n_MUADuration(Long:end);
results.v_FracMUALongDur=sum(Long);

%saves data in results for histogramming group analysis                          <                                                                                    -
results.m_MUADuration=MUADuration';       

%Done, EOF (end of file)