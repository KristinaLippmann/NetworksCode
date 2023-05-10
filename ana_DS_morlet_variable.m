function [wavelet, wavelet_timeBIN, wavelet_HzBIN] = ana_DS_morlet_variable(data,sampling_rate,low,high,sensitivity)

% cut frequencies for morlet spectrum
%high=200;
%low=0.5

% at least twice the cut frequency
target_rate=2*high;

target_length=floor(length(data)/(sampling_rate/target_rate));

downsampledDATA=resample(data,target_length,length(data),1000);
clear data

[wavelet, wavelet_timeBIN, wavelet_HzBIN ]=fu_Morlet(downsampledDATA,target_rate,low,high,sensitivity);
end