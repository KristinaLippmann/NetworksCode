function DATAchannels=helfu_ReadSMRchannels(filename,type)

[~, ~, version_x]=fileparts(filename);

switch version_x 
case '.smr'

setenv('oldSpike2mat', [pwd filesep 'spike2.7mat']);
cedpath = getenv('oldSpike2mat');
addpath(cedpath);

if (SONVersion('nodisplay')<2.31)
    errordlg('ImportSMR: An old version of the SON library is on the MATLAB path.\nDelete this and use the version in sigTOOL');
    matfilename='';
    which('SONVersion');
    return;
end
dataInMemory = struct([]);

[pathname filename2 extension]=fileparts(filename);
if strcmpi(extension,'.smr')==1
    % Spike2 for Windows source file so little-endian
    fid=fopen(filename,'r','l');
elseif strcmpi(extension,'.son')==1
    % Spike2 for Mac file
    fid=fopen(filename,'r','b');
else
    warning('%s is not a Spike2 file\n', filename);
    matfilename='';
    return
end
    
if fid<0
    matfilename='';
    return
end

% get list of valid channels
F=SONFileHeader(fid);
c=SONChanList(fid);

[channeltypes{1:length(c),1}]=c(1:end).kind;
channeltypes=cell2mat(channeltypes);
[DATAchannels{1:sum(channeltypes==type),1}]=c(channeltypes==type).title;
[DATAchannels{1:sum(channeltypes==type),2}]=c(channeltypes==type).number;

    case '.smrx'
        
        if isempty(getenv('CEDS64ML'))
            setenv('CEDS64ML', [pwd filesep 'spike2.8mat' filesep 'CEDS64ML']);
        end
        cedpath = getenv('CEDS64ML');
        addpath(cedpath);
        % load ceds64int.dll
        CEDS64LoadLib( cedpath );
        % Open a file
        file_handle = CEDS64Open(filename);
        
        if (file_handle <= 0); unloadlibrary ceds64int; return; end
        
        maxChan=CEDS64MaxChan( file_handle )+1;
        ind=1;
        for i=1:maxChan
            [ iOk, sTitleOut ] = CEDS64ChanTitle( file_handle, i-1);
            if iOk==0
            DATAchannels{ind,1}=sTitleOut;
            DATAchannels{ind,2}=num2str(i-1);
            ind=ind+1;
            end
        end
end
        
        
end