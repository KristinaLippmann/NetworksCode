loadinfo=load_folder2analyse();

%% loadinfo works as filelist and could be saved here
target_folder=fileparts(loadinfo{1,1});
current_date_time=datestr(now,'yymmdd_HHMM');
filename2save=['showinfo_' current_date_time '.mat'];

save(fullfile(target_folder,filename2save),'loadinfo','-v7.3');
clear current_date_time filename2save target_folder

%% loading data
x = inputdlg({'Frequency from [Hz]:','Frequency to [Hz]:','Sensitivity [Hz]:','window for detailed view [s]:'},...
           'what to print', [1 35; 1 35; 1 35; 1 35]);

%%
for k=1

if ~isempty(x)
allinall_analysis=tic;
for i=1:size(loadinfo,1)
    % channels of chosen files will be loaded here
    disp(['loading file ' num2str(i)])
    
    % uncomment the new version if you work with data recorded with spike version lower than 8
    % the new versions loader needs more time to load in data
    %[rawdata, timesOFint] = load_Spike2_8_win(loadinfo,i);
    [rawdata, timesOFint] = load_Spike2_7_win(loadinfo,i);
    
    % converted files are saved intheir original folder [uncomment if not wanted]
    [~, prename, ~]=fileparts(loadinfo{i,2});
    prename(strfind(prename,'.'))='_';
    prename=[prename '_' x{1,k} '_' x{2,k} '_' x{4,k}];
    
    helfu_data_presenter(rawdata, timesOFint, x{4,k}, x{1,k}, x{2,k}, x{3,k}, prename)

    clear rawdata timesOFint prename
    
end
clear i

disp(['total time for all files: ' num2str((round(toc(allinall_analysis)*100))/100) ' s'])
end

end
clear allinall_analysis k
% done

%%
for k=1

if ~isempty(x)
allinall_analysis=tic;
for i=1:size(loadinfo_1sec,1)
    % channels of chosen files will be loaded here
    disp(['loading file ' num2str(i)])
    
    % uncomment the new version if you work with data recorded with spike version lower than 8
    % the new versions loader needs more time to load in data
    %[rawdata, timesOFint] = load_Spike2_8_win(loadinfo,i);
    [rawdata, timesOFint] = load_Spike2_7_win(loadinfo_1sec,i);
    
    % converted files are saved intheir original folder [uncomment if not wanted]
    [~, prename, ~]=fileparts(loadinfo_1sec{i,2});
    prename(strfind(prename,'.'))='_';
    prename=[prename '_' x{1,k} '_' x{2,k} '_' x{4,k}];
    
    helfu_data_presenter(rawdata, timesOFint, x{4,k}, x{1,k}, x{2,k}, x{3,k}, prename)

    clear rawdata timesOFint prename
    
end
clear i

disp(['total time for all files: ' num2str((round(toc(allinall_analysis)*100))/100) ' s'])
end

end
clear allinall_analysis k
% done

%
for k=2

if ~isempty(x)
allinall_analysis=tic;
for i=1:size(loadinfo_2sec,1)
    % channels of chosen files will be loaded here
    disp(['loading file ' num2str(i)])
    
    % uncomment the new version if you work with data recorded with spike version lower than 8
    % the new versions loader needs more time to load in data
    %[rawdata, timesOFint] = load_Spike2_8_win(loadinfo,i);
    [rawdata, timesOFint] = load_Spike2_7_win(loadinfo_2sec,i);
    
    % converted files are saved intheir original folder [uncomment if not wanted]
    [~, prename, ~]=fileparts(loadinfo_2sec{i,2});
    prename(strfind(prename,'.'))='_';
    prename=[prename '_' x{1,k} '_' x{2,k} '_' x{4,k}];
    
    helfu_data_presenter(rawdata, timesOFint(1,1:2), x{4,k}, x{1,k}, x{2,k}, x{3,k}, prename)

    clear rawdata timesOFint prename
    
end
clear i

disp(['total time for all files: ' num2str((round(toc(allinall_analysis)*100))/100) ' s'])
end

end
clear allinall_analysis k
% done

%
for k=3

if ~isempty(x)
allinall_analysis=tic;
for i=1:size(loadinfo_5sec,1)
    % channels of chosen files will be loaded here
    disp(['loading file ' num2str(i)])
    
    % uncomment the new version if you work with data recorded with spike version lower than 8
    % the new versions loader needs more time to load in data
    %[rawdata, timesOFint] = load_Spike2_8_win(loadinfo,i);
    [rawdata, timesOFint] = load_Spike2_7_win(loadinfo_5sec,i);
    
    % converted files are saved intheir original folder [uncomment if not wanted]
    [~, prename, ~]=fileparts(loadinfo_5sec{i,2});
    prename(strfind(prename,'.'))='_';
    prename=[prename '_' x{1,k} '_' x{2,k} '_' x{4,k}];
    
    helfu_data_presenter(rawdata, timesOFint, x{4,k}, x{1,k}, x{2,k}, x{3,k}, prename)

    clear rawdata timesOFint prename
    
end
clear i

disp(['total time for all files: ' num2str((round(toc(allinall_analysis)*100))/100) ' s'])
end

end
clear allinall_analysis

%%
for k=7:8

if ~isempty(x)
allinall_analysis=tic;
for i=1:size(loadinfo_90sec,1)
    % channels of chosen files will be loaded here
    disp(['loading file ' num2str(i)])
    
    % uncomment the new version if you work with data recorded with spike version lower than 8
    % the new versions loader needs more time to load in data
    %[rawdata, timesOFint] = load_Spike2_8_win(loadinfo,i);
    [rawdata, timesOFint] = load_Spike2_7_win(loadinfo_90sec,i);
    
    % converted files are saved intheir original folder [uncomment if not wanted]
    [~, prename, ~]=fileparts(loadinfo_90sec{i,2});
    prename(strfind(prename,'.'))='_';
    prename=[prename '_' x{1,k} '_' x{2,k} '_' x{4,k}];
    
    helfu_data_presenter(rawdata, timesOFint, x{4,k}, x{1,k}, x{2,k}, x{3,k}, prename)

    clear rawdata timesOFint prename
    
end
clear i

disp(['total time for all files: ' num2str((round(toc(allinall_analysis)*100))/100) ' s'])
end

end
clear allinall_analysis

%% done