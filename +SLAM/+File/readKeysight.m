% readKeysight Read Keysight signal(s)
%
% This function reads signal data from a *.h5 binary file created by a
% Keysight digitizer.
%    [signal,time,name]=readKeysight(source);
% The input "source" indicates the file to be read.  When no file is
% specified, the user is prompted to interactively select the file. 
%
% The output "signal" contains voltages recorded by the digitizer file on
% the horizontal grid returned in "time".  Each signal column represents
% data from one digitizer channel, the labels of which are returned in
% "name".  Calling the function with no output:
%    readKeysight(source);
% automatically plots the signal(s) in a new figure window.
%
% See also SLAM.File
%
function varargout=readKeysight(file)

% manage input
if (nargin() < 1) || isempty(file)
    [file,location]=uigetfile('*.h5;*.H5;*.bin;*.bin',...
        'Choose Keysight binary file (*.h5, *.bin)');
    if isnumeric(file)
        varargout{1}=[];
        varargout{2}=[];
        return
    end
    file=fullfile(location,file);
else
    assert(isfile(file),'ERROR: requested file does not exist');    
end

% invoke reader function
[~,~,ext]=fileparts(file);
switch lower(ext)
    case '.h5'
        [signal,time,name]=read_keysightH5(file);
    otherwise
        error('ERROR: invalid Keysight binary file');
end

% manage output
if nargout() > 0
    varargout{1}=signal;
    varargout{2}=time;
    varargout{3}=name;
    return
end
figure('WindowStyle','normal','MenuBar','none','Toolbar','figure');
plot(time,signal);
xlabel('Time (s)');
ylabel('Signal (V)');
legend(name,'Location','best');
[~,name,ext]=fileparts(file);
title([name ext],'Interpreter','none');

end

function [signal,time,name]=read_keysightH5(filename)

info1=h5info(filename,'/Waveforms');
NumGroups=numel(info1.Groups);
name=cell(1,NumGroups);
left=nan(1,NumGroups);
dx=nan(1,NumGroups);
numpoints=nan();

for n=1:NumGroups
    name{n}=extractAfter(info1.Groups(n).Name,'/Waveforms/');  
    g=info1.Groups(n).Name;
    ds=fullfile(info1.Groups(n).Name,info1.Groups(n).Datasets.Name);
    ds=strrep(ds,'\','/'); % Windows fix   
    info2=h5info(filename,g);
    N=numel(info2.Attributes);
    [Aname,Avalue]=deal(cell(1,N));
    for k=1:N
        temp=info2.Attributes(k);
        Aname{k}=temp.Name;
        Avalue{k}=temp.Value;
    end
    attribute=cell2struct(Avalue,Aname,2);
    if n == 1
        numpoints=double(attribute.NumPoints);
        dx=double(attribute.XInc);
        left=double(attribute.XOrg);
    else
        assert(numpoints == double(attribute.NumPoints),...
            'ERROR inconsistent number of signal points');
    end
    % read/convert data
    temp=h5read(filename,ds);
    if isinteger(temp)
        temp=double(temp);
        y0=double(attribute.YOrg);
        dy=double(attribute.YInc);
        temp=y0+dy*temp;
    else
        temp=double(temp(:));
    end
    if n == 1
        signal=repmat(temp(:),[1 NumGroups]);
    else
        signal(:,n)=temp(:);
    end
end

right=left+(numpoints-1)*dx;
time=left:dx:right;
time=double(time(:));

end