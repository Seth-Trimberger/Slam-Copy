% getVerticalOffset Read vertical offsets
%
% This function reads vertical offsets for the analog channels
%    offset=getVerticalOffset(object);
% The output "offset" is a numeric array of voltage offsets with one
% element per channel.
%
% See also setVerticalOffset
%
function offset=getVerticalOffset(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

channels=object.Feature.Channels;
N=numel(channels);
offset=nan(size(channels));
for n=1:N
    response=query(object,':%s:OFFSET?',channels{n});
    offset(n)=sscanf(response,'%g');       
end

end