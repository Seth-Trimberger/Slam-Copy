function [acquire,complete]=getState(object)

temp=communicate(object,':ACQUIRE:STATE?');
if strcmp(temp,'0')
    acquire='stop';
else
    acquire='arm';
end

temp=communicate(object,':ACQUIRE:SEQUENCE:CURRENT?');
complete=logical(sscanf(temp,'%g'));

end