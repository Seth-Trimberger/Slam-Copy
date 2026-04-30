function choice=selectFiles(arg)

choice={};

if iscell(arg)
    [file,location]=uigetfile(arg,'Select files','','MultiSelect','on');
    if isnumeric(file)
        return
    end
    choice=file;
    if ischar(choice)
        choice={choice};
    end
    for n=1:numel(choice)
        choice{n}=fullfile(location,choice{n});
    end
elseif ischar(arg) || isStringScalar(arg)
    arg=char(arg);
    if ~contains(arg,'*')
        choice={arg};
        return
    end
    report=dir(arg);
    choice=cell(size(report));
    for n=1:numel(report)
        choice{n}=fullfile(report(n).folder,report(n).name);
    end
end

end