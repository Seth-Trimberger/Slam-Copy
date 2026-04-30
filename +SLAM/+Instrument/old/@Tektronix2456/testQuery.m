% testQuery Test digitizer with repeated queries
%
% This method tests the digitizer with repeated *IDN? queries. Results are
% returned as outputs:
%    [interval,total]=testQuery(object,iterations);
% or displayed in a new figure.
%    testQuery(object,iterations);
% Optional input "iterations" indicates the number of test queries
% performed; the default value is 10, and any number >= 2 may be specified.
% Output "interval" is an array of query times for each iteration, and
% "total" is the overall evaluation time.  Overall time is slightly longer
% than the sum of all iteration times.
%
% See also Tektronix456, connect
%
function varargout=testQuery(object,iterations)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(iterations)
    iterations=10;
else
    assert(isnumeric(iterations) && isscalar(iterations) && (iterations >= 2),...
        'ERROR: invalid number of iterations');
    iterations=ceil(iterations);
end

% perform test
t=zeros(1,iterations+1);
start=tic();
for n=1:iterations
    [~]=communicate(object);
    t(n+1)=toc(start);
end
t=diff(t);
total=toc(start);

% manage output
if nargout() > 0
    varargout{1}=t;
    varargout{2}=total;
    return
end

figure();
histogram(t);
label{1}=sprintf('Tested %d queries over %#.3g s',iterations,total);
label{end+1}=sprintf('Average = %#.3g s, median = %#.3g s, max = %#.3g s',...
    mean(t),median(t),max(t));
title(label);
xlabel('Query time (s)');
ylabel('Number of queries');

end