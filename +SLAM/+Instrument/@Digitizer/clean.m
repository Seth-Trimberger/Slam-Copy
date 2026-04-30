% UNDER CONSTRUCTION
%
% See also Digitizer
%
function clean(object)

previous=warning();
ID='transportlib:client:ReadWarning';
warning('off',ID);

for n=1:numel(object)
    dev=object(n).Device;
    delay=dev.Timeout;
    dev.Timeout=0.25;
    while true()
        result=read(dev,1);
        if isempty(result)
            break
        end
    end
    dev.Timeout=delay;
end

warning(previous);

end