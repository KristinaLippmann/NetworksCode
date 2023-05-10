%addpath(genpath(pwd))

loadinfo=load_folder_n_files2analyse();

%% loadinfo works as filelist and could be saved here
target_folder=fileparts(loadinfo{1,1});
current_date_time=datestr(now,'yymmdd_HHMM');
filename2save=['loadinfo_' current_date_time '.mat'];

save(fullfile(target_folder,filename2save),'loadinfo','-v7.3');
clear current_date_time filename2save target_folder


% %% loading matdata
% allinall_analysis=tic;
% for i=1:size(loadinfo,1)
%     % channels of chosen files will be loaded here
%     disp(['loading file ' num2str(i)])
%     
%     % converted files are saved intheir original folder [uncomment if not wanted]
%     [~, prename, ~]=fileparts(loadinfo{i,2});
%     prename(strfind(prename,'.'))='_';
%     
%     timesOFint=str2num(loadinfo{i,8});
%     load(fullfile(loadinfo{i,1},['raw_' prename '_Ch' num2str(loadinfo{i,3}) '_' loadinfo{i,4} '.mat']))
%     clear tempname
%     
%     % do the analysis
%     if size(loadinfo,2)==8
%     [info, data, results]=main_gamma_analiz(rawdata, timesOFint,'all',prename);
%     else
%     [info, data, results]=main_gamma_analiz(rawdata, timesOFint,'all',loadinfo{i,9});
%     end
%     clear rawdata
%  
%     % prepare the figures
%     if size(loadinfo,2)==8
%             main_gamma_FIG(info,data,results,loadinfo{i,1},info.nameOFfile)
%         newname=['analysed_' info.nameOFfile];
%     else
%             main_gamma_FIG(info,data,results,loadinfo{i,1},[loadinfo{i,9} '_Ch' num2str(loadinfo{i,3}) '_' loadinfo{i,4}] )
%         newname=['analysed_' loadinfo{i,9} '_Ch' num2str(loadinfo{i,3}) '_' loadinfo{i,4}];
%     end
%     
%     disp(['saving file ' num2str(i)])
%     save(fullfile(loadinfo{i,1},newname),'results','data','info','-v7.3');
%     
%     clear info data results newname currentfile
%     
% end
% clear i
% 
% disp(['total time for all files: ' num2str((round(toc(allinall_analysis)*100))/100) ' s'])
% clear allinall_analysis timesOFint


%% loading data
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
    
    tempname=[prename '_' 'Ch' rawdata.title];

    
%     save(fullfile(loadinfo{i,1},['raw_' tempname]),'rawdata','-v7.3');
    clear tempname
    
    % do the analysis
    if size(loadinfo,2)==8
    [info, data, results]=main_gamma_analiz(rawdata, timesOFint,'all',prename);
    else
    [info, data, results]=main_gamma_analiz(rawdata, timesOFint,'all',loadinfo{i,9});
    end
    clear rawdata
 
    % prepare the figures
    if size(loadinfo,2)==8
            main_gamma_FIG(info,data,results,loadinfo{i,1},info.nameOFfile)
        newname=['analysed_' info.nameOFfile];
    else
            main_gamma_FIG(info,data,results,loadinfo{i,1},[loadinfo{i,9} '_Ch' num2str(loadinfo{i,3}) '_' loadinfo{i,4}] )
        newname=['analysed_' loadinfo{i,9} '_Ch' num2str(loadinfo{i,3}) '_' loadinfo{i,4}];
    end
    
    disp(['saving file ' num2str(i)])
    save(fullfile(loadinfo{i,1},newname),'results','data','info','-v7.3');
    
    clear info data results newname currentfile
    
end
clear i

disp(['total time for all files: ' num2str((round(toc(allinall_analysis)*100))/100) ' s'])
clear allinall_analysis timesOFint
%% done