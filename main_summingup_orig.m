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
                
                if ii==1
                    to=max_phase(ii)/binsize_min;
                    from=1+(to-phaselenght_exp(i,ii)/binsize_min);
                else
                    from=1;
                    to=phaselenght_exp(i,ii)/binsize_min;
                end
                %% phases of experiments with overlaps are being aligned & summarised here
                freqphase=['Freq_ts' num2str(ii)];
                copypaste.timeseries.(freqphase)(1:max_phase(ii)/binsize_min,i)=NaN;
                copypaste.timeseries.(freqphase)(from:to,i)=currentfile.results.(freqphase);

                powerphase=['FreqPower_ts' num2str(ii)];
                copypaste.timeseries.(powerphase)(1:max_phase(ii)/binsize_min,i)=NaN;
                copypaste.timeseries.(powerphase)(from:to,i)=currentfile.results.(powerphase);

                freqareaphase=['FreqArea_ts' num2str(ii)];
                copypaste.timeseries.(freqareaphase)(1:max_phase(ii)/binsize_min,i)=NaN;
                copypaste.timeseries.(freqareaphase)(from:to,i)=currentfile.results.(freqareaphase);

                freqwidthphase=['FreqWidth_ts' num2str(ii)];
                copypaste.timeseries.(freqwidthphase)(1:max_phase(ii)/binsize_min,i)=NaN;
                copypaste.timeseries.(freqwidthphase)(from:to,i)=currentfile.results.(freqwidthphase);

%                 freqratiophase=['FreqSignal2Neighbour_ts' num2str(ii)];
%                 copypaste.timeseries.(freqratiophase)(1:max_phase(ii)/binsize_min,i)=NaN;
%                 copypaste.timeseries.(freqratiophase)(from:to,i)=currentfile.results.(freqratiophase);

                tauphase=['TAU_ts' num2str(ii)];
                copypaste.timeseries.(tauphase)(1:max_phase(ii)/binsize_min,i)=NaN;
                copypaste.timeseries.(tauphase)(from:to,i)=currentfile.results.(tauphase);

                
                %% phases of experiments are being summarised here
                autocorrphase=['AutocorrPhase' num2str(ii)];
                
                copypaste.all.MainFreq(i,length(currentfile.results.MainFreqPhase)*(ii-1)+1:length(currentfile.results.MainFreqPhase)*ii)=...
                    currentfile.results.MainFreqPhase(ii:length(currentfile.info.phaselength):end);
                
                copypaste.all.MainPower(i,length(currentfile.results.MainFreqPowerPhase)*(ii-1)+1:length(currentfile.results.MainFreqPowerPhase)*ii)=...
                    currentfile.results.MainFreqPowerPhase(ii:length(currentfile.info.phaselength):end);
                
                copypaste.all.MainArea(i,length(currentfile.results.Area_at_HalfMaxPhase)*(ii-1)+1:length(currentfile.results.Area_at_HalfMaxPhase)*ii)=...
                    currentfile.results.Area_at_HalfMaxPhase(ii:length(currentfile.info.phaselength):end);
                
                copypaste.all.MainFreqWidth(i,length(currentfile.results.FullWidth_at_HalfMaxPhase)*(ii-1)+1:length(currentfile.results.FullWidth_at_HalfMaxPhase)*ii)=...
                    currentfile.results.FullWidth_at_HalfMaxPhase(ii:length(currentfile.info.phaselength):end);
                
%                 copypaste.all.Signal2Neighbour(i,length(currentfile.results.Signal2NeighbourPhase)*(ii-1)+1:length(currentfile.results.Signal2NeighbourPhase)*ii)=...
%                     currentfile.results.Signal2NeighbourPhase(ii:length(currentfile.info.phaselength):end);
                
                copypaste.all.TAU(i,length(currentfile.results.(autocorrphase).TAU)*(ii-1)+1:length(currentfile.results.(autocorrphase).TAU)*ii)=...
                    currentfile.results.(autocorrphase).TAU;
                
                
                copypaste.median.MainFreq(i,ii)=...
                    nanmedian(currentfile.results.MainFreqPhase(ii:length(currentfile.info.phaselength):end));
                
                copypaste.median.MainPower(i,ii)=...
                    nanmedian(currentfile.results.MainFreqPowerPhase(ii:length(currentfile.info.phaselength):end));
                
                if sum(~isnan(currentfile.results.Area_at_HalfMaxPhase(ii:length(currentfile.info.phaselength):end)))/length(currentfile.results.Area_at_HalfMaxPhase(ii:length(currentfile.info.phaselength):end))>0.66
                copypaste.median.MainArea(i,ii)=...
                    nanmedian(currentfile.results.Area_at_HalfMaxPhase(ii:length(currentfile.info.phaselength):end));
                else
                copypaste.median.MainArea(i,ii)=NaN;
                end
                
                if sum(~isnan(currentfile.results.FullWidth_at_HalfMaxPhase(ii:length(currentfile.info.phaselength):end)))/length(currentfile.results.FullWidth_at_HalfMaxPhase(ii:length(currentfile.info.phaselength):end))>0.66
                copypaste.median.MainFreqWidth(i,ii)=...
                    nanmedian(currentfile.results.FullWidth_at_HalfMaxPhase(ii:length(currentfile.info.phaselength):end));
                else
                copypaste.median.MainFreqWidth(i,ii)=NaN;
                end

                if sum(~isnan(currentfile.results.(autocorrphase).TAU))/length(currentfile.results.(autocorrphase).TAU)>0.66
                copypaste.median.TAU(i,ii)=...
                    nanmedian(currentfile.results.(autocorrphase).TAU);
                else
                copypaste.median.TAU(i,ii)=NaN;
                end
                
%copypaste.median.Signal2Neighbour(i,ii)=...
%nanmedian(currentfile.results.Signal2NeighbourPhase(ii:length(currentfile.info.phaselength):end));

                clear freqphase powerphase freqareaphase freqwidthphase freqratiophase tauphase autocorrphase  from to
            end

            clear currentfile binsize_min
            
        end
        
        clear filename i ii max_phase
        %% done
end

clear pathname filterindex what2do phaselenght_exp
clc
