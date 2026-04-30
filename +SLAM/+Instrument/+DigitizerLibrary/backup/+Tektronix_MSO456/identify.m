function report=identify(object)

assert(contains(object.Vendor,'tektronix','IgnoreCase',true()),...
    'ERROR: "%s" is not a Tektronix digitizer');
valid={'MSO44B' 'MSO46B' ...
    'MSO54B' 'MSO56B' 'MSO58B' 'MSO58LP' ...
    'MSO64B' 'MSO66B' 'MSO68B' 'LPD64'};
assert(any(strcmpi(object.Model,valid)),'ERROR: unsupported model number');

N=sscanf(object.Model(5),'%g',1);
report.Channels=cell(1,N);
for n=1:N
    report.Channels{n}=sprintf('CH%d',n);
    communicate(object,...
        ':CH%d:BANDWIDTH:FILTER:OPTIMIZATION STEPRESPONSE',n);
end
sources=report.Channels;
sources{end+1}='AUXILIARY';
sources{end+1}='LINE';
report.Triggers.Sources=sources;
report.Triggers.Slopes={'RISE' 'FALL' 'EITHER'};
report.Divisions=[10 10];
report.Terminations=[1 1e6];
report.Couplings={'AC' 'DC'};
report.Modes={'SAMPLE' 'HIRES' 'AVERAGE'};

communicate(object,':HEADER OFF; VERBOSE ON');
communicate(object,'HORIZONTAL:MODE MANUAL');
communicate(object,'HORizontal:MODE:RECORDLENGTH');

end