% arm digitizer for single acquisition
function arm(object)

communicate(object,':ACQUIRE:STOPAFTER SEQUENCE');
communicate(object,':ACQUIRE:STATE ON');

end