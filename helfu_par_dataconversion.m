function [varargout] = helfu_par_dataconversion(what2do, data, sampling_rate, freq_low, freq_high, freq_res, modDS_rate, extDS_rate)

%% first detect poolsize
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    poolsize = 0;
else
    poolsize = p.NumWorkers;
end
clear p

if poolsize<8
poolsize=8;
end

%% reshaping data to optimally use the parpool and FFT
pre_chunklength=floor(size(data,1)/(poolsize+1));
optimized_chunklength=pow2(nextpow2(pre_chunklength)-1);
clear pre_chunklength poolsize

optimized_loops=ceil(size(data,1)/optimized_chunklength);
optimized_datachunks=floor(size(data,1)/optimized_loops);

optimized_overlap=optimized_chunklength-optimized_datachunks;

if optimized_overlap<2*sampling_rate
    optimized_loops=optimized_loops+1;
    optimized_datachunks=floor(size(data,1)/optimized_loops);
    optimized_overlap=optimized_chunklength-optimized_datachunks;
end

parpool_data=reshape(data(1:optimized_datachunks*optimized_loops,1),optimized_datachunks,optimized_loops);
lastchunk(:,1)=parpool_data(:,end);
parpool_data(1+optimized_datachunks:optimized_datachunks+optimized_overlap,1:optimized_loops-1)=parpool_data(1:optimized_overlap,2:optimized_loops);
parpool_data(:,end)=[];

%% adding data to last chunk if there is any to add
lastchunk(end:end-1+size(data((optimized_datachunks*optimized_loops):end,1)),1)=data((optimized_datachunks*optimized_loops):end,1);
clear optimized_datachunks


parfor i=1:optimized_loops-1
    % FFT filter the signal [BP(1) - BP(2) Hz]
    [helpM(:,i)] = helfu_dataconversion(what2do, parpool_data(:,i), sampling_rate, freq_low, freq_high, 2, [], []);
    %helpM(:,i)=fu_FFTbp(parpool_data(:,i),sampling_rate,BP1,BP2,8);
end
filt_lastchunk(:,1)=helfu_dataconversion(what2do, lastchunk, sampling_rate, freq_low, freq_high, 2, [], []);
clear lastchunk optimized_loops parpool_data i

%% reorganizing overlaps
till_cut=round(optimized_overlap/2);
from_cut=optimized_chunklength-(optimized_overlap-till_cut)+1;
firstchunk(:,1)=helpM(1:from_cut-1,1);
lastchunk(:,1)=filt_lastchunk(till_cut+1:end,1);
clear optimized_chunklength optimized_overlap filt_lastchunk

helpM(:,1)=[];
helpM(from_cut:end,:)=[];
helpM(1:till_cut,:)=[];
clear till_cut from_cut

%% rearrange data
middlechunk=reshape(helpM,size(helpM,1)*size(helpM,2),1);
clear helpM
varargout{1}=vertcat(firstchunk,middlechunk,lastchunk);
clear firstchunk middlechunk lastchunk

end