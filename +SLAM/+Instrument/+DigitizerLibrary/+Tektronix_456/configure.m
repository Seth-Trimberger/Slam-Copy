% configure Configure Tektronix 456 digitizer
%
% This function determines the configuration of a Tektronix 4, 5, or 6
% series digitizer.  The command:
%    data=configure(object);
% attempts to match the Vendor property in "object" to a list of supported
% digitizer models.  If successful, the output "data" is a structure
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

models={'MSO44B' 'MSO46B' ...
    'MSO54B' 'MSO56B' 'MSO58B' 'MSO58LP' ...
    'MSO64B' 'MSO66B' 'MSO68B' 'LPD64'};
assert(any(strcmpi(object.Model,models)),...
    'ERROR: this library does not support model number %s',object.Model);

% bail out in query mode
if strcmpi(mode,'query')
    return
end

% define features
N=sscanf(object.Model(5),'%g',1);
channels=cell(1,N);
for n=1:N
    channels{n}=sprintf('CH%d',n);
    communicate(object,...
        ':CH%d:BANDWIDTH:FILTER:OPTIMIZATION STEPRESPONSE',n);
end
data.Channels=channels;

sources=channels;
sources{end+1}='AUXILIARY';
sources{end+1}='LINE';
data.Trigger.Sources=sources;
data.Trigger.Slopes={'RISE' 'FALL' 'EITHER'};

data.Divisions=[10 10];
data.Terminations=[50 1e6];
data.Couplings={'DC' 'AC'};
data.Modes={'SAMPLE' 'HIRES' 'AVERAGE'};

communicate(object,':HEADER ON; VERBOSE ON');
communicate(object,'HORIZONTAL:MODE MANUAL');
communicate(object,'HORizontal:MODE:RECORDLENGTH');

end