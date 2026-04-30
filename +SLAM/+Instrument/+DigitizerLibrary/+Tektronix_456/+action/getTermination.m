% getTermination Get termination impedances
%
% This function gets input termination impedance values.
%    value=getTermination(object);
% Output "value" is a numeric array of impedances (one per channel) in
% ohms.
%
% See also setTermination
%
function value=getTermination(object)

communicate(object,':HEADER ON; VERBOSE ON');
channels=object.Feature.Channels;

N=numel(channels);
value=nan(1,N);
for n=1:N
    ID=channels{n};
    response=query(object,':%s:Termination?',ID);
    value(n)=sscanf(response,'%g',1);
end

end