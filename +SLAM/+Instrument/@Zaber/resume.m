% resume Resume motion
%
% This method resumes motion requested by the last setPosition call.
%    resume(object);
% The only reason for using this method is when motion was terminated by
% the stop method.
% 
% See also Zaber, stop
%
function resume(object)

buffer=object.LastPositionRequest;
switch buffer
    case {'min' 'max'}
        setPosition(object,buffer)
    case ''
        return
    otherwise 
        [value,~,~,next]=sscanf(buffer,'%g',1);
        mode=strtrim(buffer(next:end));
        setPosition(object,value,mode);
end



end