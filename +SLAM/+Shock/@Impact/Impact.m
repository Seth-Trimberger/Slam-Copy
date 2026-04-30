% UNDER CONSTRUCTION
classdef Impact < SLAM.Developer.SimpleHandle
    %%
    properties (SetAccess=protected)
        Flyer
        Sample
    end
    %% adjustable settings
    properties
        Points = 1000
        Pmax = 200 % GPa
        Tolerance = 1e-6
    end
    methods
        function set.Points(object,value)
            assert(isnumeric(value) && isscalar(value) && (value >= 3),...
                'ERROR: evalution points be a number >= 3');
            for n=1:numel(object)
                object.Points=ceil(value);
            end
        end
        function set.Pmax(object,value)
            assert(isnumeric(value) && isscalar(value) && (value > 0),...
                'ERROR: maximum pressure must be a number > 0');        
            for n=1:numel(object)
                object.Pmax=value;
            end
        end
        function set.Tolerance(object,value)
            assert(isnumeric(value) && isscalar(value) && (value > 0),...
                'ERROR: tolerance must be a number > 0');
            for n=1:numel(object)
                object.Tolerance=value;
            end
        end
    end
    %% user notes
    properties
        Notes
    end
    methods
        function set.Notes(object,value)
            if isstring(value)
                value=cellstr(value);
            end
            if iscellstr(value)
                value=char(value);
            else
                assert(ischar(value),'ERROR: invalid notes');
            end
            object.Notes=value;
        end
    end
    %%
    methods (Hidden=true)
        function object=Impact()
            temp=struct('Density',nan,'ShockFcn',[],'Anchor',0);
            object.Flyer=temp;
            object.Sample=temp;
        end
    end
    %%
    methods (Static=true)
        varargout=defineShockSpeed(varargin)
        varargout=lookupMaterial(varargin)
    end
end