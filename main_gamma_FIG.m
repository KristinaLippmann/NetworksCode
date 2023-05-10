function main_gamma_FIG(info,data,results,path2save,nameOFfile)

MATversion=version;
if ((str2double(MATversion(end-5:end-2))-2013) + (~strcmp(MATversion(end-1),'a')))>0
    mat_ver='new';
else
    mat_ver='old';
end

%% the plotting part
totalTime_min=size(results.TAU,1)*info.binsize;
wavelet_Xaxis=totalTime_min/size(results.wavelet.MW,2):totalTime_min/size(results.wavelet.MW,2):totalTime_min;
wavelet_digits=fu_Digits(prctile(prctile(results.wavelet.MW,99,1),99,2));
power_digits=fu_Digits(max(max(results.RelGammaPower))); %MainFreqPower  
area_digits=fu_Digits(max(max(results.Area_at_HalfMax)));
%% preparing timeseries plots
figurehandle(length(info.phaselength)+1,1)=fig_Timeseries(wavelet_Xaxis, results.wavelet.HzBIN, results.wavelet.MW,... & wavelet
                        [1*info.binsize:info.binsize:totalTime_min], results.MainFreq, results.RelGammaPower, results.FullWidth_at_HalfMax,...
                        results.Area_at_HalfMax, results.TAU,...
                        totalTime_min, wavelet_digits,power_digits,area_digits); %results.MainFreqPower  GammaPower
clear totalTime_min wavlet_Xaxis wavelet_digits power_digits area_digits 
drawnow
%% preparing phase plots
% creating variables to facilitate plotting
morlet_1sec=floor(length(results.WaveletPhase1.MWtime)/(info.binsize*60));
LFP_1sec=1/size(data.raw2plot,2):1/size(data.raw2plot,2):1;
PSD_Xaxis=info.cutHzbin;
N_of_phases=length(info.phaselength);

%retrieve min and max for plotting
prePSD_max=squeeze(max(data.PowerPhase_cleanandsmooth,[],3));
prePSD_max(info.artefact_in_subphase)=0;
PSD_max=max(prePSD_max,[],2);
for i=1:N_of_phases
% wavelet only max is necessary
wavephase=['WaveletPhase' num2str(i)];
wavelet_max(i:i,1)=prctile(prctile(results.(wavephase).MW(:,(end+1)-morlet_1sec:end),99),99);
wavelet_digits(i:i,1)=fu_Digits(wavelet_max(i));

% PSD only max is necessary
PSD_digits(i:i,1)=fu_Digits(PSD_max(i));

% autocorrelation only min is necessary
autophase=['AutocorrPhase' num2str(i)];
autocorr_min(i:i,1)=min(min(results.(autophase).autocorr(:,:,2)));
end
clear wavephase autophase

LFP_maxmin(1)=max(max(data.raw2plot));
LFP_maxmin(2)=min(min(data.raw2plot));

for i=1:N_of_phases
    
%% definitions and variables for plotting
wavephase=['WaveletPhase' num2str(i)];
autophase=['AutocorrPhase' num2str(i)];

if N_of_phases==1
    % PSD
    PSD_max=max(PSD_max);
    allPSD2plot=data.PowerPhase_cleanandsmooth;
    nanmedianPSD2plot(1,:)=nanmedian(allPSD2plot,1);
    
    prePower_analysis(1,:)=ana_PSpec_analysis(info.cutHzbin,nanmedianPSD2plot(1,:),0);
    PSDarea_Xaxis(1)=prePower_analysis(6);
    PSDarea_Xaxis(2:1+length(info.cutHzbin(info.cutHzbin>=prePower_analysis(6) &...
        info.cutHzbin<=prePower_analysis(7))))=...
        info.cutHzbin(info.cutHzbin>=prePower_analysis(6) &...
        info.cutHzbin<=prePower_analysis(7));
    PSDarea_Xaxis(end+1:end+1)=prePower_analysis(7);
    
    PSDarea=[];
    % new y including cut borders
    PSDarea(1)=prePower_analysis(1)/2;
    PSDarea(2:length(PSDarea_Xaxis)-1)=nanmedianPSD2plot(info.cutHzbin>=prePower_analysis(6) & info.cutHzbin<=prePower_analysis(7));
    PSDarea(end+1:end+1)=prePower_analysis(1)/2;
    
    % TAU
    autocorrfit=[];
    peaks4fit=[];
    
    allAutocorr2plot(:,:)=results.(autophase).autocorr(:,:,2);
    nanmedianAutocorr2plot(:,:)=nanmedian(allAutocorr2plot,1);
    
    if sum(~isnan(results.(autophase).TAU))/length(results.(autophase).TAU)>0.66
        autocorrfit=nanmedian(results.(autophase).autocorr(~info.artefact_in_subphase(i,:),:,3),1);
        peaks4fit(:,1)=results.(autophase).autopeaks4fit(:,1)*1000;
        peaks4fit(:,2)=results.(autophase).autopeaks4fit(:,2);
    end
    
else %% important needs adjustment according to the stuff done before
    %% PSD stuff:
    allPSD2plot=[];
    allPSD2plot(:,:)=squeeze(data.PowerPhase_cleanandsmooth(i,~info.artefact_in_subphase(i,:),:));
    
    nanmedianPSD2plot=[];
    nanmedianPSD2plot(1,:)=nanmedian(data.PowerPhase_cleanandsmooth(i,~info.artefact_in_subphase(i,:),:),2);
    
    prePower_analysis=[];
    prePower_analysis(1,:)=ana_PSpec_analysis(info.cutHzbin,nanmedianPSD2plot(1,:),0);
        
    % new x including cut borders
    PSDarea_Xaxis=[];
    PSDarea_Xaxis(1)=prePower_analysis(6);
    PSDarea_Xaxis(2:1+length(info.cutHzbin(info.cutHzbin>=prePower_analysis(6) &...
        info.cutHzbin<=prePower_analysis(7))))=...
        info.cutHzbin(info.cutHzbin>=prePower_analysis(6) &...
        info.cutHzbin<=prePower_analysis(7));
    PSDarea_Xaxis(end+1:end+1)=prePower_analysis(7);
    
    % new y including cut borders
    PSDarea=[];
    PSDarea(1)=prePower_analysis(1)/2;
    PSDarea(2:length(PSDarea_Xaxis)-1)=nanmedianPSD2plot(info.cutHzbin>=prePower_analysis(6) & info.cutHzbin<=prePower_analysis(7));
    PSDarea(end+1:end+1)=prePower_analysis(1)/2;
    
    %% Autocorrelation stuff:
    autocorrfit=[];
    peaks4fit=[];
    
    allAutocorr2plot=[];
    allAutocorr2plot(:,:)=squeeze(results.(autophase).autocorr(~info.artefact_in_subphase(i,:),:,2));
    
    nanmedianAutocorr2plot=[];
    nanmedianAutocorr2plot(:,:)=nanmedian(results.(autophase).autocorr(~info.artefact_in_subphase(i,:),:,2),1);
    
    if sum(~isnan(results.(autophase).TAU))/length(results.(autophase).TAU)>0.66
        autocorrfit=nanmedian(results.(autophase).autocorr(~info.artefact_in_subphase(i,:),:,3),1);
        peaks4fit(:,1)=results.(autophase).autopeaks4fit(:,1)*1000;
        peaks4fit(:,2)=results.(autophase).autopeaks4fit(:,2);
    end
end

%% do the figure
figurehandle(i:i,1)=fig_Phases(results.(wavephase).MWtime(1:morlet_1sec,1),results.(wavephase).FR,squeeze(results.(wavephase).MW(info.pharmaphaselenght/info.binsize,:,(end+1)-morlet_1sec:end)),... % morlet
    LFP_1sec, data.raw2plot(i,:), data.lowpass2plot(i,:),... % LFP
    PSD_Xaxis, nanmedianPSD2plot,allPSD2plot,... % PSD
    PSDarea_Xaxis, PSDarea,... % PSD area
    squeeze(results.(autophase).autocorr(1,:,1))*1000, nanmedianAutocorr2plot, allAutocorr2plot, autocorrfit, peaks4fit,... % autocorrelation
    i, N_of_phases, nameOFfile,...
    wavelet_digits,LFP_maxmin,PSD_max,PSD_digits,autocorr_min);

drawnow
%saveas(figurehandle(i),[path2save filesep nameOFfile '_4corel' num2str(i) '.pdf'])
print(figurehandle(i), '-dpsc2', '-append', '-loose', [path2save filesep nameOFfile '_4corel' '.ps'])

end

print(figurehandle(end), '-dpsc2', '-append', '-loose', [path2save filesep nameOFfile '_4corel' '.ps'])
ghost_folder=[pwd filesep 'ghostscript4pdf'];
switch computer()
    case 'PCWIN'
        ghost_exe=[ghost_folder filesep 'win32\bin\gswin32c.exe'];
        helfu_multiPagePDF_win([path2save filesep nameOFfile '_4corel' '.ps'], [path2save filesep nameOFfile '.pdf'], ghost_exe);
    case 'PCWIN64'
        ghost_exe=[ghost_folder filesep 'win64\bin\gswin64c.exe'];
        helfu_multiPagePDF_win([path2save filesep nameOFfile '_4corel' '.ps'], [path2save filesep nameOFfile '.pdf'], ghost_exe);
    case 'GLNX86'
        ghost_exe=[ghost_folder filesep 'linux32/gs-924-linux-x86'];
        helfu_multiPagePDF_unix([path2save filesep nameOFfile '_4corel' '.ps'], [path2save filesep nameOFfile '.pdf'], ghost_exe);
%         multiPagePDF_unix_old([path2save filesep nameOFfile '_4corel' '.ps'], path2save, nameOFfile);
    case 'GLNXA64'
        ghost_exe=[ghost_folder filesep 'linux64/gs-924-linux-x86_64'];
        helfu_multiPagePDF_unix([path2save filesep nameOFfile '_4corel' '.ps'], [path2save filesep nameOFfile '.pdf'], ghost_exe);
%         multiPagePDF_unix_old([path2save filesep nameOFfile '_4corel' '.ps'], path2save, nameOFfile);
    case {'MACI', 'MACI64'}
        disp('go and buy a proper computer')
end

close all
waitfor(figurehandle(length(info.phaselength)+1))