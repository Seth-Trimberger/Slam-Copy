% UNDER CONSTRUCTION
function varargout=regrid(varargin)

x=varargin{1};
Narg=nargin();
for n=2:Narg
    assert(strcmp(class(varargin{n}),class(varargin{1})),...
        'ERROR: invalid input');
    x=[x; varargin{n}.Data(:,1)]; %#ok<AGROW>
end
xi=unique(x);

varargout=varargin;
for n=1:Narg
    x=varargout{n}.Data(:,1);
    y1=varargout{n}.Data(:,2);
    y2=varargout{n}.Data(:,3);
    y1i=interp1(x,y1,xi,'linear','nan');
    y2i=interp1(x,y2,xi,'linear','nan');
    varargout{n}.Data=[x y1i y2i];  
end

end