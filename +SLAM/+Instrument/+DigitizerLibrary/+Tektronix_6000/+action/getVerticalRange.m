% getVerticalRange Read vertical ranges
%
% This function reads the vertical range for all analog channels.
%    range=getVerticalRange(object);
% The output "range" is a two-column array of min/max values in volts.
%
% See also setVerticalRange
%
function span=getVerticalRange(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

channels=object.Feature.Channels;
N=numel(channels);
span=nan(N,2);
for n=1:N
    buffer=communicate(object,':%s:OFFSET?; POSITION?; SCALE?',...
        channels{n});
    temp=extractAfter(buffer,'OFFSET');
    offset=sscanf(temp,'%g',1);
    temp=extractAfter(buffer,'POSITION');
    position=sscanf(temp,'%g',1);
    temp=extractAfter(buffer,'SCALE');
    scale=sscanf(temp,'%g',1);
    span(n,:)=([-1 +1]/2*object.Feature.Divisions(2)-position)*scale...
        +offset;
end

end