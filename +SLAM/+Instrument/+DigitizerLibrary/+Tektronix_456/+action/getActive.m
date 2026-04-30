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
for n=1:numel(channels)
    ID=channels{n};
    response=query(object,':DISPLAY:WAVEVIEW1:%s:STATE?;',ID);
    if logical(sscanf(response,'%g',1))
        keep(n)=true();
    end
end
result=channels(keep);

end