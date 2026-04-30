% getCoupling Get input coupling mode
%
% This function gets the current input coupling mode.
%    mode=getCoupling(object);
% The ouput "mode" is a cellstr array with elements of 'DC' and/or 'AC'.
%
% See also setCoupling
%
function value=getCoupling(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');
channels=object.Feature.Channels;

N=numel(channels);
value=cell(1,N);
for n=1:N
    value{n}=query(object,':%s:Coupling?',channels{n});
end

end