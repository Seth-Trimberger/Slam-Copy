% Thrifty Array Format file class
%
% This class supports Thrifty Array Format (*.taf) files, which combine a
% text header with binary data storage.  The original documentation of this
% format may be found in technical report SAND-2023-07387 available at
% https://doi.org/10.2172/2430696.  The current version (v1.1) is a minor
% variation of the original standard.  All essential features of the TAF
% format remain intact with the the following additions.
%    -Type codes are used to distinguish column, vector, and image arrays
%    from generic arrays.  Some methods in this class use the type code to
%    enforce certain behavior.
%    -Comments at the end of a TAF file prevent new elements from being
%    added to the array.  Data extension requires comments to be removed. 
%    -Scaled arrays also cannot be extended because doing so could force
%    the entire dataset to be remapped.
%
% Object construction requires an existing TAF file.
%    object=TAF(file);
% New files must be generated with the static create method.
%    object=TAF.create(data,file,...);
% File information is stored as object properties, and the file can be
% read/visualized/modified with object methods.
%
% See also SLAM.File
%
classdef TAF < SLAM.Developer.SimpleHandle
    properties (SetAccess=protected)
        Name      % File name
        Location  % Absolute file location        
    end
    %%
    properties (SetAccess=protected, Dependent=true)
        Info      % File information structure
    end
    methods
        function info=get.Info(object)     
            temp=dir(object.Target);
            if isempty(object.PreviousInfo) || ...
                    ~isequal(temp.datenum,object.PreviousInfo.datenum)
                try
                    probe(object);
                catch ME
                    throwAsCaller(ME);
                end
            end
            info=object.PreviousInfo;
        end
    end
    %%
    properties (SetAccess=protected)
        MemoryMap % File memory map
        ROI % Region of interest
    end
    %%
    properties (SetAccess=protected, Hidden=true)
        Target
        PreviousInfo
    end

    %% constructor
    methods (Hidden=true)
        function object=TAF(file)
            assert(isfile(file),'ERROR: file does not exist');
            [location,name,ext]=fileparts(file);
            assert(strcmpi(ext,'.taf'),'ERROR: invalid file extension');
            if isempty(location)
                location=pwd();
            end
            object.Location=location;
            object.Name=[name ext];
            object.Target=fullfile(object.Location,object.Name);
            try
                probe(object);
            catch ME
                error('ERROR: invalid TAF file');
            end
            setROI(object);
        end
        varargout=probe(varargin)
    end
    methods (Static=true)
        varargout=select(varargin)
        varargout=create(varargin)
        varargout=demonstrate(varargin)
        varargout=convertText(varargin)
        varargout=convertImage(varargin)
        varargout=convertTektronix(varargin)
        varargout=convertKeysight(varargin)
        %varargout=convertLecroy(varargin)
        %varargout=convertDIG(varargin)
    end
end