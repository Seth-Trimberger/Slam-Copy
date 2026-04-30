% setTermination Set termination impedance
%
% This function sets termination impedance values.
%    setTermination(object,value);
% Optional input "value" defines impedance in units of ohms.  The maximum
% value (1e6) is used when this input is empty/omitted.  Scalar values are
% replicated across all channels, e.g.:
%    setTermination(object,50);
% sets every channel to 50 ohm.  Mixed settings are specified from channel
% 1 onward, padding with the default value as needed. For example:
%    setTermination(object,[1e6 50]);
% explicitly sets channels 1-2 and implicitly uses the default termination
% for channels 3+.  Specifying more terminations than available channels
% generates a warning.
%
% See also getTermination
%
function setTermination(object,value)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
valid=object.Feature.Terminations;
default=max(valid);

% manage input
if (nargin() < 2) || isempty(value) || strcmpi(value,'high')
    value=default;
else
    assert(isnumeric(value),'ERROR: invalid termination');
    for n=1:numel(value)
        assert(any(value(n) == valid),'ERROR: invalid termination');
    end
end

channels=object.Feature.Channels;
N=numel(channels);
if isscalar(value)
    value=repmat(value,size(channels));
elseif numel(value) < N
    value(end+1:N)=default;
else
    warning('Tektronix456:extra','Extra values ignored');
    value=value(1:N);
end

for n=1:N
    communicate(object,':%s:TERMINATION %g',channels{n},value(n));
end

end