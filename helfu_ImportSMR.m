function data_singleChannel=ImportSMR_requested(filename,chan)
% ImportSMR imports Cambridge Electronic Design Spike2 files to MATLAB
%
% filename is the path and name of the Spike2 file to import.
% chan is the channel to import
%
% modified by janolli
% -------------------------------------------------------------------------
% Original Author: Malcolm Lidierth 07/06
% Copyright � The Author & King's College London 2006-2007
% -------------------------------------------------------------------------

% add path to CED code
if isempty(getenv('oldSpike2mat'))
    setenv('oldSpike2mat', [pwd filesep 'spike2.7mat']);
end
cedpath = getenv('oldSpike2mat');
addpath(cedpath);

extension=filename(end-3:end);

if strcmpi(extension,'.smr')==1
    % Spike2 for Windows source file so little-endian
    fid=fopen(filename,'r','l');
elseif strcmpi(extension,'.son')==1
    % Spike2 for Mac file
    fid=fopen(filename,'r','b');
else
    warning('%s is not a Spike2 file\n', filename);
    return
end


if fid<0
    return
end

[data,header]=SONGetChannel(fid, chan,'ticks','scale','progress');

if isempty(data)
    error('something went wrong, call janolli')
end

tempTime_header=SONFileHeader(fid);

if size(num2str(tempTime_header.timeDate.Detail(4)),2)<2
    hour=[num2str(0) num2str(tempTime_header.timeDate.Detail(4))];
else
    hour=num2str(tempTime_header.timeDate.Detail(4));
end

if size(num2str(tempTime_header.timeDate.Detail(3)),2)<2
    minute=[num2str(0) num2str(tempTime_header.timeDate.Detail(3))];
else
    minute=num2str(tempTime_header.timeDate.Detail(3));
end

data_singleChannel.filename=header.FileName;
data_singleChannel.title=[num2str(chan) '_' header.title];

data_singleChannel.experiment_started=[hour ':' minute];

data_singleChannel.interval=prod([header.sampleinterval 1e-6]);

data_singleChannel.length=header.npoints;

data_singleChannel.values=data;

clear data header hour minute

fclose(fid);
end