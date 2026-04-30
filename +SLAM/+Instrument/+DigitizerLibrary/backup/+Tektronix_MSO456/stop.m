% stop digitizer acquisition
function stop(object)

communicate(object,':ACQUIRE:STATE OFF');

end