function [cleanPower,cleanandsmoothPower,bad_noise2signal]=ana_PSpec_smooth(input,Hzbin,noise)

% plot(Hzbin(1:length(input)),input)

% determine range of mutual artifact
allInd=1:length(Hzbin);

% binsize is to big to have a 50Hz center
if isempty(allInd(ceil(Hzbin)==noise | floor(Hzbin)==noise | round(Hzbin)==noise))
    where2look4(1,1)=find(Hzbin<noise,1,'last');
    where2look4(1,2)=find(Hzbin>noise,1,'first');
% if 50Hz center is represented we take the center and the neighbouring bins  
else
    where2look4(2:1+length(allInd(ceil(Hzbin)==noise | floor(Hzbin)==noise | round(Hzbin)==noise)))=allInd(ceil(Hzbin)==noise | floor(Hzbin)==noise | round(Hzbin)==noise);
    where2look4(1)=where2look4(2)-1;
    where2look4(end+1)=where2look4(2)+1;
end

% calculate mean of neighbours
leftmean=mean(input(where2look4(1)-ceil(numel(where2look4)/2):where2look4(1)-1));
rightmean=mean(input(where2look4(end)+1:where2look4(end)+ceil(numel(where2look4)/2)));

% calculate steps for interpolation of cut noise
corrector=(rightmean-leftmean)/(numel(where2look4)+1);

intersteps=leftmean:corrector:rightmean;
intersteps=intersteps(2:end-1);


% replace noise by interpolation
noiseFREEinput=input;

noiseFREEinput(where2look4)=intersteps;

% size of artefact
arteAmp=max(input(where2look4));

% test whether 50Hz Peak was an artefact
if input(where2look4(1)-1)/arteAmp>0.66 || input(where2look4(end)+1)/arteAmp>0.66
    cleanPower(1,find(Hzbin>0,1,'first'):find(Hzbin>0,1,'first')+length(input)-1)=input;
    bad_noise2signal=false;
else
    cleanPower(1,find(Hzbin>0,1,'first'):find(Hzbin>0,1,'first')+length(input)-1)=noiseFREEinput;
    bad_noise2signal=arteAmp/max(noiseFREEinput(where2look4))>500;
%     noisy=arteAmp/max(noiseFREEinput(where2look4));
%     disp(noisy)
end

cleanandsmoothPower(1,1:length(cleanPower))=NaN;
cleanandsmoothPower(1,2:length(cleanPower)-1)=(2*cleanPower(1,2:end-1)+cleanPower(1,1:end-2)+cleanPower(:,3:end))/4;

end