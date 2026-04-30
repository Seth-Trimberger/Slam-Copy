% extractContours Extract counter data
%
% This function generates contour data with contourc and extracts curves as
% a cell array.
%    [data,level]=extractContours(x,y,Z,level);
% The input arguments work in the same manner as contourc except that the
% 2D array "Z" is automatically transposed.  Each element of the output
% "data" is a two-column array of [x y] values.  The output "level" matches
% the input value *unless* the latter is scalar, in which case the former
% is an array of level values.
%
% See also contourc
%
function [data,level]=extractContours(varargin)

varargin{3}=transpose(varargin{3});
try
    Q=contourc(varargin{:});
catch ME
    throwAsCaller(ME);
end

data={};
level=[];
while ~isempty(Q)
    level(end+1)=Q(1,1); %#ok<AGROW>
    N=Q(2,1);
    data{end+1}=transpose(Q(:,2:N+1)); %#ok<AGROW>
    Q=Q(:,N+2:end);
end

end