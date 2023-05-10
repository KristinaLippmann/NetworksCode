function [varargout] = helfu_dataconversion(what2do, data, samplingrate, freq_low, freq_high, freq_res, modDS_rate, extDS_rate)

% what2do = 1      -> FFT filter
% what2do = 2      -> moderate downsampling
% what2do = 3      -> FFT filter + moderate downsampling
% what2do = 4      -> wavelet transformation
% what2do = 5      -> FFT filter + wavelet transformation
% what2do = 6      -> moderate downsampling + wavelet transformation
% what2do = 7      -> FFT filter + moderate downsampling + wavelet transformation
% what2do = 8      -> downsample extreme
% what2do = 9      -> FFT filter + downsample extreme
% what2do = 10     -> moderate downsampling + downsample extreme
% what2do = 11     -> FFT filter + moderate downsampling + downsample extreme
% what2do = 12     -> wavelet transformation + downsample extreme
% what2do = 13     -> FFT filter + wavelet transformation + downsample extreme
% what2do = 14     -> moderate downsampling + wavelet transformation + downsample extreme
% what2do = 15     -> FFT filter + moderate downsampling + wavelet transformation + downsample extreme

switch what2do
    case 1  % FFT filter
        varargout{1}=fu_FFTbp(data, samplingrate, freq_low, freq_high, 8);
        
    case 2  % moderate downsampling
        if isempty(modDS_rate)
            modDS_rate=2*freq_high;
        end
        multifactor=(lcm(samplingrate,modDS_rate))/samplingrate;
        varargout{1}=resample(data, multifactor,(samplingrate/modDS_rate)*multifactor,10);
        varargout{2}=modDS_rate;
        
    case 3  % FFT filter + moderate downsampling
        data=fu_FFTbp(data, samplingrate, freq_low, freq_high, 8);
        
        if isempty(modDS_rate)
            modDS_rate=2*freq_high;
        end
        multifactor=(lcm(samplingrate,modDS_rate))/samplingrate;
        varargout{1}=resample(data, multifactor,(samplingrate/modDS_rate)*multifactor,10);
        varargout{2}=modDS_rate;
        
    case 4  % wavelet transformation
        [varargout{1}, varargout{2}, varargout{3}]=fu_Morlet(data,samplingrate,freq_low,freq_high,freq_res);
        
    case 5  % FFT filter + wavelet transformation
        data=fu_FFTbp(data, samplingrate, freq_low, freq_high, 8);
        
        [varargout{1}, varargout{2}, varargout{3}]=fu_Morlet(data,samplingrate,freq_low,freq_high,freq_res);
        
    case 6  % moderate downsampling + wavelet transformation
        if isempty(modDS_rate)
            modDS_rate=2*freq_high;
        end
        multifactor=(lcm(samplingrate,modDS_rate))/samplingrate;
        data=resample(data, multifactor,(samplingrate/modDS_rate)*multifactor,10);
        
        [varargout{1}, varargout{2}, varargout{3}]=fu_Morlet(data,modDS_rate,freq_low,freq_high,freq_res);

    case 7  % FFT filter + moderate downsampling + wavelet transformation
        data=fu_FFTbp(data, samplingrate, freq_low, freq_high, 8);
       
        if isempty(modDS_rate)
            modDS_rate=2*freq_high;
        end
        multifactor=(lcm(samplingrate,modDS_rate))/samplingrate;
        data=resample(data, multifactor,(samplingrate/modDS_rate)*multifactor,10);
        
        [varargout{1}, varargout{2}, varargout{3}]=fu_Morlet(data,modDS_rate,freq_low,freq_high,freq_res);
        
    case 8  % downsample extreme
        if isempty(extDS_rate)
            extDS_rate=samplingrate/20;
        end
        multifactor=(lcm(samplingrate,extDS_rate))/samplingrate;
        varargout{1}=resample(data, multifactor,(samplingrate/extDS_rate)*multifactor,1);
        varargout{2}=extDS_rate;
        
    case 9  % FFT filter + downsample extreme
        data=fu_FFTbp(data, samplingrate, freq_low, freq_high, 8);
        
        if isempty(extDS_rate)
            extDS_rate=samplingrate/20;
        end
        multifactor=(lcm(samplingrate,extDS_rate))/samplingrate;
        varargout{1}=resample(data, multifactor,(samplingrate/extDS_rate)*multifactor,1);
        varargout{2}=extDS_rate;
        
    case 10 % moderate downsampling + downsample extreme
        if isempty(modDS_rate)
            modDS_rate=2*freq_high;
        end
        multifactor=(lcm(samplingrate,modDS_rate))/samplingrate;
        data=resample(data, multifactor,(samplingrate/modDS_rate)*multifactor,10);
        
        if isempty(extDS_rate)
            extDS_rate=modDS_rate/20;
        end
        multifactor=(lcm(modDS_rate,extDS_rate))/modDS_rate;
        varargout{1}=resample(data, multifactor,(modDS_rate/extDS_rate)*multifactor,1);
        varargout{2}=extDS_rate;
        
    case 11 % FFT filter + moderate downsampling + downsample extreme
        data=fu_FFTbp(data, samplingrate, freq_low, freq_high, 8);
        
        if isempty(modDS_rate)
            modDS_rate=2*freq_high;
        end
        multifactor=(lcm(samplingrate,modDS_rate))/samplingrate;
        data=resample(data, multifactor,(samplingrate/modDS_rate)*multifactor,10);
        
        if isempty(extDS_rate)
            extDS_rate=modDS_rate/20;
        end
        multifactor=(lcm(modDS_rate,extDS_rate))/modDS_rate;
        varargout{1}=resample(data, multifactor,(modDS_rate/extDS_rate)*multifactor,1);
        varargout{2}=extDS_rate;
        
    case 12 % wavelet transformation + downsample extreme
        [varargout{1}, varargout{2}, varargout{3}]=fu_Morlet(data,samplingrate,freq_low,freq_high,freq_res);
        
        if isempty(extDS_rate)
            extDS_rate=samplingrate/20;
        end
        multifactor=(lcm(samplingrate,extDS_rate))/samplingrate;
        varargout{1}=(resample(varargout{1}', multifactor,(samplingrate/extDS_rate)*multifactor,1))';
        varargout{2}=resample(varargout{2}, multifactor,(samplingrate/extDS_rate)*multifactor,1);

    case 13 % FFT filter + wavelet transformation + downsample extreme
        data=fu_FFTbp(data, samplingrate, freq_low, freq_high, 8);
        
        [varargout{1}, varargout{2}, varargout{3}]=fu_Morlet(data,samplingrate,freq_low,freq_high,freq_res);
        
        if isempty(extDS_rate)
            extDS_rate=samplingrate/20;
        end
        multifactor=(lcm(samplingrate,extDS_rate))/samplingrate;
        varargout{1}=(resample(varargout{1}', multifactor,(samplingrate/extDS_rate)*multifactor,1))';
        varargout{2}=resample(varargout{2}, multifactor,(samplingrate/extDS_rate)*multifactor,1);
        
    case 14 % moderate downsampling + wavelet transformation + downsample extreme
        
        if isempty(modDS_rate)
            modDS_rate=2*freq_high;
        end
        multifactor=(lcm(samplingrate,modDS_rate))/samplingrate;
        data=resample(data, multifactor,(samplingrate/modDS_rate)*multifactor,10);
        
        [varargout{1}, varargout{2}, varargout{3}]=fu_Morlet(data,modDS_rate,freq_low,freq_high,freq_res);
        
        if isempty(extDS_rate)
            extDS_rate=modDS_rate/20;
        end
        multifactor=(lcm(modDS_rate,extDS_rate))/modDS_rate;
        varargout{1}=resample(varargout{1}', multifactor,(modDS_rate/extDS_rate)*multifactor,1);
        varargout{2}=resample(varargout{2}, multifactor,(modDS_rate/extDS_rate)*multifactor,1);
        
    case 15 % FFT filter + moderate downsampling + wavelet transformation + downsample extreme
        data=fu_FFTbp(data, samplingrate, freq_low, freq_high, 8);
        
        if isempty(modDS_rate)
            modDS_rate=2*freq_high;
        end
        multifactor=(lcm(samplingrate,modDS_rate))/samplingrate;
        data=resample(data, multifactor,(samplingrate/modDS_rate)*multifactor,10);
        
        [varargout{1}, varargout{2}, varargout{3}]=fu_Morlet(data,modDS_rate,freq_low,freq_high,freq_res);
        
        if isempty(extDS_rate)
            extDS_rate=modDS_rate/20;
        end
        multifactor=(lcm(modDS_rate,extDS_rate))/modDS_rate;
        varargout{1}=resample(varargout{1}', multifactor,(modDS_rate/extDS_rate)*multifactor,1);
        varargout{2}=resample(varargout{2}, multifactor,(modDS_rate/extDS_rate)*multifactor,1);
end