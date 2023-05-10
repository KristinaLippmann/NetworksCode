function [wavelet, wavelet_timeBIN, wavelet_HzBIN ]=fu_Morlet(v,sampling_rate,f0,fe,delta)
%V-trace
%f0-     starting frequency
%fe-     ending frequency
%delta-  frequency resolution
%--------------------------------------------------------------------------


v=v-mean(v);

steps=ceil((fe-f0)/delta);
wavelet_HzBIN=f0:delta:fe;


omega0=6;

for i=1:steps+1
    %waitbar(i/steps)
    if i>1       
       f0=f0+delta;
    end
f=sampling_rate\f0;%normalizing
    
a=((omega0+sqrt(2+omega0^2))/(4*pi))*f^-1;%frequency to scale
% f00(i)=f;
% sc(i)=a;
% 
% beta=omega0^2;
inter=ceil(a*omega0/2);%Teff=a*omega0 (power!!!)
t=-inter:inter;
if fix(length(t)/2)==length(t)/2 %even number!
    t=[t t(end)+1];
end

Tsub=t/a;
norm=(sqrt(a)^-1);
psi=norm*((pi)^-(1/4))*exp(-(Tsub.^2)/2).*exp(1i*omega0*Tsub);


if i==1%Berechnung einmal!
    l0=length(psi);
    START=(l0-1)/2;%morlet mass center--> "in phase" for all morlets to the largest morlet at i==1!
end
li=length(psi);

A=conv(psi,v);
lv=length(v);

%if i>1
    start=START-(li-1)/2+1;    
%end
%wavelet(i,1:lv+length(n)-1)=real(A);
NORM=2*(sqrt(pi)*a)^-1;%SHYU2002
wavelet(i,start:lv+length(psi)+start-2)=NORM*abs(A).^2;%power!  largest Wavelet at 1-->max alignment
%wavelet(i,start:lv+length(psi)+start-2)=(abs(A).^2)/sampling_rate;
%Teffective=(f/omega0);
end
%close(H) 
wavelet=wavelet(:,START:end-START);
%wavelet=wavelet(:,l0:end-l0);%removing of not fully occupied conv

%--------------------------------------------------------------------------
tt=1:size(wavelet,2);
wavelet_timeBIN=(1:length(tt))/sampling_rate;%time shift! (lost time)
%ttt=1:length(v)+(l0-1)/2;
%time=(tt((l0-1)/2):tt(end))/sampling_rate;%time shift! (lost time)
%v=v((l0-1)/2:end-(l0-1)/2);
time=(1:length(v))/sampling_rate;


if fe<f0
    wavelet_HzBIN(1,end+1)=f0;
end
wavelet_HzBIN=wavelet_HzBIN';
wavelet=wavelet(:,1:end-1);
wavelet_timeBIN=wavelet_timeBIN(:,1:end-1);
end

