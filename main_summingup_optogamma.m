[filename1, pathname, filterindex] = uigetfile( ...
    {  '*.mat','matlab-files (*.mat)'}, ...
    'Pick a file', ...
    'MultiSelect', 'on');

if ischar(filename1)
    filename{:}=filename1;
else
    filename=filename1;
end

clear filename1


switch filterindex
    
    case 0  % nothing selected
        clear, clc
        disp('nothing selected')
        
    otherwise,
        disp('performing requests')
        disp('all users are invited to think about any improvements now...!')
        
        %% loading data
        copypaste.analyzedfiles=filename';
        
        for i=1:length(filename)
        load(fullfile(pathname,filename{1,i}),'info');
        phaselenght_exp(i:i,1:length(info.phaselength))=info.phaselength;
        end
        %min_phase=min(phaselenght_exp);
        max_phase=max(phaselenght_exp);
        clear info
        
        for i=1:length(filename)
            
            currentfile=load(fullfile(pathname,filename{1,i}));
            binsize_min=currentfile.info.binsize;
            
            for ii=1:length(currentfile.info.phaselength)
                wavephase=['WaveletPhase' num2str(ii)];
                waveMEAN(ii,i,:)=mean(currentfile.results.(wavephase).MW,2);
%                 waveMEDIAN(ii,i,:)=median(currentfile.results.(wavephase).MW,2);
%                 wave95perctile(ii,i,:)=prctile(currentfile.results.(wavephase).MW,95,2);
            end
            
        end

                %% two normalizing options
                
                % 1°: norm to stim [max@5Hz]
%                 stimnorm_of_waveMEAN=waveMEAN./waveMEAN(:,:,9);
%                 stimnorm_of_waveMEDIAN=waveMEDIAN./waveMEDIAN(:,:,9);
%                 stimnorm_of_wave95perctile=wave95perctile./wave95perctile(:,:,9);
                
                % 2°: norm to max of baseline signal
                basenorm_of_waveMEAN=waveMEAN./max(waveMEAN(1,:,39:end),[],3);
%                 basenorm_of_waveMEDIAN=waveMEDIAN./max(waveMEDIAN(1,:,39:end),[],3);
%                 basenorm_of_wave95perctile=wave95perctile./max(wave95perctile(1,:,39:end),[],3);
                
                %% summary
                mean_of_waveMEAN(:,:)=mean(waveMEAN,2);
%                 mean_of_waveMEDIAN(:,:)=mean(waveMEDIAN,2);
%                 mean_of_wave95perctile(:,:)=mean(wave95perctile,2);                
                
%                 mean_stimnorm_of_waveMEAN(:,:)=mean(stimnorm_of_waveMEAN,2);
%                 mean_stimnorm_of_waveMEDIAN(:,:)=mean(stimnorm_of_waveMEDIAN,2);
%                 mean_stimnorm_of_wave95perctile(:,:)=mean(stimnorm_of_wave95perctile,2);
                
                mean_basenorm_of_waveMEAN(:,:)=mean(basenorm_of_waveMEAN,2);
%                 mean_basenorm_of_waveMEDIAN(:,:)=mean(basenorm_of_waveMEDIAN,2);
%                 mean_basenorm_of_wave95perctile(:,:)=mean(basenorm_of_wave95perctile,2);


                [preAmp,preInd]=max(waveMEAN(1,:,39:end),[],3);
                [postAmp,postInd]=max(waveMEAN(2,:,39:end),[],3);
                preFreq=currentfile.results.WaveletPhase1.FR(38+preInd);
                postFreq=currentfile.results.WaveletPhase1.FR(38+postInd);
                
                relAMPchange=postAmp./preAmp;
                relFREQchange=postFreq./preFreq;
end
                