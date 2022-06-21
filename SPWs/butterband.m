function L=butterband(X,sampling_rate,flo,fhi,order)


nsample=length(X);
period = nsample/sampling_rate;
hzpbin = 1/period;

ii = 1:nsample/2+1;%left one-sided spectrum->from nyquist frequency to zero
r_lo = ((ii-1)*hzpbin/flo).^(2*order);%->normalized spectrum: hzpbin/flo=n
factor_lo0 = r_lo./(1 + r_lo);
r_hi = ((ii-1)*hzpbin/fhi).^(2*order);
factor_hi0 = 1./(1 + r_hi);

factor_lo=[factor_lo0,fliplr(factor_lo0(2:end-1))];
factor_hi=[factor_hi0,fliplr(factor_hi0(2:end-1))];


fftx = fft(X);
if length(fftx)>length(factor_lo)
    factor_lo=[factor_lo0,fliplr(factor_lo0(2:end))];
    factor_hi=[factor_hi0,fliplr(factor_hi0(2:end))];
end
% if size(fftx,1)>size(factor_lo,1)
%     fftx=fftx';
% end

fact=sqrt(factor_lo.* factor_hi);
if size(fftx,1)~=size(fact,1)
    fact=fact';
end

fftx_l = fftx.* fact;
L=ifft(fftx_l);


