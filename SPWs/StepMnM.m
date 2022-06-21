%-------------------------------------------------------------------------%
%%  This script 'StepMnM' is intended for analysing SPW-R-complexes
% To be executed following 'Step12'.
% Here we export all m_ values grouped to Igor's *.itx
% Version 1.0 JE/KL, CLI 17-12-2020
% email: jens.eilers@...       kristina.lippmann@medizin.uni-leipzig.de                                    
%-------------------------------------------------------------------------%

%% First we read the fieldnames and create a struct for the results
fields = fieldnames(AllRes);        % All fieldnames
nGr = AllRes(end).Group;            % # of groups
AllMsPerGroup = AllRes(1:nGr,1);    % Our final target, one line per group


% Delete all fields that are not 'Label', 'Group' or 'm_*'
% This is similar to what we did in Step 12, line 46 ff
for ii =  length(fields):-1:1
    FN=char(fields(ii)); % The i-th field without curly brackets
    
     % We keep 'Group'
    if strcmp(FN,'Group')
        continue                     % Next field please
    end
    
    % We keep 'Label
    if strcmp(FN,'Label')
        continue                     % Next field please
    end
    
   % We can remove all other fields with text entries
    if ischar(AllRes(1).(FN))
        fields(ii)=[];
        AllMsPerGroup = rmfield(AllMsPerGroup,(FN));
        continue                     % Next field please
    end
    
    % Done with 4 chars and group
    % The rest should be numeric; double check
    if ~isnumeric(AllRes(1).(FN))
          fields(ii)=[];
          AllMsPerGroup = rmfield(AllMsPerGroup,(FN));
        continue            % Next field please
    end
    % Done with possible crazy types such as structs
    % The rest is numeric, we have v_, s_, m_, h_, e_, a_*_
    % of which we only keep 'm_'
    % Get the first character which defines the type of data:
    [Type, ~] = Step_MyTypes(FN);
    if Type ~= 'm'
          fields(ii)=[];
          AllMsPerGroup = rmfield(AllMsPerGroup,(FN));
    end
end
% Now we have 'fields' and 'AllMsPerGroup'


%% Next we sum up...
% We extract data groupwise, even if there is just one group.
n   = size(AllRes,1);                    % # of entries

% Assign 'Group'
for Gr = 1:nGr          % For all groups
    AllMsPerGroup(Gr).Group = Gr;
end

% Assign 'Label'
for Gr = 1:nGr          % For all groups
    for entry=1:n       % For all entries
        if AllRes(entry).Group == Gr
            AllMsPerGroup(Gr).Label = AllRes(entry).Label;
            break
        end
    end
end

% We go through all other fields
for ii = 3: length(fields)   % For all fields but 'Group'
    FN=char(fields(ii)) ;    % The ii-th field without curly brackets
    for Gr = 1:nGr          % For all groups
        A=[];
        for entry=1:n       % For all entries
            if AllRes(entry).Group == Gr
                B = AllRes(entry).(FN);         % any 2D 'nm' array
                B = reshape(B,1,numel(B));      % now 1D, n*m
                A = [A B];                      %#ok<AGROW> % concatenating
            end
        end
        AllMsPerGroup(Gr).(FN) = A;
    end
end
% Done

%% Next export...
fileID = fopen('MnMs.itx','w');
fprintf(fileID,'IGOR\n\n');
for ii = 3: length(fields)   % For all fields but 'Label'and 'Group'
    FN=char(fields(ii)) ;    % The ii-th field without curly brackets
%     if strcmp(FN,'m_Duration') == 0
%         continue     % for debugging...
%     end
    
    fprintf(fileID,'X SetDataFolder root:\n');
    fprintf(fileID,'X NewDataFolder/O/S %s\n',FN);
    for Gr = 1:nGr          % For all groups
        w = strcat(FN,'_',AllMsPerGroup(Gr).Label);
        fprintf(fileID,'WAVES %s\n',w);
        fprintf(fileID,'BEGIN\n');
        fprintf(fileID,'%e\n',AllMsPerGroup(Gr).(FN));
        fprintf(fileID,'End\n\n');
    end
    
    
    fprintf(fileID,'X Display/K=1 as \"%s\"\n',FN);
    for Gr = 1:nGr          % For all groups
        w = strcat(FN,'_',AllMsPerGroup(Gr).Label);
        w_Hist = strcat(w,'_Hist');
        fprintf(fileID,'X Make/O/N=100/O %s\n',w_Hist);
        fprintf(fileID,'X Histogram/P/B=1  %s %s\n',w, w_Hist);
        fprintf(fileID,'X AppendToGraph %s\n',w_Hist);
        switch Gr
            case 1
                fprintf(fileID,'X ModifyGraph rgb[0]=(32125,32125,32125)\n');
            case 2
                fprintf(fileID,'X ModifyGraph rgb[1]=(0,0,0)\n');
            case 3
                fprintf(fileID,'X ModifyGraph rgb[2]=(0,65535,0)\n');
        end
    end
    fprintf(fileID,'X ModifyGraph lsize=2\n');
    fprintf(fileID,'X ModifyGraph axThick=2,axisOnTop=1,standoff=0\n');
    fprintf(fileID,'X ModifyGraph fStyle=1\n');
    fprintf(fileID,'X SetAxis/A/N=1/E=3 left\n');
    fprintf(fileID,'X SetAxis/A/N=1/E=3 bottom\n');
    fprintf(fileID,'X Legend/C/N=text0/F=0/A=MC\n');
    fprintf(fileID,'X Label bottom \"%s\"\n',FN);
    fprintf(fileID,'X Label left \"%s\"\n','PDF(\U)');
    fprintf(fileID,'X SetDataFolder root:\n\n');
end
fprintf(fileID,'X TileWindows/O=1/C');
fclose(fileID);

% % Almost done
disp('Done exporting to MnM.itx...');     % Signal the user we are done
clear ii FN Type B A n Group entry ans Element nGr Gr fields fileID
clear w w_Hist

% E O F