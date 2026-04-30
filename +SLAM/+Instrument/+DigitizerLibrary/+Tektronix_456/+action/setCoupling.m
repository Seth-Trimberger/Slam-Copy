% setCoupling Set input coupling
%
% This function sets channel analog input coupling.
%    setCoupling(object,value);
% Optional input "value" indicates the desired coupling, defaulting to DC
% coupling when empty/omitted.  Individual values are broadcast to all
% channels:
%    setCoupling(object,'DC');
%    setCoupling(object,'AC');
% Mixed states can be specified with cellstr/string arrays, starting from
% channel 1 and padding with the default value ('DC') as needed.  Excess
% coupling values are ignored.
% 
% NOTE: AC coupling is not available when channels are terminated at 50
% ohms.
%
% See also getCoupling
%
function setCoupling(object,value) 

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

% manage input
default='DC';
if (nargin() < 2) || isempty(value)
    value=default;
elseif ischar(value)
    value={value};
else
    assert(isstring(value) || iscellstr(value),...
        'ERROR: invalid coupling mode');
end

channels=object.Feature.Channels;
N=numel(channels);
if isscalar(value)
    value=repmat(value,size(channels));
elseif numel(value) < N
    N0=numel(value);
    value{N}=default;
    for n=N0+1:N-1
        value{n}=default;
    end
else
    value=value(1:N);
end

% error checking
for n=1:numel(value)
    assert(any(strcmpi(value{n},object.Feature.Couplings)),...
        'ERROR: invalid coupling')
end

% send commands
for n=1:N
    communicate(object,':%s:COUPLING %s',channels{n},value{n});
end
        
end