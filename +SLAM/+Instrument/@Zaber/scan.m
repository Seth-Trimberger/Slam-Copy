% scan Scan for Zaber devices
%
% This *static* methdod scans for Zaber device connections.
%    object=Zaber.scan();
% The output "object" is an array of Zaber devices.
%
% See also Zaber
%
function object=scan()

list=serialportlist();
if isempty(list)
    fprintf('No devices found\n');
    return
end

object=[];
for n=1:numel(list)
   try
       new=SLAM.Instrument.Zaber(list{n});
   catch
       continue
   end
   if isempty(object)
       object=new;
   else
       object(end+1)=new;
   end
end

if isempty(object)
        fprintf('No devices found\n');
end

end