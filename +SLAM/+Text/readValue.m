% readValue Read value/unit arguments
%
% This function reads a value/unit argument.
%    [number,unit]=readValue(argument);
% Mandatory input "argument" can be a numeric scalar, a character array, or
% a scalar string.  For numeric input, output "number" is equal to
% "argument" and "unit" is an empty character string.  Text arguments are
% scanned for number followed by an optional unit.  For example:
%    [number,unit]=readValue('10 GPa');
% returns outputs 10 and 'GPa'.  White space to the left and right of the
% unit is optional.
%
% See also SLAM.Text
%
function [number,unit]=readValue(argument)

assert(nargin() > 0,'ERROR: insuffient input');

unit='';
if isnumeric(argument)
    assert(isscalar(argument),'ERROR: cannot read multiple values');
    number=argument;
    return
end

try
    [number,~,~,next]=sscanf(argument,'%g',1);
catch
    error('ERROR: invalid input');
end

argument=argument(next:end);
if ~isempty(argument)
    unit=strtrim(argument);
end

end