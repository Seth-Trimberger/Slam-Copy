% checkStatus Check digitizer status
%
% This method checks digitizer status, which is either returned as a
% structure:
%    report=checkStatus(object);
% or printed in the command window.
%    checkStatus(object);
% Status information includes the arm state, acquisition mode, active
% channels, and the availability of signal data.
%
% See also Tektronix456, arm, clear, disarm, forceTrigger
%
function varargout=checkStatus(object)

report=struct();

temp=communicate(object,'ACQUIRE:STATE?');
switch temp
    case '1'
        switch lower(communicate(object,'ACQUIRE:STOPAFTER?'))
            case 'sequence'
                report.State='SINGLE';
            case 'runstop'
                report.State='RUN';
        end
    case '0'
        report.State='STOP';
end

report.Mode=communicate(object,'ACQUIRE:MODE?');

response=communicate(object,':DISPLAY:WAVEVIEW1:CH%d:STATE?; ',...
    1:object.Channels);
response=strrep(response,';',' ');
report.Active=find(sscanf(response,'%g'));
report.Active=reshape(report.Active,1,[]);

response=communicate(object,'DATA:SOURCE:AVAILABLE?');
if strcmpi(response,'none')
    report.Data=[];
else
    response=strrep(response,',',' ');
    response=strrep(response,'CH',' ');
    report.Data=sscanf(response,'%g');
    report.Data=reshape(report.Data,1,[]);
end

% manage output
if nargout() > 0
    varargout{1}=report;
    return
end

fprintf('Digitizer state is "%s" in "%s" mode\n',...
    report.State,report.Mode);

if isempty(report.Active)
    fprintf('No active channels\n');
else
    fprintf('Active channels: ');
    fprintf('%g ',report.Active);
    fprintf('\n');
end

if isempty(report.Data)
    fprintf('No data available \n');
else
    fprintf('Data on channels: ');
    fprintf('%g ',report.Data);
    fprintf('\n');
end

end