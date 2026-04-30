% hilbert Calculate Hilbert transform
%
% This function calculates the Hilbert transform of uniformly sampled input
% signal.
%    z=hilbert(s);
% Optional input "s" must be a numeric array, defaulting to a simple
% Gaussian peak when empty or omitted.  The output "z" is a complex-valued
% array contained the analytic representation of "s".  Apart from a DC
% offset, the real component of "z" matches "s" within numerical precision.
% The real and imaginary parts of "z" form a quadrature pair.  Omitting
% the output request:
%    hilbert(s);
% plots the analytic signal in a new figure..
% 
% Ideally, the input signal should be symmetric at the boundaries, i.e. the
% first/last values are either the same or form a continuous slope.  For
% best results, the signal should have zero value and slope at the
% boundaries.  When these conditions are not met, the imaginary component
% of "z" may ring at the edges.
%
% See also SLAM.Math
%
function varargout=hilbert(in)


% manage input
Narg=nargin();
if (Narg < 1) || isempty(in)
    t=linspace(-5,5,1000);
    in=exp(-t.^2/2/0.1^2);
else
    assert(isnumeric(in),'ERROR: invalid input');    
end
shape=size(in);
in=in(:);

% calculation
N=numel(in);
N2=pow2(nextpow2(N));
fn=(-N2/2):(N2/2-1);
fn=(fn(:))/N2;
fn=ifftshift(fn,1);

transform=fft(in,N2);
profile=zeros(size(fn));
profile(fn > 0)=+1;
profile(fn < 0)=-1;

S1=transform.*abs(profile);
out1=ifft(S1,'symmetric');
out1=real(out1(1:N));

S2=transform.*(-1i*profile);
out2=ifft(S2,'symmetric');
out2=real(out2(1:N));

out=out1+1i*out2;
out=reshape(out,shape);

% manage output
if nargout() > 0
    varargout{1}=out;
    return
end

figure();
tn=1:N;
plot(tn,out1,tn,out2);
xlabel('Index');
ylabel('Valuel');
legend('Real','Imaginary','Location','best');

end