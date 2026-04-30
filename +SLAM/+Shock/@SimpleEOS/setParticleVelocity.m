% UNDER CONSTRUCTION
function setParticleVelocity(object,value)

assert(nargin() > 1,'ERROR: no particle velocity specified');
assert(isfinite(value),'ERROR: invalid particle velocity')

object.ParticleVelocity=value;

end