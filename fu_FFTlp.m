function L=fu_FFTlp(X,sampling_rate,flo,order)
if size(X,1)>size(X,2)
X=X';
end
nsample=length(X);
period = nsample/sampling_rate;
hzpbin = 1/period;
             
i = 1:nsample/2+1;%left one-sided spectrum->from nyquist frequency to zero
r_lo = ((i-1)*hzpbin/flo).^(2*order);
factor_lo0 = 1./(1 + r_lo);
factor_lo=[factor_lo0,fliplr(factor_lo0(2:end-1))];

                 
          
            fftx = fft(X);  
            if length(fftx)>length(factor_lo)
            factor_lo=[factor_lo0,fliplr(factor_lo0(2:end))];                
            end
            
            fftx_l = fftx.* sqrt(factor_lo);            
            L=ifft(fftx_l);
            
       
