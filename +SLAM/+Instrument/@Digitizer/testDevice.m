% testDevice Test digitizer connection
%
% This methods tests the digitizer connection with *IDN? queries.  Timing
% results from that test are either returned as numeric array:
%    result=testDevice(object,iter);
% or plotted as a histogram.
%    testDevice(object,iter);
% Optional input "iter" indicates the number of test iterations to be
% performed, defaulting to 1.  Each operation typically takes 1-100 ms, so
% use caution before requesting a large number of iterations (e.g., one
% million iterations could take half an hour).
%
function varargout=testDevice(object,iter)

% manage input
if (nargin() < 2) || isempty(iter)
    iter=1;
else
    assert(isnumeric(iter) && isscalar(iter) && (all(iter >= 1)),...
        'ERROR: invalid number of test iterations');
    iter=ceil(iter);
end

% perform tests
time=zeros(1,iter+1);
start=tic();
for n=1:iter
    [~]=communicate(object,'*IDN?');
    time(n+1)=toc(start);
end
total=toc(start);
time=diff(time);

% manage output
if nargout() > 0
    varargout{1}=time;
else
    figure();
    histogram(time);
    label{1}=sprintf('%d test queries over %#.3g s',iter,total);
    label{end+1}=sprintf('Average = %#.3g s, median = %#.3g s, max = %#.3g s',...
        mean(time),median(time),max(time));
    title(label);
    xlabel('Query time (s)');
    ylabel('Number of queries');
end

end