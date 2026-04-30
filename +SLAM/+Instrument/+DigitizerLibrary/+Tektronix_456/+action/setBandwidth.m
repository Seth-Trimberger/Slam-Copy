% setBandwidth Set analog bandwidth
%
% This function sets the current analog bandwidth
%    setBandwidth(object,value);
% Optional input "value" specifies the requested bandwidth in Hertz,
% defaulting to the maximum supported value when empty/omitted.  Scalar
% values are replicated across all channels, e.g.:
%    setBandwidth(object,500e6);
% Mixed settings are defined from channel 1 onward, defaulting to the
% maximum bandwidth as needed.  Excess bandwidths are ignored.
%
% NOTE: bandwidth limits may be determined by the number of active
% channels and input coupling/termination.
%
% See also getBandwidth
%
function setBandwidth(object,value) 

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

% manage input
if (nargin() < 2) || isempty(value) || strcmpi(value,'full')
    value=inf();
else
    assert(isnumeric(value),'ERROR: invalid bandwidth value');
end

channels=object.Feature.Channels;
N=numel(channels);
if isscalar(value)
    value=repmat(value,size(channels));
elseif numel(value) < N
    value(end+1:N)=inf();
else
    value=value(1:N);
end

% send commands
for n=1:N
    if isfinite(value(n))
        communicate(object,':%s:BANDWIDTH %g',channels{n},value(n));
    else
        communicate(object,':%s:BANDWIDTH FULL',channels{n});
    end
end

end