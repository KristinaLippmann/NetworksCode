function [TAU, autocorr, autopeaks4fit] = ana_AutoCorrFit(helpM,samplingrate,artefact,bad_noise, prepowerinfo, mat_ver)

powerinfo=prepowerinfo(1,2:3);

[preautocorr,prelags] = xcorr(helpM,...
    fix(0.2*samplingrate),'coeff');
clear helpM

prelags=prelags/samplingrate;

% make sure that correlations have the same length (resample if not)
if length(prelags)~=4001
    autocorr_help=resample(preautocorr,4001,length(prelags),1000);
    lags=(-0.2:0.4/4000:0.2);
else
    autocorr_help=preautocorr;
    lags=prelags;
end
clear preautocorr prelags

expected_mainpeak=1/powerinfo(1);
if ~artefact && ~bad_noise && expected_mainpeak<0.05
    
    [pretempexpoMax, pretempexpoMaxInd]=findpeaks(autocorr_help(2001:3501));
%     [pretempexpoMin, pretempexpoMinInd]=findpeaks((-1)*autocorr_help(2001:3501));
%     tempexpoMin=pretempexpoMin*(-1);
    
%     zerocrossings=diff(sign(autocorr_help(2001:3501)));
%     upcross=sum(zerocrossings==2);
%     downcross=sum(zerocrossings==-2);
%     clear zerocrossings
    
        tempexpoMax=pretempexpoMax(pretempexpoMax>0);
        tempexpoMaxInd=pretempexpoMaxInd(pretempexpoMax>0);
        clear pretempexpoMax pretempexpoMaxInd
        
    expoTime=lags(2001:3501);
    expoTime=expoTime(tempexpoMaxInd);
    
    expected_peakjitter(1)=1/(powerinfo(1)+(powerinfo(2)/1.5));
    
    if powerinfo(2)>powerinfo(1)
        expected_peakjitter(2)=expected_peakjitter(1)+expected_mainpeak;
    else
    expected_peakjitter(2)=1/(powerinfo(1)-(powerinfo(2)/1.5));
    end
    
    prePeak=0;
    preTime=0;
    
    i=1;
    while i<=length(expoTime) && preTime(end)~=expoTime(end) && ~isempty(expoTime((expected_peakjitter(1)*i<expoTime) & (expoTime < expected_peakjitter(2)*i)))
        %[~, closest]=min(abs(abs(expoTime((expected_peakjitter(1)*i<expoTime) & (expoTime < expected_peakjitter(2)*i)))-expected_mainpeak*i));
        helpTime=expoTime((expected_peakjitter(1)*i<expoTime) & (expoTime < expected_peakjitter(2)*i));
        helpPeak=tempexpoMax((expected_peakjitter(1)*i<expoTime) & (expoTime < expected_peakjitter(2)*i));
        [~, closest]=min(abs((helpTime-expected_mainpeak*i)));
        
        prePeak(i)=helpPeak(closest);
        preTime(i)=helpTime(closest);
        i=i+1;
        helpPeak=[];
        helpTime=[];
        closest=[];
        expected_mainpeak=preTime(1);
    end
    
    [preTime,ia,~]=unique(preTime);
    prePeak=prePeak(ia);
    
    artificial_50Hz=all(mod(round(bsxfun(@rdivide,preTime,0.02/10)),10)==0) && round((round(10/expected_mainpeak))/10)~=50;
   
    if ~isempty(prePeak) && sum(preTime<0.1)>1 && ~artificial_50Hz %&& length(prePeak)>1 %
    
        % calculating the weights
        straightLineFun = @(p,x) p(1)*x+p(2);
        fittedParametres(1)=(prePeak(end)-prePeak(1))/(preTime(end)-preTime(1));
        fittedParametres(2)=prePeak(end)-(fittedParametres(1)*preTime(end));
        
        %Weights_bad=100*(1-abs(prePeak-straightLineFun(fittedParametres, preTime))).^100;
        
        if length(prePeak)>2
        initialValues = [(prePeak(end)-prePeak(1))/(preTime(end)-preTime(1)),prePeak(end)-((prePeak(end)-prePeak(1))/(preTime(end)-preTime(1))*preTime(end))];
        fittedParametres = nlinfit(preTime, prePeak, straightLineFun, initialValues);
        end
        
        if fittedParametres(1)<-0.01 %&& fittedParametres(2)>0.05 && sum((bsxfun(@rdivide,diff(prePeak),diff(preTime)))<0)/(length(prePeak)-1)>0.5
            %clear fittedParametres initialValues
            
            % janolli method
            % p(1): plateau that is reached at the end
            % p(2): tau
            expoDecayFun = @(p,x) (p(1) + (1-p(1))*(exp(-x/p(2))))*(1-(p(2)<(2.7183/1000)));
            opts = statset('nlinfit');
            opts.RobustWgtFun=[];
            if strcmp(mat_ver,'new')
            opts.UseParallel=true;
            else
            opts.UseParallel='always';
            end
            
            % guessing tau from straight line connecting the first max
            m = (prePeak(1)-1)/preTime(1); % slope of line
            pointOfint = prePeak(end)+(1-prePeak(end))*exp(-1); % value at 1/e
            initialTAU=(pointOfint-1)/m;
            
            initialValues = [prePeak(end) initialTAU];

            Weights_good=100*(1-abs(prePeak-straightLineFun(fittedParametres, preTime))).^100;
            %Weights=[100 100 1 10 10];
            %Weights=[100 100 100 100 100];
            
%             fittedParametres_standard=nlinfit([0 preTime],[1 prePeak],...
%                 expoDecayFun,initialValues,opts);
            try
            fittedParametres=nlinfit([0 preTime],[1 prePeak],...
                expoDecayFun,initialValues,opts,'Weights',[100 100 Weights_good(2:end)]);
            
%             fittedParametres_bad=nlinfit([0 preTime],[1 prePeak],...
%                 expoDecayFun,initialValues,opts,'Weights',[100 Weights_bad]);
            % time constant in ms (therefore multiplying by 1000)
            TAU=fittedParametres(2)*1000;
            TAU(:,1)=TAU;
            autocorr(:,3)=expoDecayFun(fittedParametres, 0:0.0001:0.1);
            
            autopeaks4fit(:,1)=preTime(preTime<0.1);
            autopeaks4fit(:,2)=prePeak(preTime<0.1);
%             figure
%             plot(lags(2001:3001)*1000,autocorr_help(2001:3001))
%             hold on
%             plot(preTime*1000,prePeak,'ro')
%             %line(0:1:100, expoDecayFun(fittedParametres_bad, 0:0.001:0.1),'LineStyle',':', 'Color',[0.5 0.5 0.5])
%             %line(0:1:100, expoDecayFun(fittedParametres_standard, 0:0.001:0.1), 'Color',[0.2 0.2 0.2])
%             line(0:1:100, expoDecayFun(fittedParametres, 0:0.001:0.1), 'Color','m')
%             hold off
            catch
            prePeak=NaN;
            preTime=NaN;
            TAU=NaN;
            autocorr(1:length(lags(2001:3001)),3)=NaN;
            autopeaks4fit(:,1:2)=NaN;
            end
            
        else
            prePeak=NaN;
            preTime=NaN;
            TAU=NaN;
            autocorr(1:length(lags(2001:3001)),3)=NaN;
            autopeaks4fit(:,1:2)=NaN;
        end
    else
        prePeak=NaN;
        preTime=NaN;
        TAU=NaN;
        autocorr(1:length(lags(2001:3001)),3)=NaN;
        autopeaks4fit(:,1:2)=NaN;
    end
else
    prePeak=NaN;
    preTime=NaN;
    TAU=NaN;
    autocorr(1:length(lags(2001:3001)),3)=NaN;
    autopeaks4fit(:,1:2)=NaN;
end

autocorr(:,1)=lags(2001:3001);
autocorr(:,2)=autocorr_help(2001:3001);

