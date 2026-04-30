% getActive Get active channels
%
% This function determines which digitizer channels are active.
%    result=getActive(object);
% The output "result" is a cellstr array of active channel labels, such as
% {'CH1' 'CH2'}.  An empty cell array is returned when no channels are
% active.
%
% See also setActive
%
function result=getActive(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

channels=object.Feature.Channels;
keep=false(size(channels));
response=communicate(object,'SELECT?');
for n=1:numel(channels)
    temp=extractAfter(response,channels{n});
    keep(n)=logical(sscanf(temp,'%g',1));
end

result=channels(keep);

end