%-------------------------------------------------------------------------%
%%  This script 'Step12' is intended for analysing SPW-R-complexes
% To be executes following 'Step11'. Here we group results on the fly,
% average them and create output.
% 
% Version 1.0 JE/KL, CLI 23-07-2020
% email: jens.eilers@...       kristina.lippmann@medizin.uni-leipzig.de                                    
%-------------------------------------------------------------------------%

%% Extract results per group
GroupResults = [];                  % Create/clear it

% We do the group analysis groupwise, even if there is just one group.
for ii =  1:AllRes(end).Group         % For all groups
    % Create a copy of entries that match Group == ii
    ThisGroup = AllRes([AllRes.Group]==ii);
    % https://de.mathworks.com/matlabcentral/answers/414989-logical-indexing-with-a-structure

    % Send it to the subroutine and store the return in GroupResults(ii)
    ThisGroup    = AverageGroup(ThisGroup);
    GroupResults = vertcat(GroupResults,ThisGroup); %#ok<AGROW>
end
GroupResults = RemoveFields(GroupResults, 'ma');
GroupResults = orderfields(GroupResults);

% Clean up
clearvars ThisGroup
disp('Done 12... Going on with Step_2itx (exporting)'); % Signal the user we are done
Step_2itx;
% done

%% The routine for averaging one group
function [Ret] = AverageGroup(Group)
fields = fieldnames(Group);     % We have these fields
Ret    = Group(1);              % One row for storing the average data.

for ii=1:size(fields,1)          % Go through all fields
    FN=char(fields(ii)); % The ii-th field without curly brackets
    
    %----------------------------------------
    % Let's first handle the 4 char and 1 group entries: 
    % Filename, Path, , Label, Name. We only take Path, Group and 
    % Label; and there's no need for averaging because all are identical.
    % Jens: Group is a  

    if ischar(Ret.(FN))
        if strcmp(FN,'Filename')
            Ret.(FN)='n.a.';
        elseif strcmp(char(fields(ii)),'Name')
            Ret.(FN)='n.a.';
        else
            Ret.(FN)= Group(1).(FN);    % For both, Path and Label
        end
        continue                     % Next field please
    end
    
    if strcmp(FN,'Group')
        Ret.(FN)=Group(1).(FN);
        continue                     % Next field please
    end

% Done with 4 chars and group
    
   %----------------------------------------
     % The rest should be numeric; double check
    if ~isnumeric(Ret.(FN))
        disp(append(num2str(ii), ' is of un-supported type'));
        continue            % Next field please
    end
    % Done with possible crazy types such as structs
 
    %----------------------------------------
    % The rest is numeric, we have:
    % v_ represents scalar (i.e., single) values
    % s_ represents statistics (7 parameters)
    % m_ represents kann weg
    % h_ represents histogrammed data
    % e_ represents the corresponding edges
    % a_*_ represents an array with * being either v or s

    % Get the first character which defines the type of data:
    [Type, Subtype] = Step_MyTypes(FN);
    
    if isempty(Type)
        continue
    end 
    
    % A.a=A.a(:,[1 2 3 6])
    % note that we sometimes use the transpose operation .' for  
    % convertinhg between rows and colums
    GrColEntry=[];
    switch Type
        case 'v'    % scalar -> 7 stats
            GroupColumn = vertcat(Group((1:end)).(FN));
            Ret.(FN) = My7StatsRowVec(GroupColumn.');
             
        case 's'    % 7 stats -> 7+7+1+1 stats
            GroupColumn = vertcat(Group(1:end).(FN));
           % auch die Anzahl der 0/1 in kstest
            % Create a local, temporary container, row vector
            GrColEntry(1,1:16) = NaN;
            
            % Digest the means -> 7 mean stats
            GrColEntry(1,1: 7) = My7StatsRowVec(GroupColumn(:,1).');

            % Now the medians -> 7 median stats
            GrColEntry(1,8:14) = My7StatsRowVec(GroupColumn(:,5).');

            % Next the total n
            GrColEntry(1,  15) = sum(GroupColumn(:,3).');
 
            % Finally the fraction of normaly-distributed data
            GrColEntry(1,  16) = sum(GroupColumn(:,4).')./size(GroupColumn,1);
 
            % Store it
            Ret.(FN) = GrColEntry;          
             
        case 'm' % we do not average m_ fields, they contain kind real data
            Ret.(FN) = NaN;  
        case 'h'    % histos: do stats on each bin
            % We have h_r_, h_n_, h_f.
            if strcmp(Subtype,'f')
                Ret.(FN)= Group(1).(FN);  % edges for the fit, no binning
            else
                GroupColumn = vertcat(Group(1:end).(FN));
                % Create a local, temporary container, row vector
                n = size(GroupColumn,2);
                GrColEntry(1,1:n*7) = NaN;
                for h=1:n
                    GrColEntry(1,h:n:n*7) = My7StatsRowVec(GroupColumn(:,h));
                    %GrColEntry(1,h:n:n*7) = 17;
                end
                Ret.(FN)= GrColEntry;
            end
              
        case 'e'    % edges, should be identical, we take the first
            Ret.(FN)= Group(1).(FN);
            
        case 'a'    % binned data, ignored for now
            if isempty(Subtype)
                continue
            end
            
            switch Subtype
                case 's'
                    
                case 'v'
                    
            end
            Ret.(FN) = NaN;
    end
end  % for loop
end


%% The routine for removing unwanted types of fields
% Removes m_ and a_ fields
function [S] = RemoveFields(S,pattern)
fields = fieldnames(S);     % We have these fields

for ii=1:size(fields,1)      % Go through all fields
    FN=char(fields(ii));     % The ii-th field without curly brackets
    if isnumeric(S(1).(FN))
        Type = extractBefore(FN,'_');
        if length(Type) == 1 && contains(pattern,Type)
            S = rmfield(S,FN);
        end
    end
end  % for loop
end

% Done EOF
