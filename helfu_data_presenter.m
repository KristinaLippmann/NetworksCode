function helfu_data_presenter(rawdata, timesOFint, window_time, window_freq_from, window_freq_to, sensitivity, nameOFfile)

%% initialization

% creating filename using file+channel name
nameOFfile=[nameOFfile '_' 'Ch' rawdata.title];
[path2save, ~]=fileparts(rawdata.filename);

% cutting and printing of data
episode_window=str2num(window_time);
%episode_window=5;

% sampling rate
samplingrate=round(1/rawdata.interval);

% frequencies to be shown
freq_window(1,1)=str2num(window_freq_from);
freq_window(1,2)=str2num(window_freq_to);
%freq_window=[0.5 400];
sensitivity=str2num(sensitivity);

% indices to be used for cutting;
ind2cut(:,2)=floor(timesOFint*samplingrate);
ind2cut(:,1)=1+(ind2cut(:,2)-floor(episode_window*samplingrate));

% plot to control
% plot((ind2cut(1,1):1:ind2cut(1,2))/samplingrate,rawdata.values(ind2cut(1,1):ind2cut(1,2),1))

%% retrieve matlab version to determine how to call the parallel pool
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

%% downsampling and wavelet analysis
    disp('starting wavelet transformation')
    [filt_data, ~] = ana_par_FILT_DS(rawdata.values,samplingrate,[freq_window(1,1) 100],'no_down',[]);
    rawdata.values=filt_data;

    [first_wavelet, wavelet_timeBIN_epochs, wavelet_HzBIN_epochs] =...
                    ana_DS_morlet_variable(rawdata.values(ind2cut(1,1):ind2cut(1,2),1),samplingrate,freq_window(1),freq_window(2),sensitivity);
    % image(wavelet_timeBIN, wavelet_HzBIN, first_wavelet,'CDataMapping','scaled');
    % set(gca,'YDir','normal');
    wavelet_data_epochs(:,:,1)=first_wavelet;
    clear first_wavelet

    parfor i=2:length(timesOFint)
        wavelet_data_epochs(:,:,i)=...
                    ana_DS_morlet_variable(rawdata.values(ind2cut(i,1):ind2cut(i,2),1),samplingrate,freq_window(1),freq_window(2),sensitivity);
    end

    [filtdown_data, filtdown_sampling_rate] = ana_par_FILT_DS(rawdata.values,samplingrate,[freq_window(1,1) 2*freq_window(1,2)],'down',[]);
    
    [wavelet_whole, ~, wavelet_HzBIN_whole] = ana_par_morlet_variable(filtdown_data,filtdown_sampling_rate,sensitivity,freq_window(1),freq_window(2));

% [wavelet_whole, wavelet_timeBIN_whole, wavelet_HzBIN_whole] =...
%                     ana_DS_morlet_variable(rawdata.values,samplingrate,freq_window(1),freq_window(2));
%                 
wavelet_whole_resampled=resample(wavelet_whole',1,20,1);
%wavelet_timeBIN_whole_resampled=resample(wavelet_timeBIN_whole',1,20,10);

wavelet_timeBIN_whole_resampled=(1:size(wavelet_whole_resampled,1))/(filtdown_sampling_rate/20);

clear wavelet_timeBIN_whole wavelet_whole

%% start figure production
figurehandle=fig_representative(wavelet_timeBIN_whole_resampled/60, wavelet_HzBIN_whole, wavelet_whole_resampled',rawdata.values,... & wavelet
                         wavelet_timeBIN_epochs, wavelet_HzBIN_epochs, wavelet_data_epochs, timesOFint, ind2cut);
drawnow
print(figurehandle, '-dpsc2', '-append', '-loose', [path2save filesep nameOFfile '_4corel' '.ps'])
ghost_folder=[pwd filesep 'ghostscript4pdf'];
switch computer()
    case 'PCWIN'
        ghost_exe=[ghost_folder filesep 'win32\bin\gswin32c.exe'];
        helfu_multiPagePDF_win([path2save filesep nameOFfile '_4corel' '.ps'], [path2save filesep nameOFfile '.pdf'], ghost_exe);
    case 'PCWIN64'
        ghost_exe=[ghost_folder filesep 'win64\bin\gswin64c.exe'];
        helfu_multiPagePDF_win([path2save filesep nameOFfile '_4corel' '.ps'], [path2save filesep nameOFfile '.pdf'], ghost_exe);
    case 'GLNX86'
        ghost_exe=[ghost_folder filesep 'linux32/gs-921-linux-x86'];
        helfu_multiPagePDF_unix([path2save filesep nameOFfile '_4corel' '.ps'], [path2save filesep nameOFfile '.pdf'], ghost_exe);
%         multiPagePDF_unix_old([path2save filesep nameOFfile '_4corel' '.ps'], path2save, nameOFfile);
    case 'GLNXA64'
        ghost_exe=[ghost_folder filesep 'linux64/gs-921-linux-x86_64'];
        helfu_multiPagePDF_unix([path2save filesep nameOFfile '_4corel' '.ps'], [path2save filesep nameOFfile '.pdf'], ghost_exe);
%         multiPagePDF_unix_old([path2save filesep nameOFfile '_4corel' '.ps'], path2save, nameOFfile);
    case {'MACI', 'MACI64'}
        disp('go and buy a proper computer')
end

close all
waitfor(figurehandle)
