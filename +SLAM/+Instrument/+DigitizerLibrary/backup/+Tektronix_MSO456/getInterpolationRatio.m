function value=getInterpolationRatio(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

response=communicate(dig,'HORizontal:MAIn:INTERPRatio?');
response=extractAfter(response,' ');
value=sscanf(response,'%g',1);

end