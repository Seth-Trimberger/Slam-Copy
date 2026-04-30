% getBandwidth Get analog bandwidth
% 
% This function gets the current analog bandwidth.
%   BW=getBandwidth(object);
% The output "BW" is a numeric array with one element per input channel. 
%
% See also setBandwidth
%
function bandwidth=getBandwidth(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');
channels=object.Feature.Channels;

N=numel(channels);
bandwidth=nan(size(channels));
for n=1:N
    response=query(object,':%s:BANDWIDTH:ACTUAL?',channels{n});
    bandwidth(n)=sscanf(response,'%g',1);
end

end