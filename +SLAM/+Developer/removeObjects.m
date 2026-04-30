% removeObjects Recursive object removal
%
% This function converts all objects in a variable to structures.
%    new=removeObjects(original);
% The output "new" replicates the input "original" without the use MATLAB
% objects.  Any element, property, or field of "original" that contains
% an object is replaced by a structure with all public information from
% that object.  This means that object arrays are converted to structure
% arrays, cell arrays containing objects are converted to cell arrays of
% structures, and sub-objects (fields/properties that are themselves
% objects) become sub-structures.
% 
% Recursive conversion is subject to several limitations.
%    -Only public properties are converted.
%    -Graphic and Java handles are *not* transferred, leaving an empty
%    array in its place.  This is done to avoid infinite parent-child
%    links.
%    -Character conversion is attempted for objects having no public
%    properties, such as enumerations. 
% An empty array is used as a placeholder for omitted handles and
% unsuccessful character conversions.
%
function result=removeObjects(source)

result=convert(source);
    function out=convert(in)
        if iscell(in)
            out=cell(size(in));
            for n=1:numel(in)
                out{n}=convert(in{n});
            end
            return
        end
        try
            name=fieldnames(in);
        catch
            out=in;
            return
        end
        out=repmat(struct(),size(in));
        for m=1:numel(in)
            for n=1:numel(name)
                out(m).(name{n})=[];
                value=in(m).(name{n});
                if isobject(value)
                    if any(ishandle(value))
                        continue
                    end
                    new=convert(value);
                    if isempty(fieldnames(new))
                        try %#ok<TRYNC>
                            new=char(value);
                        end
                    end
                else
                    new=value;
                end
                out(m).(name{n})=new;
            end
        end
    end

end