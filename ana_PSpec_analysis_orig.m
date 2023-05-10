function powerparams = ana_PSpec_analysis(x1,y1,artefact)
%% derives parametres from the powerspectrum
% param(1): peak power
% param(2): frequency @ peak
% param(3): full width @ half max
% param(4): full area @ half max
% param(5): peak2neighbour [10 Hz vs. 2x 5 Hz]
% param(6): from
% param(7): to
% param(8): really full width = 1 || white noise @ full width = 0
if ~artefact
%% no smoothing
% % smooth the spectrum
% y1=(2*y(:,2:end-1)+y(:,1:end-2)+y(:,3:end))/4;
% x1=x(2:end-1);

% peak power
[powerparams(1),index1]=max(y1(1,:));

% frequency @ peak
powerparams(2)=x1(index1);

% from
if sum(fliplr(y1(1,1:index1-1))<(powerparams(1)/2))==0
    powerparams(6)=NaN;
else
[~, l_helpInd]=max(fliplr(y1(1,1:index1-1))<(powerparams(1)/2));
lI1=x1(index1-l_helpInd);
lI2=x1(index1-l_helpInd+1);
lA1=y1(index1-l_helpInd);
lA2=y1(index1-l_helpInd+1);
deltalY=lA2-lA1;
deltalX=lI2-lI1;
lSLOPE=deltalY/deltalX;
powerparams(6)=(((powerparams(1)/2)-lA1)/lSLOPE)+lI1;
end

% to
if sum(y1(1,index1+1:end)<(powerparams(1)/2))==0
    powerparams(7)=NaN;
else
[~, r_helpInd]=max(y1(1,index1+1:end)<(powerparams(1)/2));
rI1=x1(index1+r_helpInd-1);
rI2=x1(index1+r_helpInd);
rA1=y1(index1+r_helpInd-1);
rA2=y1(index1+r_helpInd);
deltarY=rA2-rA1;
deltarX=rI2-rI1;
rSLOPE=deltarY/deltarX;
powerparams(7)=(((powerparams(1)/2)-rA1)/rSLOPE)+rI1;
end

if ~any(isnan(powerparams(6:7)))
    % full width @ half max
    powerparams(3)=powerparams(7)-powerparams(6);
    
    % new x including cut borders
    newX(1)=powerparams(6);
    newX(2:1+length(x1(x1>=powerparams(6) & x1<=powerparams(7))))=x1(x1>=powerparams(6) & x1<=powerparams(7));
    newX(end+1)=powerparams(7);
    
    % new y including cut borders
    newY(1)=powerparams(1)/2;
    newY(2:1+length(y1(x1>=powerparams(6) & x1<=powerparams(7))))=y1(x1>=powerparams(6) & x1<=powerparams(7));
    newY(end+1)=powerparams(1)/2;
    
    % calculate full area using trapezoidal numerical integration
    area_Hz(1)=trapz(newX(1:2),newY(1:2));
    if length(newX)>3
        area_Hz(2)=trapz(newX(2:end-1),newY(2:end-1));
    elseif length(newX)<3
        disp('something unexpected happened while analysing area')
    end
    area_Hz(3)=trapz(newX(end-1:end),newY(end-1:end));
    
    powerparams(4)=sum(area_Hz);
    
    
    % really full width = 1 || white noise @ full width = 0
    if powerparams(6) == x1(1)
        powerparams(8)=0;
    else
        powerparams(8)=1;
    end
    
else
    powerparams(3)=NaN;
    powerparams(4)=NaN;
    powerparams(8)=0;
end

% % gamma/theta ratio
% lowFAmp=y1(abs(x1-10)==min(abs(x1-10)));
% highFAmp=y1(abs(x1-40)==min(abs(x1-40)));
% powerparams(5)=highFAmp./lowFAmp;

% peak2neighbour [10 Hz vs. 2x 5 Hz]

if powerparams(2)-10>5 && powerparams(2)+10<x1(end)
    % find right borders first
    rightBINborder_center=x1(abs(x1-(powerparams(2)+5))==min(abs(x1-(powerparams(2)+5))));
    ind2bin_right(1)=find(x1==powerparams(2));
    ind2bin_right(2)=find(x1==rightBINborder_center);
    ind2bin_right(3)=ind2bin_right(2)+1;
    ind2bin_right(4)=ind2bin_right(3)+(ind2bin_right(2)-ind2bin_right(1));
    
    leftBINborder_center=x1(abs(x1-(powerparams(2)-5))==min(abs(x1-(powerparams(2)-5))));
    ind2bin_left(4)=ind2bin_right(1)-1;
    ind2bin_left(3)=find(x1==leftBINborder_center);
    ind2bin_left(2)=ind2bin_left(3)-1;
    ind2bin_left(1)=ind2bin_left(2)-(ind2bin_left(4)-ind2bin_left(3));
    
    constantFullArea=(x1(ind2bin_right(4))-x1(ind2bin_left(1)))*min(y1(ind2bin_left(1)), y1(ind2bin_right(4)));
    fullArea=trapz(x1(ind2bin_left(1):ind2bin_right(4)),y1(ind2bin_left(1):ind2bin_right(4)))-constantFullArea;
    
    constantCenterArea=(x1(ind2bin_right(2))-x1(ind2bin_left(3)))*min(y1(ind2bin_left(1)), y1(ind2bin_right(4)));
    centerArea=trapz(x1(ind2bin_left(3):ind2bin_right(2)),y1(ind2bin_left(3):ind2bin_right(2)))-constantCenterArea;
    
    
    periphericArea=fullArea-centerArea;
    powerparams(5)=centerArea/periphericArea;
else
    powerparams(5)=NaN;
end
% powerparams(5)=kurtosis(newY(2:end-1));

%     range1=y1(:,(x1>5 & x1<20));
%     range2=y1(:,(x1>25 & x1<60));
%     
%     [imaxlow] = extremawithoutends2(range1);
%     [imaxhigh] = extremawithoutends2(range2);
%     
%     if isempty(imaxlow)
%     lowFAmp=median(range1);
%     else
%     lowFAmp=imaxlow;
%     end
%     
%     if isempty(imaxhigh)
%     highFAmp=median(range2);
%     else
%     highFAmp=imaxhigh;
%     end
%     
%     if length(highFAmp)>1
%         highFAmp=max(highFAmp);
%     end
%     if length(lowFAmp)>1
%         lowFAmp=max(lowFAmp);
%     end
%
%     powerparams(5)=highFAmp./lowFAmp;
% figure
% plot(x1,y1)
% hold on
% area(newX,newY,'FaceColor','r')
% plot([powerparams(6) powerparams(7)], [powerparams(1)/2 powerparams(1)/2],'k','linewidth',2)
% hold off
else
    powerparams(1,1:8)=NaN;
end

end