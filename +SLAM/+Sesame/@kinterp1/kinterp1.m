% Kerley interpolation class (1D)
%
% This class implements one-dimensional rational interpolation described by
% by G.I. Kerley in Los Alamos report LA-6903-MS.  Interpolation grid
% points are defined at object creation:
%    object=kinterp1(x,y);
% and stored for later use by the evaluate method.  This approach mimics
% the speed benefits of MATLAB's griddedInteropolant class versus the
% interp1 function.
%
% See also SLAM.Sesame
%
classdef kinterp1
    %%
    properties (SetAccess=protected)
        Grid   % Grid Interpolation grid (x)
        Data   % Data Interpolation data (y)
        Points % Points Number of grid points        
    end
    properties (SetAccess=protected)                      
        Parameter % Interpolation parameters [SL C1 C2]      
        IndexFcn  % IndexFcn Lookup function for left index
    end
    %% constructor
    methods (Hidden=true)
        function object=kinterp1(varargin)
            % manage input
            switch nargin()
                case 0
                    error('ERROR: insufficient input');
                case 1
                    y=varargin{1}(:);
                    x=1:numel(y);
                case 2
                    x=varargin{1}(:);
                    y=varargin{2}(:);
                otherwise
                    error('ERROR: too many inputs');
            end
            % error checking
            assert(isnumeric(x) && isreal(x) && all(isfinite(x)),...
                'ERROR: invalid x data');
            assert(isnumeric(y) && isreal(y) && all(isfinite(y)),...
                'ERROR: invalid y data');
            if isscalar(x)
                assert(x ~= 0,'ERROR: invalid horizontal step');
                x=(0:numel(y)-1)*x;
                x=x(:);
            else
                assert(numel(x) == numel(y),'ERROR: inconsistent data');
            end
            assert(all(diff(x) > 0) || all(diff(x) < 0),...
                'ERROR: x data must be monotonic');
            if (x(end) < x(1))
                x=x(end:-1:1);
                y=y(end:-1:1);
            end
            N=numel(x);
            assert(N >= 4,'ERROR: at least four points needed');
            x=x(:);
            y=y(:);
            % calculate interpolation parameters            
            Delta=diff(x);
            S=diff(y)./Delta;           
            C1=nan(N-1,1);
            C2=nan(N-1,1);
            C2(1)=(S(2)-S(1))/(Delta(2)+Delta(1));
            if S(1)*(S(1)-Delta(1)*C2(1)) < 0
                C2(1)=S(1)/Delta(1);
            end
            i=2:N-2;
            C1(i)=(S(i)-S(i-1))./(Delta(i)+Delta(i-1));
            if S(1)*(S(1)-Delta(1)*C1(2)) < 0
                C1(2)=(S(2)-2*S(1))/Delta(2);
            end
            C2(i)=(S(i+1)-S(i))./(Delta(i+1)+Delta(i));
            C1(N-1)=(S(N-1)-S(N-2))/(Delta(N-1)+Delta(N-2));            
            % store arrays            
            object.Points=N;
            object.Grid=x;
            object.Data=y;
            object.Parameter=[S C1 C2];            
            object.IndexFcn=griddedInterpolant(x,1:numel(x),'previous');
        end
    end
    %% static methods
    methods (Static=true)
        varargout=showExample1(varargin)
        varargout=showExample2(varargin)
        varargout=showExample3(varargin)

    end
end