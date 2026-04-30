% Institute for Shock Physics data file class
%
% This class supports Institute for Shock Physics (*.isp) data files.
% These files store MATLAB variables as distinct records within a binary
% file, associating character names with each record clear organization.
% Records may be written to the file, read from the file, revised, and
% renamed based on user needs.  Behind the scenes, these files use version
% 7.3 of the builtin MAT file format, which itself based on HDF5.  
%
% Object creation requires specification of a file name.
%    object=ISPfile(name);
% The requested "name" can specify an existing new file.  When no file is
% requested, the default file "demonstration.isp" is used.  Interactive
% file specification is provided by the static select and create methods.
%
% See also SLAM.File
%
classdef ISPfile
    properties (SetAccess=protected)
        Name % File name
        Location % File location 
    end
    properties (SetAccess=protected, Hidden=true)
        File
        Matfile
    end
    %%
    properties (SetAccess=protected, Dependent=true)
        Size % File size (in bytes)
    end
    methods
        function value=get.Size(object)
            info=dir(object.File);
            value=info.bytes;
        end
    end
    %%
    properties
        Overwrite = 'off' % Overwrite permission ('off' or 'on');
    end
    methods
        function set.Overwrite(object,value)
            if any(strcmpi(value,{'on' 'off'}))
                object.Overwrite=lower(value);
            else
                error('ERROR: overwrite must be ''on'' or ''off''');
            end
        end
    end
    %%
    methods (Hidden=true)
        function object=ISPfile(file)
            persistent ISPformat
            if isempty(ISPformat)
                location=fileparts(mfilename("fullpath"));
                src=fullfile(location,'format.txt');
                fid=fopen(src,'r');
                ISPformat=fread(fid,inf,'*char');
                ISPformat=reshape(ISPformat,1,[]);
                fclose(fid);
            end
            Narg=nargin();
            if (Narg < 1) || isempty(file)
                file='demonstration.isp';
                fprintf('Defaulting to "%s" file\n',file);
            end
            [~,short,ext]=fileparts(file);
            if isempty(ext)
                ext='.isp';
            end
            assert(strcmpi(ext,'.isp'),'ERROR: invalid file extension');            
            temp=dir(file);
            location=temp.folder;          
            object.Name=[short ext];
            object.Location=location;
            object.File=fullfile(object.Location,object.Name);
            if ~isfile(file) % create new file                
                save(object.File,'-mat','-v7.3','ISPformat');
            else  % verify file
                try
                    buffer=char(h5read(object.File,'/ISPformat'));
                    assert(strcmp(buffer,ISPformat));
                catch ME
                    error('ERROR: invalid ISP file');
                end                
            end
            object.Matfile=matfile(object.File,'Writable',true());            
        end
    end
    %%
    methods (Static=true)
        varargout=create(varargin)
        varargout=select(varargin)
        varargout=demonstrate(varargin)
    end
end