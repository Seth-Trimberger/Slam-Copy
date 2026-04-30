% CODATA Look up physical constants
%
% This function looks up physical constants using CODATA recommended
% values.  Quantities matching one or more text patterns (case insensitive)
% are returned as a structure array.
%    data=CODATA(pattern1,pattern2,...);
% When no patterns are specified, "data" contains every tabulated constant.
% Patterns are inclusive by default (e.g. 'mass') and exclusive when
% started by a dash (e.g. '-mass').  Exact matches are specified with an
% dollar sign as illustrated below.
%    data=CODATA('$electron mass'); 
% The output "data" has fields Quantity, Value, Uncertainty, and Units.
%
% Calling this function with no output:
%    CODATA(pattern1,pattern2,...);
% prints all matching constants in the command window.  Printed values may
% be shown at different precision than the tabulation, so
% numerical calculations should be based on explicit lookup (shown above).
%
% Data obtained from https://physics.nist.gov/cuu/Constants/
%
% See also SLAM.Reference
%
function varargout=CODATA(varargin)

persistent data start
if isempty(data)
    location=fileparts(mfilename('fullpath'));
    file=fullfile(location,'data','CODATA.txt');
    fid=fopen(file,'r');
    CU=onCleanup(@() fclose(fid));
    % process header
    previous='';
    while~ feof(fid)
        current=fgetl(fid);
        if isempty(previous) || isempty(current)
            previous=current;
            continue
        elseif all(current == '-')
            break
        end
    end
    start=nan(1,4);
    start(1)=strfind(previous,'Quantity');
    start(2)=strfind(previous,'Value');
    start(3)=strfind(previous,'Uncertainty');
    start(4)=strfind(previous,'Unit');    
    % read data
    entry=struct('Quantity','','Value',[],'Uncertainty',[],'Unit','');
    data=cell(0,4);
    while ~feof(fid)
        buffer=fgetl(fid);
        if isempty(strtrim(buffer))
            continue
        end
        temp=buffer(start(1):start(2)-1);
        entry.Quantity=strtrim(temp);
        temp=buffer(start(2):start(3)-1);
        temp=strrep(temp,' ','');
        temp=strrep(temp,'...','');
        entry.Value=sscanf(temp,'%g',1);
        temp=buffer(start(3):start(4)-1);
        temp=strrep(temp,' ','');
        if strcmpi(temp,'(exact)')
            entry.Uncertainty=nan;
        else
            entry.Uncertainty=sscanf(temp,'%g',1);
        end
        temp=buffer(start(4):end);
        entry.Unit=strtrim(temp);
        if isempty(data)
            data=entry;
        else
            data(end+1)=entry; %#ok<AGROW> 
        end
    end    
end

% manage input
if nargin() < 1
    varargin{1}='';    
end

% find matches
keep=false(size(data));
N=numel(varargin);
flag=false(1,N);
done=false();
for m=1:numel(data)
    flag(:)=false;
    for n=1:N        
        pattern=varargin{n};
        if startsWith(pattern,'$') && strcmpi(data(m).Quantity,pattern(2:end))
            keep(:)=false;
            keep(m)=true;
            done=true();
            break
        elseif isempty(pattern) || any(regexpi(data(m).Quantity,pattern))           
            flag(n)=true;
        elseif startsWith(pattern,'-')
            pattern=strrep(pattern,'-','');
            if ~any(regexpi(data(m).Quantity,pattern))
                flag(n)=true;
            end
        end
        if all(flag)
            keep(m)=true;            
        end
    end
    if done
        break
    end
end
report=data(keep);

% manage output
if nargout > 0
    varargout{1}=report;
    return
end

L=numel(report);
if L == 0
    fprintf('No matches found\n');
    return
end
temp=SLAM.Text.sprintPlural(L,'quantity','quantities');
fprintf('Found %s:\n\n',temp);
fprintf('%-60s%20s%20s%15s\n','Quantity','Value','Uncertainty','Units');
fprintf(repmat('-',[1 115]));
fprintf('\n')
format='%-60s%20.9g%#20.2g%15s\n';
for k=1:L
    fprintf(format,report(k).Quantity,report(k).Value,...
        report(k).Uncertainty,report(k).Unit);
end
fprintf('\n');

end