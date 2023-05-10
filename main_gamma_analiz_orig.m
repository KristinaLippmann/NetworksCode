%-------------------------------------------------------------------------%
%                                                                         %
%  The program is intended for parallel analysis of gamma-oscillations    %
%                                                                         %
%  rawdata: *.mat - file you created using spike2's export function       %
%  (alternatively use the function: ImportSMR_requested)                  %
%                                                                         %
%  timesOFint: provide times of washin of drugs or of interest            %
%                                                                         %
%  all_or_epochs: 'all' - analysis of full timeseries as well as epochs   %
%                 'epochs' - analysis of epochs only                      %
%                                                                         %
%  nameOFfile: alternative filename                                       %
%                                                                         %
%--------------------------------enjoy------------------------------------%

function [info, data, results]=main_gamma_analiz(rawdata, timesOFint, all_or_epochs, nameOFfile)

%% initializing

% creating filename using file+channel name
nameOFfile=[nameOFfile '_' 'Ch' rawdata.title];

% storing it inside the infofile
info.nameOFfile=nameOFfile;

% time stamp of experiment's start
info.experiment_started=rawdata.experiment_started;

% some cleaning
%clc
close all

% tic toc's are used for counting and displaying elapsed time
wholeanalysis=tic;

% retrieve matlab version to determine how to call the parallel pool
MATversion=version;

% until v.2013b 'matlabpool' was used afterwards parpool has to be called
% following code recruits parallel pool according to the matlab version running this code
if ((str2double(MATversion(end-5:end-2))-2013) + (~strcmp(MATversion(end-1),'a')))>0
    p = gcp('nocreate'); % check pool, do not create new one.
    if isempty(p)
        startpool=tic;
        parpool
        disp(['connecting: ' num2str((round(toc(startpool)*100))/100) ' s'])
        clear startpool
    end
    mat_ver='new';
    clear p
else
    try
    if matlabpool('size') == 0
        startpool=tic;
        matlabpool
        disp(['connecting: ' num2str((round(toc(startpool)*100))/100) ' s'])
        clear startpool
    end
    catch
        disp('parallel toolbox missing')
    end
        
    mat_ver='old';
end
clear MATversion

initialising=tic;
info.timesOFint(1)=0;

if isempty(who('timesOFint')) || isempty(timesOFint)
    % full length of datafile is used for analysis
    info.timesOFint(1+length(info.timesOFint))=floor(rawdata.length/round(1/rawdata.interval));
    all_or_epochs='all';
else
    % datafile will be analysed in epochs as well
    % timesOFint defines the end points in seconds of epochs
    info.timesOFint(2:length(timesOFint)+1)=floor(timesOFint);
    info.timesOFint(1+length(info.timesOFint))=floor(rawdata.length*rawdata.interval);
end

%% some definitions before anything is analysed

% time to plot [s]
time2plot=1;

% phase length [min] (for epochs)
info.pharmaphaselenght=5; %5 as default

if any(diff(info.timesOFint)/60<info.pharmaphaselenght)
    tooshort(1:length(info.timesOFint))=zeros;
    tooshort(2:length(info.timesOFint))=(diff(info.timesOFint)/60)<info.pharmaphaselenght;
    info.timesOFint(logical(tooshort))=[];
else
end

% bin size [min]
info.binsize=0.5;

% sliding overlap [s] (for continous data only)
info.overlap=15;

% size of the window to look for artefacts
window(1)=0;
window(2)=100;

% reading out samplingrate from inputfile
info.samplingrate=round(1/rawdata.interval);

% Welch's power spectral density estimate uses this parametre
% the higher the FFTsize the smaller the binwidth of the spectrum
% comment and uncomment the following according to your needs
% info.desiredFFTsize=16384;
  info.desiredFFTsize=8192;
% info.desiredFFTsize=4096;
% info.desiredFFTsize=2048;

% resulting binsize
info.Hzresolution=info.samplingrate/info.desiredFFTsize;

% HzBins
info.Hzbin=(1:1:info.desiredFFTsize/2)*info.Hzresolution;

% remove noise @ the given frequency used by:
% welch_50Hz_cleaning.m
noise=50;

% length of bin
binlength=floor(info.samplingrate*60*info.binsize);

% length of overlapping chunk of data
stickyend=floor(info.samplingrate*info.overlap);

% number of bins in total taking care that the last bin is fully represented
numberofbins=floor((rawdata.length-stickyend)/binlength);

% are there at least 5 minutes + stickyend available for analysis? If not,
% use last bin without stickyend
if numberofbins*binlength<info.pharmaphaselenght*60*info.samplingrate && numberofbins<floor(info.timesOFint(end)/(info.binsize*60))
    lastbin_cut=1;
else
    lastbin_cut=0;
end

% parfor can not handle variables within structures therefore: reorganization
samplingrate=info.samplingrate;
desiredFFTsize=info.desiredFFTsize;
Hzbin=info.Hzbin;
window2=window(2);
window1=window(1);
cutHzbin=Hzbin(:,Hzbin>window1 & Hzbin<window2);
info.cutHzbin=cutHzbin;

%% calculating binned data
if strcmp(all_or_epochs,'all')
    
    % more or less smart way of cutting the datafile into pieces without using for-loops
    cutrawdata=reshape(rawdata.values(1:binlength*(numberofbins+lastbin_cut),1),binlength,numberofbins+lastbin_cut);
    cutrawdata(1+binlength:binlength+stickyend,1:(numberofbins+lastbin_cut)-1)=cutrawdata(1:stickyend,2:(numberofbins+lastbin_cut));
    if lastbin_cut==1
        cutrawdata(1+binlength:binlength+stickyend,(numberofbins+lastbin_cut))=NaN;
    else
        cutrawdata(1+binlength:binlength+stickyend,(numberofbins+lastbin_cut))=rawdata.values(binlength*(numberofbins+lastbin_cut)+1:binlength*(numberofbins+lastbin_cut)+stickyend,1);
    end
    
    disp(['initialising done: ' num2str((round(toc(initialising)*100))/100) ' s'])
    clear initialising
    
    % test for artefacts that will be excluded from analysis at the very end
    raw2PrcTile_high=prctile(cutrawdata,99.999,1);
    raw2PrcTile_low=prctile(cutrawdata,0.001,1);
    prctilerange=raw2PrcTile_high-raw2PrcTile_low;
    prctilerange_cut=prctilerange(2:end-1);
    clear raw2PrcTile_high raw2PrcTile_low
    
    dramatic_changetestL2R=rdivide(prctilerange(1:end-2),prctilerange_cut)>2;
    dramatic_changetestR2L=rdivide(prctilerange(3:end),prctilerange_cut)>2;
    clear prctilerange prctilerange_cut
    
    artefact_in_BIN(1,1:size(cutrawdata,2))=zeros;
    artefact_in_BIN(1,1:size(cutrawdata,2)-2)=artefact_in_BIN(1,1:size(cutrawdata,2)-2)+dramatic_changetestL2R;
    artefact_in_BIN(1,3:size(cutrawdata,2))=artefact_in_BIN(1,3:size(cutrawdata,2))+dramatic_changetestR2L;
    artefact_in_BIN=logical(artefact_in_BIN);
    clear dramatic_changetestL2R dramatic_changetestR2L

    info.artefactBIN=artefact_in_BIN;

%% PowerSpectralDensity (Welch)
    % do not filter cut data!!!!!!!!!!!!!
    filter_and_power=tic;
    parfor i=1:numberofbins
        % bandpass filter the signal [5-200 Hz]
        helpM(i,:)=fu_FFTbp(cutrawdata(:,i),samplingrate,5,200,8);
        % comment from Kristina: default filter is 5-200 Hz...for gamma we use 0.5-100 Hz
        % helpM(i,:)=fu_FFTbp(cutrawdata(:,i),samplingrate,0.5,100,8);
    end
    clear cutrawdata
    
    parfor i=1:numberofbins
        % bandpass filtered signal is used for Welch's PowerSpectralDensity
        helpdata(i,:)=pwelch (helpM(i,:), desiredFFTsize, [], desiredFFTsize, samplingrate);
    end
    disp(['filtering and PowerSpectralDensity done: ' num2str((round(toc(filter_and_power)*100))/100) ' s'])
    clear filter_and_power
    
    % data from Welch's PSD is shortly saved here before being processed any further
    helpPowerData=helpdata(:,2:end);
    clear helpdata
    helpPowerData=helpPowerData(:,Hzbin>window1 & Hzbin<window2);
    
    parfor i=1:numberofbins
        [cleanPower(i,:),cleanandsmoothPower(i,:), bad_noise2signal(i)]=ana_PSpec_smooth(helpPowerData(i,:),cutHzbin,noise);
    end
    clear helpPowerData
    info.bad_noise2signal=bad_noise2signal;
    
    data.cleanPower=cleanPower;
    data.cleanandsmoothPower=cleanandsmoothPower;
    
    % circumvention for too long epochs of noise e.g. electrode out of slice 4 too long
    % in case we detected artefacts somewhere and they are separated by only
    % one bin which includes incredible noise we suppose that we have a
    % (very) long lasting artefact... - might need further testing
    
    bad_noise2signal_INDEX=find(bad_noise2signal==1);
    for i=bad_noise2signal_INDEX
        if artefact_in_BIN(i)==0 && artefact_in_BIN(i-1)==1 && artefact_in_BIN(i+1)==1
        artefact_in_BIN(i)=1;
        end
    end
    
    parfor i=1:numberofbins
        prePower_analysis(i,:)=ana_PSpec_analysis(cutHzbin,cleanandsmoothPower(i,:),artefact_in_BIN(i));
    end
    results.Power_analysis=prePower_analysis;
    clear cleanPower cleanandsmoothPower
    
    results.MainFreq(:,1)=results.Power_analysis(:,2);
    results.MainFreqPower(:,1)=results.Power_analysis(:,1);
    results.FullWidth_at_HalfMax(:,1)=results.Power_analysis(:,3);
    results.Area_at_HalfMax(:,1)=results.Power_analysis(:,4);
    results.Signal2Neighbour(:,1)=results.Power_analysis(:,5);
    
    %% autocorrelation
    autocorrtic=tic;
    
    parfor i=1:numberofbins
        % bandpass filtered data is sent to autocorr_and_fit function
        [tempTAU(i,1), ~ ,~]=ana_AutoCorrFit(helpM(i,:),samplingrate,artefact_in_BIN(i), bad_noise2signal(i), prePower_analysis(i,:), mat_ver);
    end
    % TAU being stored in the results structure
    results.TAU=tempTAU;
    clear tempTAU bad_noise2signal prePower_analysis
    
    disp(['autocorrelation done: ' num2str((round(toc(autocorrtic)*100))/100) ' s'])
    clear autocorrtic
    
    % trimming sticky ends for wavelet analysis
    prehelpdata=reshape(rawdata.values(1:binlength*(numberofbins+lastbin_cut),1),binlength,numberofbins+lastbin_cut);
    helpM=prehelpdata';
    clear prehelpdata
    
    %% downsampling and wavelet analysis
    disp('starting wavelet transformation')
    wavetic=tic;
    
    [first_wavelet, ~, wavelet_HzBIN] = ana_DS_morlet(helpM(1,:),samplingrate);
    wavelet_data(:,:,1)=first_wavelet;
    %tic
    parfor i=2:(numberofbins+lastbin_cut)
        wavelet_data(:,:,i)=ana_DS_morlet(helpM(i,:),samplingrate);
    end
    %toc
    clear helpM
    
    results.wavelet.MW=reshape(wavelet_data,size(first_wavelet,1),size(first_wavelet,2)*size(first_wavelet,3)*(numberofbins+lastbin_cut));
    clear wavelet_data first_wavelet
    % resampling the wavelet to reduce the amount of data
    helpMW=resample(results.wavelet.MW',1,20,1);
    results.wavelet.MW=helpMW';
    results.wavelet.HzBIN=wavelet_HzBIN;
    clear wavelet_HzBIN helpMW
    
    disp(['wavelet transformation done: ' num2str((round(toc(wavetic)*100))/100) ' s'])
    clear wavetic
    disp(['analysis of full time series done: ' num2str((round(toc(wholeanalysis)*100))/100) ' s'])
    
else % removing unnecessary info
    
    info=rmfield(info,{'overlap'});
    
end

%% calculating baseline, washin(s), washout
disp('starting to analyse phases of experiments')
phasetic=tic;

    % number of pharmacological relevant phases
    N_of_phases=length(info.timesOFint)-1;

    phaselength(1:N_of_phases)=zeros;
    
    % preallocating size of matrix
    data.PowerPhase_all(1:N_of_phases,1:(info.desiredFFTsize/2))=zeros;
    
    for i=1:N_of_phases
        
    wavephase{i:i,:}=['WaveletPhase' num2str(i)];
    autophase{i:i,:}=['AutocorrPhase' num2str(i)];
    
        % length of phases
        if info.timesOFint(1+i)-info.timesOFint(i)>info.pharmaphaselenght*60
            phaselength(i)=floor(info.samplingrate*60*info.pharmaphaselenght);
            
        elseif info.timesOFint(1+i)-info.timesOFint(i)>(info.pharmaphaselenght-2)*60
            phaselength(i)=floor(info.samplingrate*(info.timesOFint(1+i)-info.timesOFint(i)));
            
        elseif info.timesOFint(1+i)-info.timesOFint(i)>(info.pharmaphaselenght/2)*60
            phaselength(i)=floor(info.samplingrate*60*(info.pharmaphaselenght/2));
            
        else
            phaselength(i)=floor(info.samplingrate*(info.timesOFint(1+i)-info.timesOFint(i)));
        end

    prehelp(i:i,1:phaselength(i))=rawdata.values(floor((info.timesOFint(1+i)*info.samplingrate))-phaselength(i)+1:...
        floor(info.timesOFint(1+i)*info.samplingrate));
    
    baseline4crosscorr=fu_FFTlp(prehelp(i:i,:),samplingrate,1000/samplingrate,8);
    lowhelpM4crosscorr=fu_FFTlp(prehelp(i:i,:),samplingrate,200,8);
    data.lowpass4crosscorr(i:i,:)=lowhelpM4crosscorr-baseline4crosscorr;
    
    clear lowhelpM4crosscorr baseline4crosscorr
    end
    clear rawdata
    
disp(['initialising phase analysis done: ' num2str((round(toc(phasetic)*100))/100) ' s'])
filter_and_power=tic;

subphases=phaselength(1)/binlength;

% more or less smart way of cutting the datafile into pieces without using for-loops
cutmatprehelp=reshape(prehelp,N_of_phases,binlength,subphases);
clear prehelp

parfor k=1:subphases
    for i=1:N_of_phases
        subtractionfit(i,k,:)=fu_FFTlp(squeeze(cutmatprehelp(i,:,k)),samplingrate,1000/samplingrate,8);
        lowhelpM(i,k,:)=fu_FFTlp(squeeze(cutmatprehelp(i,:,k)),samplingrate,200,8);
    end
end

%% do the artefactdetection again
if size(cutmatprehelp,1)==1
    cutmatprehelp1(:,:)=cutmatprehelp;
    % test for artefacts that will be excluded from analysis at the very end
    raw2PrcTile_high=prctile(cutmatprehelp1,99.99,1);
    raw2PrcTile_low=prctile(cutmatprehelp1,0.01,1);
    prctilerange=raw2PrcTile_high-raw2PrcTile_low;
    prctilerange_cut=prctilerange(2:end-1);
    clear raw2PrcTile_high raw2PrcTile_low
    
    dramatic_changetestL2R=rdivide(prctilerange(1:end-2),prctilerange_cut)>1.5;
    dramatic_changetestR2L=rdivide(prctilerange(3:end),prctilerange_cut)>1.5;
    clear prctilerange prctilerange_cut
    
    artefact_in_subphase(1,1:size(cutmatprehelp1,2))=zeros;
    artefact_in_subphase(1,1:size(cutmatprehelp1,2)-2)=artefact_in_subphase(1,1:size(cutmatprehelp1,2)-2)+dramatic_changetestL2R;
    artefact_in_subphase(1,3:size(cutmatprehelp1,2))=artefact_in_subphase(1,3:size(cutmatprehelp1,2))+dramatic_changetestR2L;
    artefact_in_subphase=logical(artefact_in_subphase);
    clear dramatic_changetestL2R dramatic_changetestR2L cutmatprehelp1
    
    data4secplot(1,:)=cutmatprehelp(:,(end+1)-(time2plot*info.samplingrate):end,end);
    low4secplot(1,:)=lowhelpM(:,end,(end+1)-(time2plot*info.samplingrate):end);
    sub4secplot(1,:)=subtractionfit(:,end,(end+1)-(time2plot*info.samplingrate):end);
    clear subtractionfit lowhelpM
else
    % test for artefacts that will be excluded from analysis at the very end
    raw2PrcTile_high(:,:)=prctile(cutmatprehelp,99.99,2);
    raw2PrcTile_low(:,:)=prctile(cutmatprehelp,0.01,2);
    prctilerange=raw2PrcTile_high-raw2PrcTile_low;
    prctilerange_cut=prctilerange(:,2:end-1);
    clear raw2PrcTile_high raw2PrcTile_low
    
    dramatic_changetestL2R=rdivide(prctilerange(:,1:end-2),prctilerange_cut)>1.5;
    dramatic_changetestR2L=rdivide(prctilerange(:,3:end),prctilerange_cut)>1.5;
    clear prctilerange prctilerange_cut
    
    artefact_in_subphase(1:size(cutmatprehelp,1),1:size(cutmatprehelp,3))=zeros;
    artefact_in_subphase(:,1:size(cutmatprehelp,3)-2)=artefact_in_subphase(:,1:size(cutmatprehelp,3)-2)+dramatic_changetestL2R;
    artefact_in_subphase(:,3:size(cutmatprehelp,3))=artefact_in_subphase(:,3:size(cutmatprehelp,3))+dramatic_changetestR2L;
    artefact_in_subphase=logical(artefact_in_subphase);
    clear dramatic_changetestL2R dramatic_changetestL2R
    
    data4secplot(:,:)=cutmatprehelp(:,(end+1)-(time2plot*info.samplingrate):end,end);
    low4secplot(:,:)=lowhelpM(:,end,(end+1)-(time2plot*info.samplingrate):end);
    sub4secplot(:,:)=subtractionfit(:,end,(end+1)-(time2plot*info.samplingrate):end);
    clear subtractionfit lowhelpM
end

    info.artefact_in_subphase=artefact_in_subphase;
    clear rawMax rawMean rawMin rawSTD10  
    
    data.raw2plot=data4secplot-sub4secplot;
    data.lowpass2plot=low4secplot-sub4secplot;
    clear data4secplot low4secplot sub4secplot
    
parfor k=1:subphases
    for i=1:N_of_phases
        helpM(i,k,:)=fu_FFTbp(squeeze(cutmatprehelp(i,:,k))',samplingrate,5,200,8);
    end
end
clear cutmatprehelp
    
%% PowerSpectralDensity (Welch)

parfor k=1:subphases
    for i=1:N_of_phases
        tempPower(i,k,:) = pwelch (squeeze(helpM(i,k,:)), desiredFFTsize, [], desiredFFTsize, samplingrate);
    end
end

    tempPower=tempPower(:,:,2:end);
    PowerPhase2clean=tempPower(:,:,Hzbin>window1 & Hzbin<window2);
    clear tempPower
    data.PowerPhase_all=squeeze(PowerPhase2clean);
    
% cleaning the 50 Hz
parfor k=1:subphases
    for i=1:N_of_phases
       [PowerPhase_clean(i,k,:),PowerPhase_cleanandsmooth(i,k,:), bad_noise2signal(i,k)]=ana_PSpec_smooth(squeeze(PowerPhase2clean(i,k,:)),cutHzbin,noise);
    end
end
    clear PowerPhase2clean noise

    data.PowerPhase_cleanandsmooth=squeeze(PowerPhase_cleanandsmooth);

% Power Analysis
parfor k=1:subphases
    for i=1:N_of_phases
        PowerPhase_analysis(i,k,:)=ana_PSpec_analysis(cutHzbin,squeeze(PowerPhase_cleanandsmooth(i,k,:))',artefact_in_subphase(i,k));
    end
end
    results.PowerPhase_analysis=PowerPhase_analysis;
    data.PowerPhase_clean=squeeze(PowerPhase_clean);
    clear PowerPhase_clean PowerPhase_cleanandsmooth
    
    results.MainFreqPhase(:,:)=results.PowerPhase_analysis(:,:,2);
    results.MainFreqPowerPhase(:,:)=results.PowerPhase_analysis(:,:,1);
    results.FullWidth_at_HalfMaxPhase(:,:)=results.PowerPhase_analysis(:,:,3);
    results.Area_at_HalfMaxPhase(:,:)=results.PowerPhase_analysis(:,:,4);
    results.Signal2NeighbourPhase(:,:)=results.PowerPhase_analysis(:,:,5);
    
    results.PowerPhase_analysis=squeeze(results.PowerPhase_analysis);
    
disp(['filtering and PowerSpectralDensity done: ' num2str((round(toc(filter_and_power)*100))/100) ' s'])
clear filter_and_power

%% autocorrelation
autocorrtic=tic;
autopeaks4fit=cell(N_of_phases,subphases);
parfor k=1:subphases
    for i=1:N_of_phases
        [TAU(i,k), autocorr(i,k,:,:), autopeaks4fit{i,k}]=ana_AutoCorrFit(squeeze(helpM(i,k,:))',samplingrate,artefact_in_subphase(i,k), bad_noise2signal(i,k), PowerPhase_analysis(i,k,:), mat_ver);
    end
end

    for i=1:N_of_phases
        results.(autophase{i,1}).TAU(:,:)=TAU(i,:);
        results.(autophase{i,1}).autocorr(:,:,:)=autocorr(i,:,:,:);
        results.(autophase{i,1}).autopeaks4fit=vertcat(autopeaks4fit{i,:});
    end
    clear autophase TAU autocorr autopeaks4fit bad_noise2signal PowerPhase_analysis
    
disp(['autocorrelation done: ' num2str((round(toc(autocorrtic)*100))/100) ' s'])
clear autocorrtic

%% filter & downsample for wavelet analysis
disp('starting wavelet transformation')
wavetic=tic;

parfor k=1:subphases
    for i=1:N_of_phases
        [MW(i,k,:,:), MWtime(i,k,:), FR(i,k,:)]=ana_DS_morlet(squeeze(helpM(i,k,:)),samplingrate);
    end
end
    % if you want to do statistics on wavelets: do it within the for loop here
    for i=1:N_of_phases
        results.(wavephase{i,1}).MW(:,:,:)=MW(i,:,:,:);
        results.(wavephase{i,1}).MWtime(:,:)=MWtime(1,1,:);
        results.(wavephase{i,1}).FR(:,:)=FR(1,1,:);
    end
    clear wavephase MW MWtime FR helpM

disp(['wavelet transformation done: ' num2str((round(toc(wavetic)*100))/100) ' s'])
clear wavetic

if strcmp(all_or_epochs,'all')
%% aligning data 4 export

    if lastbin_cut==1
        data.cleanPower((numberofbins+lastbin_cut),:)=data.PowerPhase_clean((numberofbins+lastbin_cut),:);
        data.cleanandsmoothPower((numberofbins+lastbin_cut),:)=data.PowerPhase_cleanandsmooth((numberofbins+lastbin_cut),:);
        
        results.Power_analysis((numberofbins+lastbin_cut),:)=results.PowerPhase_analysis((numberofbins+lastbin_cut),:);
        results.MainFreq((numberofbins+lastbin_cut),1)=results.Power_analysis((numberofbins+lastbin_cut),2);
        results.MainFreqPower((numberofbins+lastbin_cut),1)=results.Power_analysis((numberofbins+lastbin_cut),1);
        results.FullWidth_at_HalfMax((numberofbins+lastbin_cut),1)=results.Power_analysis((numberofbins+lastbin_cut),3);
        results.Area_at_HalfMax((numberofbins+lastbin_cut),1)=results.Power_analysis((numberofbins+lastbin_cut),4);
        results.Signal2Neighbour((numberofbins+lastbin_cut),1)=results.Power_analysis((numberofbins+lastbin_cut),5);
        results.TAU((numberofbins+lastbin_cut),1)=results.AutocorrPhase1.TAU(:,(numberofbins+lastbin_cut));
    end

info.phaselength=floor(diff(info.timesOFint/60));
min2bin=floor(info.phaselength/info.binsize);

if sum(info.phaselength)>(numberofbins+lastbin_cut)*info.binsize
    info.phaselength(end)=info.phaselength(end)-info.binsize;
    min2bin=floor(info.phaselength/info.binsize);
else
end

TAUphasename=      'TAU_ts ';
Freqphasename=     'Freq_ts ';
FreqPowerphasename='FreqPower_ts ';
FreqWidthphasename='FreqWidth_ts ';
FreqAreaphasename= 'FreqArea_ts ';
FreqSignal2Neighbourname= 'FreqSignal2Neighbour_ts ';

for i=1:length(info.phaselength)
    TAUphasename(end:end)=num2str(i);
    Freqphasename(end:end)=num2str(i);
    FreqPowerphasename(end:end)=num2str(i);
    FreqWidthphasename(end:end)=num2str(i);
    FreqAreaphasename(end:end)=num2str(i);
    FreqSignal2Neighbourname(end:end)=num2str(i);
    
        results.(TAUphasename)=results.TAU(sum(min2bin(1:i-1))+1:sum(min2bin(1:i)),1);
        results.(Freqphasename)=results.MainFreq(sum(min2bin(1:i-1))+1:sum(min2bin(1:i)),1);
        results.(FreqPowerphasename)=results.MainFreqPower(sum(min2bin(1:i-1))+1:sum(min2bin(1:i)),1);
        results.(FreqAreaphasename)=results.Area_at_HalfMax(sum(min2bin(1:i-1))+1:sum(min2bin(1:i)),1);
        results.(FreqWidthphasename)=results.FullWidth_at_HalfMax(sum(min2bin(1:i-1))+1:sum(min2bin(1:i)),1);
        results.(FreqSignal2Neighbourname)=results.Signal2Neighbour(sum(min2bin(1:i-1))+1:sum(min2bin(1:i)),1);

%    end
end

clear TAUphasename Freqphasename FreqPowerphasename FreqWidthphasename FreqAreaphasename FreqSignal2Neighbourname i who2take



end
disp(['phase analysis done: ' num2str((round(toc(phasetic)*100))/100) ' s'])
clear phasetic
disp(['whole analysis done: ' num2str((round(toc(wholeanalysis)*100))/100) ' s'])
clear wholeanalysis