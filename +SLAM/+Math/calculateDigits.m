% calculateDigits Determine integer digits
%
% This function determines the number of integer digits in a number.
%    value=calculateDigits(data)
% The output "value" indicates the maximum number of integer digits in
% numeric input array "data".  A warning is generated if non-integer values
% are found in "data".
%
% See also SLAM.Math
%
function value=calculateDigits(number)

% manage input
Narg=nargin();
assert(Narg > 0,'ERROR: insufficient input');
assert(isnumeric(number) && isreal(number) && all(isfinite(number)),...
    'ERROR: invalid input');

% calculation
number=abs(number);
if any(number ~= round(number))
    warning('digits:integers','Non-integer value detected');
end
number=max(round(number));

value=log10(number);
if value == ceil(value)
    value=value+1;
else
    value=ceil(value);
end

end