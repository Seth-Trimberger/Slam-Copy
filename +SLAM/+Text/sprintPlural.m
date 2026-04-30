% sprintPlural Print singular/plural number string
%
% This function prints an *integer* to a singular/plural number string.
%    out=sprintPlural(quantity,singular,plural);
% The input "quantity" should be non-negative integer; warnings are
% generated for negative and non-integer values.  The input "singular" is
% the (character) phrase printed after a quantity of one.  The output
% "plural" is the (character) phrase printed for quantities greater than
% one.  For example:
%    out=sprintPlural(N,'box','boxes');
% returns '1 box' when N=1 and '10 boxes' when N=10.  The plural phrase can
% be omitted when adding an s' to the singular phrase is sufficient. 
%    out=sprintPlural(N,'item'); % prints 'item' or 'items'
%
% See also SLAM.Text
%
function out=sprintPlural(quantity,singular,plural)

% manage input
assert(nargin >= 2,'ERROR: insufficient input');
assert(isnumeric(quantity) && isscalar(quantity),'ERROR: invalid number');

assert(ischar(singular),'ERROR: invalid singular label');

if (nargin < 3) || isempty(plural)
    plural=singular;
    plural(end+1)='s';
else
    assert(ischar(plural),'ERROR: invalid plural label');
end

% manage warnings
if quantity < 0
    warning('sprintPlural:negative','Negative number printed as zero');
end

if quantity ~= floor(quantity)
    warning('sprintfPlural:decimal','Non-integer number printed without decimals');
end

% print number string
if quantity == 1
    out=sprintf('1 %s',singular);
else
    out=sprintf('%d %s',quantity,plural);
end

end