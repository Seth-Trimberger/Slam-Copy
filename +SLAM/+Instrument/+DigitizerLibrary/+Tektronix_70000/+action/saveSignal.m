% saveSignal Save analog signals
%
% This function saves analog signals to a binary file format (ISF).
%    saveSignal(object,file,bytes);
% Optional input "file" indicates the base file name used for saving data.
% When this input is empty/omitted, the user is prompted to interactively
% select a base file name.  Separate files are written for each channel,
% appending the base name with an underscore and channel number, e.g.
% '_CH1'.  Any file extension other than *.isf is automatically changed to
% *.isf.
% 
% NOTE: only active channels with available data are saved by this function.
% An error is generated when no signals are available.  
%
% See also readSignal
%
function saveSignal(object,file,bytes)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(file)
    [name,location]=uiputfile({'*.isf;*.ISF' 'Tektronix ISF files'},...
        'Select base file name');
    if isnumeric(name)
        return
    end
    file=fullfile(location,name);
else
    if isStringScalar(file)
        file=char(file);
    end
    assert(ischar(file),'ERROR: invalid base file name');
end
[location,name,ext]=fileparts(file);
if ~strcmpi(ext,'.isf')
    ext='.isf';
end
name=handy.portableFilename(name);

if (Narg < 3) || isempty(bytes) || (bytes == 2)
    bytes=2;
elseif bytes == 1
    bytes=1;
else
    error('ERROR: invalid number of read bytes');
end

% send commands
communicate(object,...
    ':WFMOUTPRE:ENCDG BINARY; BYT_OR LSB; BYT_NR %d; BN_FMT RI',bytes);
response=query(object,'HORIZONTAL:RECORDLENGTH?');
points=sscanf(response,'%g',1);
communicate(object,'DATA:START 1; STOP %g',points);
active=object.Action.getActive();
active=sprintf('%s ',active{:});
channels=object.Feature.Channels;
for n=1:numel(channels)
    if contains(active,channels{n},'IgnoreCase',true())
        label=object.Feature.Channels{n};
        target=sprintf('%s_%s',name,label);
        target=fullfile(location,[target ext]);
        fid=fopen(target,'w');
        CU=onCleanup(@() fclose(fid));
        communicate(object,':DATA:SOURCE %s',label);
        preamble=communicate(object,':WFMOUTPRE?');
        fprintf(fid,'%c',preamble);
        command=':CURVE?';
        writeline(object.Device,command);
        [~]=read(object.Device,numel(command),'uint8');
        fprintf(fid,'%s',command(1:end-1));
        raw=readbinblock(object.Device,'uint8');
        N=numel(raw);
        digits=ceil(log10(N));
        fprintf(fid,'\n#%d%d',digits,N);
        fwrite(fid,raw,'uint8');
        delete(CU);
    end
end

end