% SimpleHandle Simplified handle class
%
% The class provides a simplified version of MATLAB's handle class, hiding
% extraneous methods from the casual user.  Capbilities from the handle
% class (addlistener, findobj, etc.) are still available but do not show up
% in the class documentation.  This reduces the cognitive burden for end
% users, focusing attention on important class methods without distraction.
%
% Like the abstract handle superclass, SimpleHandle objects cannot be
% instantiated directly.  Concrete subclasses *can* be built from
% SimpleHandle.
%
% See also SLAM.Developer
%
classdef (Abstract=true) SimpleHandle < handle
    methods (Hidden=true)
        function object=SimpleHandle(varargin)
        end
        %% hide extraneous methods from handle class
        function result=addlistener(varargin)
            result=addlistener@handle(varargin{:});
        end
        function delete(varargin)
           delete@handle(varargin{:}); 
        end
        function result=eq(varargin)     
            result=eq@handle(varargin{:});
        end
        function result=findobj(varargin)
            result=findobj@handle(varargin{:});
        end
        function result=findprop(varargin)
            result=findprop@handle(varargin{:});
        end
        function result=ge(varargin)
            result=ge@handle(varargin{:});
        end
        function result=gt(varargin)
            result=gt@handle(varargin{:});
        end
        function result=le(varargin)
            result=le@handle(varargin{:});
        end
        function result=lt(varargin)
            result=lt@handle(varargin{:});
        end
        function result=listener(varargin)
            result=listener@handle(varargin{:});
        end
        function result=ne(varargin)
            result=ne@handle(varargin{:});
        end
        function result=notify(varargin)
            result=notify@handle(varargin{:});
        end        
    end   
end