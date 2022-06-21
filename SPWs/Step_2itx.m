%-------------------------------------------------------------------------%
%%  This script 'Step_2itx' is intended for analysing SPW-R-complexes
% To be executed following 'Step12'.
% Here we export v_, s_, and h_n_ values to Igor's *.itx
% Version 1.0 JE/KL, CLI 30-07-2020
% Version 1.1 JE/KL, CLI 17-12-2020, sorting into subfolders in Igor
% email: jens.eilers@...       kristina.lippmann@medizin.uni-leipzig.de                                    
%-------------------------------------------------------------------------%

%% Extract results per group

% We go through all fieldnames
fields      = fieldnames(GroupResults); % We have these fields
NoOfGr      = AllRes(end).Group;        % No. of groups
nPerGroup   = zeros(NoOfGr,1);          % No. of obs. per group, local use
Labels      = strings(NoOfGr,1);        % Label of groups

% Open the file
fileID = fopen('SWRdata.itx','w');
fprintf(fileID,'IGOR\n');

for iFN=1:size(fields,1)                % Go through all of them
    FN=char(fields(iFN));               % i-th field without curly brackets
    if ~isnumeric(GroupResults(1).(FN))
        % These are text entries we do need to export.
        continue                        % Next field please
    end
    
    if strcmp(FN,'Group')
        % This is the numeric field with the group number. Not needed here
        continue                        % Next field please
    end
    
    % The rest are entries of type v_, s_, h_, and e_ (e not needed)
    % Get to know the type and, if applicable, the subtype

    [Type, Subtype] = Step_MyTypes(FN);
    
    AllGroups   = vertcat(AllRes((1:end)).(FN));
    switch Type
        case 'v'           %Extract the column with the data of all groups
             StoreBox2Itx(AllRes,AllGroups,fileID,NoOfGr,nPerGroup,FN,Labels);
            
        case 's'    % 7 stats per slice -> 7+7+1+1 stats per group
            % We always average data per slice as medians (#5)
            % Slices per group are exported as data points
            AllGroups = AllGroups(:,5);                  % The medians
             StoreBox2Itx(AllRes,AllGroups,fileID,NoOfGr,nPerGroup,FN,Labels);
        
        case 'h'    % histograms
            % We have h_r_, h_n_, h_f. We go for h_n
            if strcmp(Subtype,'n')
                StoreHisto2Itx(GroupResults,fileID,NoOfGr,nPerGroup,FN)
            end
    end
 end
fprintf(fileID,'X TileWindows/O=1/C\n');
fclose(fileID);

% Clean up
clearvars fields FN iFN Type Subtype nPerGroup fileID Labels fileID NoOfGr;
clearvars AllGroups ans;
disp('Done exporting to SWRdata.itx...');     % Signal the user we are done
% done


function StoreHisto2Itx(GroupResults,fileID,NoOfGr,nPerGroup,FN)
fprintf(fileID,'X SetDataFolder root:\n');
fprintf(fileID,'X NewDataFolder/O/S %s\n',FN);

str     = extractAfter(extractAfter(FN,'_'),'_');
yDatFN  = FN;                 % Is present
xDatFN  = strcat('e_h_',str); % Must be present

% Access data
AllyDat   = vertcat(GroupResults((1:end)).(yDatFN));
AllxDat   = vertcat(GroupResults((1:end)).(xDatFN));

% Export groupwise
% Also collect the n per group
for iGr=1:NoOfGr
    
    % The median, Q1, Q3 and x
    ThisyDat  = AllyDat([GroupResults.Group]==iGr,:);
    ThisxDat  = AllxDat([GroupResults.Group]==iGr,:);
    n         = size(ThisyDat,2)/7;
    nPerGroup(iGr) = ThisyDat(2*n+1);
    % n*mean,     n*SD,       n*n,      n*kstest,   n*median...
    ThisMd    = ThisyDat(4*n+1:5*n);
    ThisQ1    = ThisyDat(5*n+1:6*n);
    ThisQ3    = ThisyDat(6*n+1:7*n);
    % Cave: In Matlab, Q1 and Q3 are absolute values
    % BUT in Igor, for adding +/- waves, we need relative values
    % For example: in Matlab: Mean=100, Q1=90, Q3=120
    % Must be converted to / stored as 100 +20 -10
    ThisQ3 = ThisQ3 - ThisMd;
    ThisQ1 = ThisMd - ThisQ1;
        
    % Write the data
    fprintf(fileID,'\nWAVES %s      %s      %s      %s\n',...
        strcat(FN,'_Md_',num2str(iGr)),...
        strcat(FN,'_Q1_',num2str(iGr)),...
        strcat(FN,'_Q3_',num2str(iGr)),...
        strcat(FN,'_x_',num2str(iGr)));
    fprintf(fileID,'BEGIN\n');
    for ii=1:n
        fprintf(fileID,'%e      %e      %e      %e\n',...
            ThisMd(ii), ThisQ1(ii), ThisQ3(ii), ThisxDat(ii));
    end
    fprintf(fileID,'End\n');
end

% Create the x wave holding the lables
AllLabels   = {GroupResults((1:end)).('Label')};

% The commands for the histogram
% Create it
fprintf(fileID,'X Display /K=1 as \"%s\"\n',FN);

% % Add and pimp data [and fits]
for iGr=1:NoOfGr
    xD = strcat(FN,'_x_',    num2str(iGr));
    Md = strcat(FN,'_Md_',   num2str(iGr));
    Q1 = strcat(FN,'_Q1_',   num2str(iGr));
    Q3 = strcat(FN,'_Q3_',   num2str(iGr));
    
    % Define the color
    switch iGr
        case 1
            sMaCol   = 32125;   % was: 52428;
        case 2
            sMaCol   = 0;       % was 30583;
        otherwise
            sMaCol = 20000;
    end
    
    fprintf(fileID,'X AppendToGraph %s vs %s\n',Md,xD);
    fprintf(fileID,'X ModifyGraph mode(%s)=8\n',Md);
    fprintf(fileID,'X ModifyGraph marker(%s)=9\n',Md);
    fprintf(fileID,'X ModifyGraph lSize(%s)=10\n',Md);
    fprintf(fileID,'X ModifyGraph rgb(%s)=(%u,%u,%u)\n',...
        Md,sMaCol,sMaCol,sMaCol);
    fprintf(fileID,'X ModifyGraph hbFill(%s)=2\n',Md);
    fprintf(fileID,'X ModifyGraph useNegPat(%s)=1\n',Md);
    fprintf(fileID,'X ModifyGraph useBarStrokeRGB(%s)=1\n',Md);
    fprintf(fileID,'X ModifyGraph barStrokeRGB(%s)=(65535,65535,65535)\n',Md);
    fprintf(fileID,'X ModifyGraph offset(%s)={%e,0}\n',Md,(iGr-1)*.5);
    fprintf(fileID,'X ErrorBars/RGB=(0,0,0) %s Y,wave=(%s,%s)\n',Md,Q3,Q1);
end

% Pimp the graph
fprintf(fileID,'X ModifyGraph lblMargin(left)=12,lblMargin(bottom)=3\n');
fprintf(fileID,'X ModifyGraph standoff=0\n');
fprintf(fileID,'X ModifyGraph lblLatPos(bottom)=-2\n');
fprintf(fileID,'X ModifyGraph axisOnTop=1\n');
fprintf(fileID,'X Label left \"%s\"\n',FN);
fprintf(fileID,'X SetAxis left*,1\n');
fprintf(fileID,'X SetAxis left*,1\n');

% The legend
str = 'X Legend/C/N=text0/J/F=0/A=MC/X=39.76/Y=35.66 \"';
for iGr=1:NoOfGr
    Md = strcat(FN,'_Md_',   num2str(iGr));
    str=strcat(str,'\\\\s(', Md,')'," ",AllLabels(iGr),...
        ', n=',num2str(nPerGroup(iGr)),'\\r');
end
fprintf(fileID,'X SetDataFolder root:\n\n');
%done
end

function StoreBox2Itx(AllRes,AllGroups,fileID,NoOfGr,nPerGroup,FN,Labels)
fprintf(fileID,'X SetDataFolder root:\n');
fprintf(fileID,'X NewDataFolder/O/S %s\n',FN);
% Export groupwise
% Also collect the n per group

for iGr=1:NoOfGr
    ThisGroup  = AllGroups([AllRes.Group]==iGr);
    nPerGroup(iGr) = size(ThisGroup,1);
    
    fprintf(fileID,'\nWAVES %s\n',strcat(FN,'_',num2str(iGr)));
    fprintf(fileID,'BEGIN\n');
    fprintf(fileID,'%e\n',ThisGroup);
    fprintf(fileID,'End\n');
end

% Create & store the x wave holding the lables
AllLabels   = transpose({AllRes((1:end)).('Label')});
fprintf(fileID,'\nWAVES/T %s\n',strcat(FN,'_X'));
fprintf(fileID,'BEGIN\n');
for iGr=1:NoOfGr
    ThisLabel      = AllLabels([AllRes.Group]==iGr);
    ThisLabel      = string(ThisLabel(1));
    Labels(iGr)    = ThisLabel;
    fprintf(fileID,'\"%s\"\n',ThisLabel);
end
fprintf(fileID,'End\n\n');

% The commands for the box plot
% Create it

fprintf(fileID,'X Display /K=1 as \"%s\"\n',FN);

% Add data
xW = strcat(FN,'_X');
for iGr=1:NoOfGr
    yW = strcat(FN,'_',num2str(iGr));
    fprintf(fileID,'X AppendViolinPlot %s vs %s\n',yW,xW);
    fprintf(fileID,'X AppendBoxPlot    %s vs %s\n',yW,xW);
end

% Pimp it
fprintf(fileID,'X ModifyGraph margin(bottom)=35\n');
fprintf(fileID,'X ModifyGraph mode=4\n');
fprintf(fileID,'X ModifyGraph noLabel(bottom)=2\n');
fprintf(fileID,'X ModifyGraph lblMargin(left)=12\n');
fprintf(fileID,'X ModifyGraph standoff=0\n');
fprintf(fileID,'X ModifyGraph axThick(bottom)=0\n');
fprintf(fileID,'X ModifyGraph lblLatPos(left)=-2\n');
fprintf(fileID,'X SetAxis/A/N=1 left\n');
fprintf(fileID,'X ModifyGraph mode=4\n');
fprintf(fileID,'X ModifyGraph mode=4\n');
fprintf(fileID,'\n');
% No way... 	Label left "\\Z12 Ripple frequency"
fprintf(fileID,'X Label left \"%s\"\n',FN);

% Adjusting colors et al.
for iGr=1:NoOfGr
    yW = strcat(FN,'_',num2str(iGr));
    switch iGr
        case 1
            sMaCol = '32125';     % was '52428';
        case 2
            sMaCol = '0';         % was '30583';
        otherwise
            sMaCol = '20000';
    end
    str = strcat('ModifyViolinPlot trace=',yW,',');
    str=strcat(str,'MarkerColor=(',sMaCol,',',sMaCol,',',sMaCol,')');
    str=strcat(str,',LineThickness=0');
    fprintf(fileID,'X %s\n',str);
    
    str = strcat('ModifyBoxPlot trace=',yW,',instance=1,');
    str=strcat(str,'markers={-1,8,8,8,8},');
    str=strcat(str,'showMean,boxColor=(',sMaCol,',',sMaCol,',',sMaCol,')');
    fprintf(fileID,'X %s\n',str);
    
    str = strcat('ModifyBoxPlot trace=',yW,',instance=1,');
    str=strcat(str,'medianMarkerColor=(65535,65535,65535)');
    fprintf(fileID,'X %s\n',str);
    
    str = strcat('ModifyBoxPlot trace=',yW,',instance=1,');
    str=strcat(str,'dataColor=(65535,65535,65535),');
    str=strcat(str,'outlierColor=(65535,65535,65535)');
    fprintf(fileID,'X %s\n',str);
    
    str = strcat('ModifyBoxPlot trace=',yW,',instance=1,');
    str=strcat(str,'farOutlierColor=(65535,65535,65535)');
    fprintf(fileID,'X %s\n',str);
    
    str = strcat('ModifyBoxPlot trace=',yW,',instance=1,');
    str=strcat(str,'meanColor=(',sMaCol,',',sMaCol,',',sMaCol,')');
    fprintf(fileID,'X %s\n',str);
    
    str = strcat('ModifyBoxPlot trace=',yW,',instance=1,');
    str=strcat(str,'medianLineColor=(',sMaCol,',',sMaCol,',',sMaCol,')');
    str=strcat(str,'whiskerColor=(',sMaCol,',',sMaCol,',',sMaCol,')');
    fprintf(fileID,'X %s\n',str);
end

% Adding the labels
fprintf(fileID,'X SetDrawLayer UserFront\n');
for iGr=1:NoOfGr
    fprintf(fileID,'X SetDrawEnv textxjust= 1,textyjust= 1\n');
    fprintf(fileID,'X SetDrawEnv xcoord= bottom,ycoord= prel\n');
    str=strcat('X DrawText '," ",num2str((2*iGr-1)/(NoOfGr*2)),', 0.0,');
    str=strcat(str,'\"',Labels(iGr),', n=',num2str(nPerGroup(iGr)),'\"\n');
    fprintf(fileID,str);
end
fprintf(fileID,'X SetDataFolder root:\n\n');
end

% Done EOF


