function output=load_folder_n_files2analyse(varargin)

% add path to JAVA code
setenv('javacode', [pwd filesep 'java_TableSort']);
javapath = getenv('javacode');
addpath(javapath);

Figure_handle=figure;

prein.output={};

if ~isempty(cell2mat(varargin))
    prein.inpath=varargin;
else
prein.inpath={''};
end
set(Figure_handle, 'UserData' ,prein)


PushButton_files=uicontrol(Figure_handle, 'Style','pushbutton','String','add files for analysis',...
    'units','normalized','pos',[0.1,0.92,0.25,0.06],...
    'Callback',@loadbuttonCallback_files);

PushButton_folder=uicontrol(Figure_handle, 'Style','pushbutton','String','add path to files for analysis',...
    'units','normalized','pos',[0.65,0.92,0.25,0.06],...
    'Callback',@loadbuttonCallback_folder);




uiwait(Figure_handle)
if ishandle(Figure_handle)
    %Figure_handle=gcf;
    preout=get(Figure_handle, 'UserData');
    if isstruct(preout)
        output=preout.output;
    else
        output=preout;
    end
    
    output=output(cell2mat(output(:,5)),:);
    close gcf
else
    warning('execution terminated by user')
    output=[];
    return
end


end

function data2load=loadbuttonCallback_files(ObjH,Figure_handle)
Figure_handle=gcf;
    preout=get(Figure_handle, 'UserData');
    if ~isstruct(preout)
        output=preout;
        inpath=preout{end,1};
        clear preout
    else
    output=preout.output;
    inpath=preout.inpath{:};
    end
    
    if ~isempty(inpath)
        [loadfile, loadpath]=uigetfile( ...
            {  '*.smr; *.smrx' ,'spike-files (*.smr & *.smrx)'}, ...
            'Pick a file', ...
            'MultiSelect', 'on',...
            inpath);
    else
        [loadfile, loadpath]=uigetfile( ...
            {  '*.smr; *.smrx' ,'spike-files (*.smr & *.smrx)'}, ...
            'Pick a file', ...
            'MultiSelect', 'on');
    end

if ischar(loadfile)
loadfile={loadfile};
end

for i=1:size(loadfile,2)
    preDATAchannels=helfu_ReadSMRchannels([loadpath filesep loadfile{1,i}],1);
if i==1
    data2load(1:size(preDATAchannels,1),1)=cellstr(loadpath);
    data2load(1:size(preDATAchannels,1),2)=cellstr(loadfile{1,i});
    data2load(1:size(preDATAchannels,1),3)=preDATAchannels(:,2);
    data2load(1:size(preDATAchannels,1),4)=preDATAchannels(:,1);
    data2load(1:size(preDATAchannels,1),5)=cellfun(@true,{1},'UniformOutput',false);
    data2load(1:size(preDATAchannels,1),6)=cellstr('');
    data2load(1:size(preDATAchannels,1),7)=cellstr('');
    data2load(1:size(preDATAchannels,1),8)=cellstr('');
else
    currentsize=size(data2load,1);
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),1)=cellstr(loadpath);
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),2)=cellstr(loadfile{1,i});
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),3)=preDATAchannels(:,2);
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),4)=preDATAchannels(:,1);
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),5)=cellfun(@true,{1},'UniformOutput',false);
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),6)=cellstr('');
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),7)=cellstr('');
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),8)=cellstr('');
    clear currentsize
end
clear preDATAchannels
end

output=vertcat(output,data2load);

wd=output;
[~,idx]=unique(strcat(wd(:,1),wd(:,2),wd(:,3)));
uniqueDATA=wd(idx,:);

[jtable, output_1] = treeTable(gcf,{'folder', 'files', 'channels','label', 'to load or not to load', 'start2cut', 'stop2cut','times of interest'},uniqueDATA,'ColumnTypes',{'char','char','','char','logical','char','char','char'});
preout.output=output_1.data;
% if ischar(loadpath)
%     loadpath=cell(loadpath);
% end

preout.inpath{:}=loadpath;
Figure_handle=gcf;
set(Figure_handle, 'UserData' ,preout)

PushButton2=uicontrol(gcf, 'Style','pushbutton','String','...analyse datasets...',...
    'units','normalized','pos',[0,0,1,0.1],...
    'Callback',@executebuttonCallback, ...
    'UserData', Figure_handle);
end

function data2load=loadbuttonCallback_folder(ObjH,Figure_handle)
Figure_handle=gcf;
    preout=get(Figure_handle, 'UserData');
    if ~isstruct(preout)
        output=preout;
        inpath=preout{end,1};
        clear preout
    else
    output=preout.output;
    inpath=preout.inpath{:};
    end
    
    if ~isempty(inpath)
        loadpath=uigetdir(inpath);
    else
        loadpath=uigetdir;
    end
    loadpath=[loadpath filesep];
datafiles=struct2cell(dir([loadpath '*.smr*']));

for i=1:size(datafiles,2)
    preDATAchannels=helfu_ReadSMRchannels([loadpath filesep datafiles{1,i}],1);
if i==1
    data2load(1:size(preDATAchannels,1),1)=cellstr(loadpath);
    data2load(1:size(preDATAchannels,1),2)=datafiles(1,i);
    data2load(1:size(preDATAchannels,1),3)=preDATAchannels(:,2);
    data2load(1:size(preDATAchannels,1),4)=preDATAchannels(:,1);
    data2load(1:size(preDATAchannels,1),5)=cellfun(@true,{1},'UniformOutput',false);
    data2load(1:size(preDATAchannels,1),6)=cellstr('');
    data2load(1:size(preDATAchannels,1),7)=cellstr('');
    data2load(1:size(preDATAchannels,1),8)=cellstr('');
else
    currentsize=size(data2load,1);
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),1)=cellstr(loadpath);
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),2)=datafiles(1,i);
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),3)=preDATAchannels(:,2);
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),4)=preDATAchannels(:,1);
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),5)=cellfun(@true,{1},'UniformOutput',false);
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),6)=cellstr('');
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),7)=cellstr('');
    data2load(currentsize+1:currentsize+size(preDATAchannels,1),8)=cellstr('');
    clear currentsize
end
clear preDATAchannels
end

output=vertcat(output,data2load);

wd=output;
[~,idx]=unique(strcat(wd(:,1),wd(:,2),wd(:,3)));
uniqueDATA=wd(idx,:);

[jtable, output_1] = treeTable(gcf,{'folder', 'files', 'channels','label', 'to load or not to load', 'start2cut', 'stop2cut','times of interest'},uniqueDATA,'ColumnTypes',{'char','char','','char','logical','char','char','char'});
preout.output=output_1.data;
preout.inpath{:}=loadpath;
Figure_handle=gcf;
set(Figure_handle, 'UserData' ,preout)

PushButton2=uicontrol(gcf, 'Style','pushbutton','String','...analyse datasets...',...
    'units','normalized','pos',[0,0,1,0.1],...
    'Callback',@executebuttonCallback, ...
    'UserData', Figure_handle);
end


function data2load=executebuttonCallback(ObjH,Figure_handle)
uiresume
end
