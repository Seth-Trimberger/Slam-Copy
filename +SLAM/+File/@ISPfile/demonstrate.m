% demonstrate Generate example ISP file
%
% This *static* method generates an ISP file with several data records.
% The base command:
%    ISPfile.demonstrate();
% creates the file 'demonstration.isp' in the current directory.
% Requesting an output:
%    object=ISPfile.demonstrate();
% creates the file and returns an object linked to that file.
%
% See also ISPfile
%
function varargout=demonstrate()

persistent constructor
if isempty(constructor)
    constructor=handy.generateCall('ISPfile');
end

file='demonstrate.isp';
if isfile(file)
    delete(file)
end

object=constructor(file);

time=0:(1/10):10;
time=time(:);
write(object,time,'Time');
signal=cospi(2*time);
write(object,signal,'Cosine');
data=[time signal];
write(object,data,'TwoColumns');
data=struct('Time',time,'Signal',signal);
write(object,data,'Structure');

x=linspace(-3,+3,100);
y=x;
[x,y]=meshgrid(x,y);
z=exp(-x.^2/2-y.^2/(2*0.5^2));
write(object,z,'Image');

% manage output
if nargout() > 0
    varargout{1}=object;
end

end