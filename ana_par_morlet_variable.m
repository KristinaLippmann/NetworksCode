function [wavelet_data, wavelet_timeBIN, wavelet_HzBIN] = ana_par_morlet_variable(input,sampling_rate,resolution,low,high)

%% first detect poolsize
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    poolsize = 0;
else
    poolsize = p.NumWorkers;
end
clear p

%% reshaping data to optimally use the parpool
chunklength=floor(size(input,1)/poolsize);
lastchunk=input(chunklength*poolsize+1:end,1);

input=reshape(input(1:chunklength*poolsize,1),chunklength,poolsize);
input=input';


% allocating 3D matrix for the wavelet
wavelet_data(1:length(low:resolution:high),1:chunklength,1:poolsize)=NaN;

parfor i=1:poolsize
    wavelet_data(:,:,i)=fu_Morlet(input(i,:),sampling_rate,low,high,resolution);
end

clear input

wavelet_data=reshape(wavelet_data,size(wavelet_data,1),size(wavelet_data,2)*size(wavelet_data,3));

% adding wavelet of last chunk if exists
if ~isempty(lastchunk)
    [last_wavelet, ~, wavelet_HzBIN] = fu_Morlet(lastchunk,sampling_rate,low,high,resolution);
    wavelet_data(:,size(wavelet_data,2)+1:size(wavelet_data,2)+size(last_wavelet,2))=last_wavelet;
else
    wavelet_HzBIN=low:resolution:high;
end

wavelet_timeBIN=(1:size(wavelet_data,2))/sampling_rate;

%% test plot
% Create image
% figure
% imagesc(wavelet_timeBIN, wavelet_HzBIN, wavelet_data,'CDataMapping','scaled');
% %caxis([0, prctile(prctile(wavelet_data,99,1),99,2)])
% set(gca,'YDir','normal')

end