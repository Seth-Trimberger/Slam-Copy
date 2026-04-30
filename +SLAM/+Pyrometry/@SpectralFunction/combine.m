% combine Combine spectral functions
%
% This method combines spectral functions into a new object.
%    new=combine(object,src1,src2,...);
% Every element of "object" and each *scalar* source object is used to
% generate the output "new".  The resulting spectral function is a product
% of all source functions, collecting all unique waypoints along the way.
%
% NOTE: although an arbitrary number of spectral functions can be combined,
% no more than one of these can be a density function.  
%
% See also SpectralFunction, define, integrate, plot
%
function out=combine(object,varargin)

% manage input
M=numel(varargin);
waypoints=[];
factor={[]};
label={''};
density=[false()];
for m=1:M
    source=varargin{m};
    assert(isa(source,class(object(1))),...
        'ERROR: combine only works with spectral function objects');
    for k=1:numel(source)
        density(end+1)=source(k).IsDensity;        %#ok<AGROW>
        waypoints=[waypoints source(k).Waypoints]; %#ok<AGROW>
        factor{end+1}=source(k).Function;          %#ok<AGROW>
        label{end+1}=source(k).FunctionLabel;      %#ok<AGROW>
    end    
end

for n=1:numel(object)
    density(1)=object(n).IsDensity;
    assert(sum(density) < 2,...
        'ERROR: cannot combine multiple density functions');
    x=uniquetol([object(n).Waypoints waypoints],...
        object(n).Tolerance.Wavelength);
    factor{1}=object(n).Function;
    label{1}=object(n).FunctionLabel;
    new=feval(class(object(1)),@(x) combinedFcn(x,factor),x);
    if any(density)
        new.IsDensity=true();
        new.FunctionLabel=label{density};
    end
    if n == 1
        %out=new;
        out=repmat(new,size(object));
    else
        out(n)=new;
    end    
end
out=reshape(out,size(object));

end

function y=combinedFcn(x,factor)

y=factor{1}(x);
for kk=2:numel(factor)
    y=y.*factor{kk}(x);
end
end