% Sesame file class
%
% This class supports Sesame tables using Los Alamos's ASCII (version 2.0)
% file format as described in report LA-UR-19-24891.  A source file can be
% specified at object creation:
%    object=File(file);
% or selected interactively.
%    object=File();
% The file is immediately scanned, which may take some time based on number
% of materials/tables defined and the size of each.  Subsequent operations
% are based on that initial scan and are generally much faster.
%
% See also SLAM.Sesame, EOS
%
classdef File < SLAM.Developer.SimpleHandle
    properties (SetAccess=protected)
        Name      % Name Sesame file name
        Location  % Location Sesame file location
        Data      % Data Tabular data structure
        Materials % Material List of defined material numbers
    end
    %% constructor   
    methods (Hidden=true)
        function object=File(name)          
            Narg=nargin();
            if (Narg < 1) || isempty(name)
                [name,location]=uigetfile(...
                    {'*.ascii2' 'All files'},'Select Sesame ASCII2 file');
                assert(~isnumeric(name),'ERROR: no file selected');
                object.Name=name;
                object.Location=location;
            else
                assert(isfile(name),...
                    'ERROR: requested file does not exist');
                [location,name,ext]=fileparts(name);
                assert(strcmpi(ext,'.ascii2'),...
                    'ERROR: invalid file format'); 
                object.Name=[name ext];
                object.Location=location;
            end
            try
                fid=fopen(fullfile(object.Location,object.Name),'r');               
                buffer=strtrim(fgetl(fid));
                fclose(fid);
                assert(strcmp(buffer,'Version 2.0'),'');
            catch
                error('ERROR: invalid file format');
            end
            try
                fprintf('Scanning file...');
                scan(object);
                fprintf('done\n');
            catch
                error('ERROR: unable to scan SESAME file');
            end
            M=numel(object.Data);
            object.Materials=nan(1,M);
            for m=1:M
                object.Materials(m)=object.Data(m).Material;
            end
        end
    end
    %%
    methods (Hidden=true)
        varargout=scan(varargin)
        varargout=searchComments(varargin)
        varargout=searchTables(varargin)
    end
end