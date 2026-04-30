% generateBands Quickly define spectral bands
%
% This *static* method allows quick definition of multiple spectral bands.
%    object=generateBands(center,width,shape);
% Optional input "center" indicates the band locations being defined.
% Scalar values indicate a single band, while multiple values return an
% object array.  The default value is three bands: 500 nm, 1000 nm, and
% 1500 nm.  
%
% Optional input "width" indicates the characteristic spectral width of
% each band (50 nm default).  Scalar values are replicated across all
% bands, or band-specific values can be specified.  Optional input "shape"
% controls whether bands are 'square' (default) or 'gauss'.  
%
% NOTE: width value interpretation depends on the shape setting.  For
% square bands, these values are used as the full width.  Gaussian bands
% use these values as the standard deviation.
%
% See also SpectralFunction, define
%
function object=generateBands(center,width,shape)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(center)
    %center=transpose(400:200:1800);
    center=500:500:1500;
else
    assert(isnumeric(center) && all(isfinite(center)),...
        'ERROR: invalid center wavelength array');
    %center=sort(center(:));
end
N=numel(center);

if (Narg < 2) || isempty(width)
    width=repmat(50,[N 1]);
elseif isnumeric(width)
    assert(all(isfinite(width)) && all(width > 0),...
        'ERROR: invalid spectral width');
    if isscalar(width)
        width=repmat(width,[N 1]);
    else
        assert(numel(width) == N,...
            'ERROR: spectral width and center arrays must be consistent');
    end
else
    error('ERROR: invalid spectral width');
end

if (Narg < 3) || isempty(shape) || strcmpi(shape,'square')
    shape='square';
elseif strcmpi(shape,'gauss')
    shape='gauss';
else
    error('ERROR: invalid peak shape')
end

% create object array
persistent constructor
if isempty(constructor)
    constructor=handy.generateCall('SpectralFunction');
end
for n=1:N
    if strcmpi(shape,'square')
        left=center(n)-width(n);
        right=center(n)+width(n);
        new=constructor('-square',[left right]);
    elseif strcmpi(shape,'gauss')
        new=constructor('-gauss',[center(n) width(n)]);
    end
    new.Name=sprintf('Spectral band %d',n);
    if n == 1
        object=new;
    else
        object(end+1)=new; %#ok<AGROW> 
    end    
end

end