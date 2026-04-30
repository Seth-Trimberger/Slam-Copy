% configure Configure Tektronix TDS70000 digitizer
%
% This function determines the configuration of a Tektronix TDS70000 series
% digitizer.  The command:
%    data=configure(object);
% attempts to match the Vendor property in "object" to a list of supported
% digitizer models.  If successful, the output "data" is a structure of
% core features for this product series.
% 
% If successful, the output "data" is a structure
% model-specific features.  A fast query mode:
%    configure(object,'query');
% performs a quick check to see if the digitizer model is supported
% without returning a feature structure.
% 
function data=configure(object,mode)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(mode) || strcmpi(mode,'normal')
    mode='normal';
elseif strcmpi(mode,'query')
    mode=lower(mode);
else
    error('ERROR: invalid configure mode');
end

% verify digitizer type
assert(strcmpi(object.Vendor,'Tektronix'),...
   'ERROR: "%s" is not a Tektronix digitizer',object.Name);

temp=sscanf(object.Model(4:end),'%g',1);
assert((temp >= 70e3) && (temp < 80e3),...
    'ERROR: this library does not support model number %s',object.Model);

% bail out in query mode
if strcmpi(mode,'query')
    return
end

% define features
N=4;
if endsWith(object.Model,'2SX')
    N=2;
end
channels=cell(1,N);
for n=1:N
    channels{n}=sprintf('CH%d',n);
end
data.Channels=channels;

sources=channels;
sources{end+1}='AUXILIARY';
sources{end+1}='LINE';
data.Trigger.Sources=sources;
data.Trigger.Slopes={'RISE' 'FALL' 'EITHER'};

data.Divisions=[10 10];
data.Terminations=[50]; %#ok<NBRAK2>
data.Couplings={'DC' 'GND'};
data.Modes={'SAMPLE' 'HIRES' 'AVERAGE'};

communicate(object,':HEADER ON; VERBOSE ON');

end