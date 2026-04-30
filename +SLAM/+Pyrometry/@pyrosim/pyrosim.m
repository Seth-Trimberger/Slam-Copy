% Pyrometer simulation class
%
% This class simulates a single-band radiometer.  Simple estimates of
% integrated power, photon flux, and detector signal are generated based on
% collection diameter/angle, coupling efficiency, and responsivity for the
% specified source temperature and emissivity.  The operating principles of
% this calculation are described in links shown below.  The original
% implementation of pyrosim was a self-contained MATLAB function, which is
% now replaced by a handle subclass.
%
% Object creation involves no input arguments.
%    object=pyrosim();
% All adjustable values in the pyrometry calculation are managed as object
% properties.  For example:
%    object.Temperature=500:500:5000;
% sets the source temperature to be values from 500 K to 5000 K in 500 K
% increments.  The use of empty values:
%    object.Temperature=[];
% invokes the default state of that specific property at object creation.
% 
% Links:
% <a href="matlab:handy.grabFile('SLAM.Pyrometry.pyrosim','doc/theory.m')">Calculation theory</a>
% <a href="https://doi.org/10.2172/1038205">Technical report SAND2011-7778</a>
% 
classdef pyrosim < SLAM.Developer.SimpleHandle
    %% name
    properties
        % Name Pyrometer name
        %
        % This property is a character array, with automatic conversion of
        % scalar strings.  The initial value is based on the number of
        % objects that have already been created.
        %
        % See also pyrosim
        Name 
    end
    methods
        function set.Name(object,value)
            assert(ischar(value) || isStringScalar(value),...
                'ERROR: invalid name');
            object.Name=value;
        end
    end
    %% calculation parameters
    properties
        % Temperature Source temperature(s) in Kelvin
        %
        % This property is a numeric array of values greater than zero.
        % The values are automatically sorted so that temperature is
        % monotonically increasing.
        %
        % See also pyrosim
        Temperature 
        % Emissivity Source emissivity value or file
        %
        % This property is a numeric scalar (>= 0 and <= 1) or the name of
        % a two-column [wavelength emissivity] text file.
        %
        % See also pyrosim
        Emissivity  
        % Relay Coupling efficiency value or file
        %
        % This property is a numeric scalar (>= 0 and <= 1) or the name of
        % a two-column [wavelength relay] text file.
        %
        % See also pyrosim
        Relay       
        % Response Detector response in volts per watt
        %
        % This property is a numeric scalar or the name of a two-column
        % [wavelength responlse] text file.
        %
        % See also pyrosim
        Response    
        % Diameter Collection diameter in millimeters
        %
        % This property is a non-negative numeric scalar.
        %
        % See also pyrosim
        Diameter    
        % Angle Maximum collection angle in degrees   
        %
        % This property is a non-negative numeric scalar.
        %
        % See also pyrosim
        Angle       
        % Range Integration wavelength range [min max] in micrometers
        %
        % This property is a two-element numeric array, with automatic
        % value sorting.
        %
        % See also pyrosim
        Range       
        % Points Number of integration points
        %
        % This property is a positive integer with automatic rounding
        % (towards infinity).
        %
        % See also pyrosim
        Points      
    end
    methods
        function set.Temperature(object,value)           
            if isempty(value)
                value=1000:200:9000;
            end
           assert(isnumeric(value) && all(value > 0) ...
               && all(isfinite(value)),'ERROR: invalid temperature');

           object.Temperature=unique(value);
        end
        function set.Emissivity(object,value)
            if isempty(value)
                value=1;
            elseif isnumeric(value)
                assert(isscalar(value) && (value >=0) && (value <=1 ),...
                    'ERROR: invalid emissivity');
            else
                assert(ischar(value) || isStringScalar(value),...
                    'ERROR: invalid emissivity file');
            end
            object.Emissivity=value;
        end
        function set.Diameter(object,value)
            if isempty(value)
                value=1;
            end
            assert(isnumeric(value) && isscalar(value)...
                && (value >= 0) && isfinite(value),...
                'ERROR: invalid collection diameter');
            object.Diameter=value;
        end
        function set.Angle(object,value)
            if isempty(value)
                value=10;
            end
            assert(isnumeric(value) && isscalar(value)...
                && (value >= 0) && isfinite(value),...
                'ERROR: invalid max collection angle');
            object.Angle=value;
        end
        function set.Relay(object,value)
            if isempty(value)
                value=1;
            end
            if isnumeric(value)
                assert(isscalar(value) && (value >=0) && (value <=1 ),...
                    'ERROR: invalid relay efficiency');
            else
                assert(ischar(value) || isStringScalar(value),...
                    'ERROR: invalid relay file');
            end
            object.Relay=value;
        end
        function set.Response(object,value)
            if isempty(value)
                value=50;
            end
            if isnumeric(value)
                assert(isscalar(value),'ERROR: invalid response value');
            else
                assert(ischar(value) || isStringScalar(value),...
                    'ERROR: invalid response file');
            end
            object.Response=value;
        end        
        function set.Range(object,value)
            if isempty(value)
                value=[0.1 20];
            end
            assert(isnumeric(value) && numel(value)...
                && all(value > 0) && all(isfinite(value))...
                && (abs(diff(value)) > 0),...
                'ERROR: invalid wavelength range');
            object.Range=sort(value);
        end
        function set.Points(object,value)
            if isempty(value)
                value=1000;
            end
            assert(isnumeric(value) && isscalar(value) ...
                && (value >= 2) && isfinite(value),...
                'ERROR: invalid number of integration points');
            object.Points=ceil(value);
        end
    end
    %%
    methods (Hidden=true)
        function object=pyrosim()
            % manage naming
            persistent counter
            if isempty(counter)
                counter=1;
            else
                counter=counter+1;
            end
            object.Name=sprintf('Pyrometer #%d',counter);
            % invoke default settings
            object.Temperature=[];
            object.Emissivity=[];
            object.Relay=[];
            object.Response=[];
            object.Diameter=[];
            object.Angle=[];
            object.Range=[];
            object.Points=[];
        end
    end
end