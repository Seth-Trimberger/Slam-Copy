% UNDER CONSTRUCTION
%
%
classdef kinterp2

    %%
    properties (SetAccess=protected, Dependent=true)
        Grid1
        Grid2
        Data
        Points % Points Number of grid points
    end
    methods
        
    end
    %%
    properties (SetAccess=protected)
        InterpolateRow
        InterpolateColumn
        IndexFcn
    end
    %% 
    methods (Hidden=true)
        function object=kinterp2(varargin)
            try
                object=build(object,varargin{:});
            catch ME
                throwAsCaller(ME);
            end

        end
    end    
    %%
    methods (Static=true)
        varargout=showExample1(varargin)
    end

end