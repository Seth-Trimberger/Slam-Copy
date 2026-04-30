% Spectral function class
%
% The class supports spectral function calculations.  These functions
% describe variations of a quantity with optical wavelength, which is
% defined in nanometer units.  These functions may describe a parameter
% that simply varies with wavelength (such as transmission or detector
% response) or the density of some physical quantity (value per nanometer).
% Both types of function are supported by this class with the following
% rules.
%    -Non-density functions can be combined (multiplied together) at any
%    time.
%    -One density function can be combined with any number of non-density
%    functions.
%    -Density functions *cannot* be combined because the result would
%    involve multiple integrations.  This class assumes that one
%    integration of a spectral function yields a scalar quantity.
%
% Spectral functions are created with parameters that are passed onto the
% define method.  For example:
%    object=SpectralFunction('-gauss',1000,50);
% creates a Gaussian peak centered at 1000 nm with a standard deviation of
% 50 nm.
% 
% See also SLAM.Pyrometry
%   
classdef SpectralFunction < SLAM.Developer.SimpleHandle
    %%
    properties 
        Name % Object name (character array)
    end
    methods
        function set.Name(object,value)
            if iscellstr(value) || isstring(value)
                value=char(value);
            end
            assert(ischar(value),'ERROR: invalid spectral function name');
            object.Name=value;
        end
    end
    %%
    properties (SetAccess=protected)
        Definition % Definition type (character array)
        Function   % Spectral function (function handle)
        Waypoints  % Important wavelengths (double array)
        Center     % Estimated center (double)
        Width      % Estimated width (double)
        SpectrumLabel = 'Wavelength (nm)' % Horizontal plot
    end
    %%
    properties
        FunctionLabel = 'Value (-)' % Vertical plot label
    end
    methods
        function set.FunctionLabel(object,value)
            if isStringScalar(value)
                value=char(value);
            end
            assert(ischar(value),'ERROR: invalid function label');
            object.FunctionLabel=value;
        end
    end
    %%
    properties
        IsDensity = false() % Indicates spectral density function (logical)
    end
    %%
    properties
        Tolerance % Tolerance structure
    end
    methods
        function set.Tolerance(object,value)
            if isempty(value)
                object.Tolerance=struct('Wavelength',1e-9,...
                    'Absolute',1e-10,'Relative',1e-6);
                return
            end
            assert(isstruct(value),'ERROR: invalid tolerance structure');
            name={'Wavelength' 'Absolute' 'Relative'};
            for n=1:numel(name)
                assert(isfield(value,name{n}),...
                    'ERROR: invalid tolerance structure');               
                temp=value.(name{n});
                assert(isnumeric(temp) && isscalar(temp) && (temp > 0),...
                    'ERROR: invalid %s tolerance',name{n});
            end
        end        
    end
    %%
    methods (Hidden=true)
        function object=SpectralFunction(varargin)
            persistent counter
            if isempty(counter)
                counter=1;
            end
            object.Name=sprintf('Function %d',counter);
            counter=counter+1;
            object.Tolerance=[];
            try
                define(object,varargin{:});
            catch ME
                throwAsCaller(ME);
            end
        end
    end
    methods (Static=true)
        varargout=generateBands(varargin)       
    end
end