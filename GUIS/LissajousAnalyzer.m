classdef LissajousAnalyzer
% LissajousAnalyzer  Pure math class for VISAR Lissajous pattern analysis.
%
% Takes raw oscilloscope trace arrays, performs background subtraction,
% computes Lissajous XY points, and calculates fringe contrast.
% Zero hardware dependencies -- usable in any interferometry context.
%
% Constants derived from EvaluateLis() in AlignCtrl.c:
%   ppT          = 250   points per DDG period (5 pts/us * 50 us)
%   avePreStart  = 7     first pre-pulse background point index
%   avePostStart = 162   first post-pulse background point index
%   aveBkN       = 95    number of background points on each side
%   aveSigN      = 42    number of signal points to average over pulse
%   pulseStart   = 112   index of laser-on pulse start within period
%
% Usage:
%   la = LissajousAnalyzer();
%   [lisX, lisY, npulse] = la.Evaluate(traceData, detectorPolarity);
%   contrast = la.ComputeContrast(lisX, lisY);

    properties (Constant)
        % Points per DDG period: 5 pts/us * 50 us period
        ppT          = 250;

        % Background averaging window -- pre-pulse side
        avePreStart  = 7;

        % Background averaging window -- post-pulse side
        avePostStart = 162;

        % Number of background points averaged on each side of the pulse
        aveBkN       = 95;

        % Number of signal points averaged over the laser-on pulse
        aveSigN      = 42;

        % Index of the start of the laser-on pulse within each period
        pulseStart   = 112;
    end

    methods

        function [lisX, lisY, npulse] = Evaluate(obj, traceData, detectorPolarity)
        % Evaluate  Analyze raw scope traces and produce Lissajous XY points.
        %
        % For each laser pulse in the trace, this function:
        %   1. Averages pre- and post-pulse background on both channels
        %   2. Averages the signal over the laser-on window
        %   3. Subtracts background from signal, applies detector polarity
        %
        % Inputs:
        %   traceData         Nx2 or Nx4 double array of raw scope samples.
        %                     Columns are [CH1, CH2] or [CH1, CH2, CH3, CH4].
        %                     Values should be raw ADC counts (integers).
        %   detectorPolarity  Scalar: +1 or -1 depending on detector wiring.
        %                     From resp[sn].polarity in the legacy C code.
        %
        % Outputs:
        %   lisX    npulse-length column vector of background-subtracted
        %           X channel values (CH1 or CH3), polarity-corrected.
        %   lisY    npulse-length column vector of background-subtracted
        %           Y channel values (CH2 or CH4), polarity-corrected.
        %   npulse  Number of complete pulses found in the trace.
        %
        % Note: This method analyzes the FIRST channel pair (columns 1 & 2).
        %       Call Evaluate again with traceData(:,3:4) for the second pair.

            narginchk(3, 3);

            npts   = size(traceData, 1);
            chX    = traceData(:, 1);
            chY    = traceData(:, 2);

            % Compute number of complete pulses, leaving 2 periods at the
            % end to avoid partial pulses (matches C: npts/ppT - 2)
            npulse = floor(npts / obj.ppT) - 2;

            if npulse < 1
                error('LissajousAnalyzer:InsufficientData', ...
                      'Trace has %d points -- need at least %d for one pulse.', ...
                      npts, 3 * obj.ppT);
            end

            lisX = zeros(npulse, 1);
            lisY = zeros(npulse, 1);

            for i = 1:npulse
                periodStart = (i - 1) * obj.ppT;   % 0-based offset into trace

                % --- Background: pre-pulse window ---
                preIdx  = periodStart + obj.avePreStart  + (1:obj.aveBkN);

                % --- Background: post-pulse window ---
                postIdx = periodStart + obj.avePostStart + (1:obj.aveBkN);

                % Average both background windows together (matches C: sum both sides / 2*aveBkN)
                bkgX = mean([chX(preIdx); chX(postIdx)]);
                bkgY = mean([chY(preIdx); chY(postIdx)]);

                % --- Signal: laser-on pulse window ---
                sigIdx = periodStart + obj.pulseStart + (1:obj.aveSigN);

                sigX = mean(chX(sigIdx));
                sigY = mean(chY(sigIdx));

                % Background-subtracted, polarity-corrected Lissajous point
                lisX(i) = (sigX - bkgX) * detectorPolarity;
                lisY(i) = (sigY - bkgY) * detectorPolarity;
            end

            fprintf('LissajousAnalyzer: evaluated %d pulses from %d trace points.\n', ...
                    npulse, npts);
        end

        function [lisX, lisY] = SubtractBackground(obj, traceData, detectorPolarity)
        % SubtractBackground  Convenience wrapper that returns only the
        % background-subtracted Lissajous arrays (no npulse output).
        %
        % Inputs/outputs match Evaluate() -- see that method for full docs.

            [lisX, lisY, ~] = obj.Evaluate(traceData, detectorPolarity);
        end

        function contrast = ComputeContrast(obj, lisX, lisY)
        % ComputeContrast  Compute fringe contrast from Lissajous XY data.
        %
        % Implements the Yoshi contrast metric from LisCB() in AlignCtrl.c:
        %   For each channel, contrast = (max - min) / (max + min)
        %   where max/min are taken of the intensity-normalized channel signal.
        %   The overall contrast is the mean across all four channels (or two).
        %
        % Inputs:
        %   lisX   npulse-length vector of X Lissajous coordinates.
        %   lisY   npulse-length vector of Y Lissajous coordinates.
        %
        % Output:
        %   contrast  Scalar fringe contrast value in [0, 1].
        %             Values near 1 indicate good alignment.
        %
        % Note: The legacy code normalizes each channel by the sum of all
        %       four channels (beam intensity monitor).  With only two channels
        %       available here, we normalize by lisX + lisY (total intensity).

            narginchk(3, 3);

            if isempty(lisX) || isempty(lisY)
                contrast = 0;
                fprintf('LissajousAnalyzer: empty Lissajous data -- contrast = 0.\n');
                return;
            end

            totalIntensity = lisX + lisY;

            % Guard against division by zero (dark frames or disconnected detectors)
            validMask = totalIntensity ~= 0;
            if ~any(validMask)
                contrast = 0;
                fprintf('LissajousAnalyzer: all intensity values zero -- contrast = 0.\n');
                return;
            end

            normX = zeros(size(lisX));
            normY = zeros(size(lisY));
            normX(validMask) = lisX(validMask) ./ totalIntensity(validMask);
            normY(validMask) = lisY(validMask) ./ totalIntensity(validMask);

            % Per-channel contrast: (max - min) / (max + min)
            cX = obj.ChannelContrast(normX);
            cY = obj.ChannelContrast(normY);

            % Average across channels (legacy code averages 4; we average 2)
            contrast = (cX + cY) / 2;

            fprintf('LissajousAnalyzer: contrast = %.4f  (X=%.4f, Y=%.4f)\n', ...
                    contrast, cX, cY);
        end

    end % public methods

    methods (Access = private)

        function c = ChannelContrast(~, normVec)
        % ChannelContrast  Compute (max-min)/(max+min) for a normalized channel.
            hi = max(normVec);
            lo = min(normVec);
            denom = hi + lo;
            if denom == 0
                c = 0;
            else
                c = (hi - lo) / denom;
            end
        end

    end % private methods

end % classdef