classdef DataManager
% DataManager  Handles all VISAR data saving: scope traces, Lissajous data,
%              and shot metadata. No hardware or GUI dependencies.
%
% This class is the MATLAB equivalent of the legacy DataSave.c functions:
%   SaveDataTextformat()  ->  SaveShotData() / SaveTextFormat()
%   SaveLis()             ->  SaveLissajous() / SaveTextFormat()
%   SaveDataVSRformat()   ->  SaveMatFormat()  (legacy .vsr was never
%                             fully implemented; .mat is the primary
%                             binary format here)
%
% The ShotInfo.txt persistence (loading/saving default header values
% across sessions) is also handled here via LoadShotInfo() / SaveShotInfo().
%
% Reusability note: The metadata struct layout and file format conventions
% are general enough to be reused by any future multi-channel interferometry
% or diagnostic shot system.
%
% Usage example:
%   dm   = DataManager();
%   meta = DataManager.BuildMetadata( ...
%              'Shot001', 'Al-target', 'LiF-etalon', 'S.Trimberger', ...
%              1.234, 0.567, 0.891, false, nScopes);
%   dm.SaveShotData(traces, meta, 'C:\Data\Shot001.txt');
%   dm.SaveLissajous(lisData, meta, 'C:\Data\Shot001.lis');
%   dm.SaveMatFormat(traces, lisData, meta, 'C:\Data\Shot001.mat');

    % ------------------------------------------------------------------ %
    properties (Constant)
        % Default file for persisting shot header values between sessions
        % (mirrors the legacy ShotInfo.txt mechanism in DataSaveDoneCB)
        ShotInfoFile = 'ShotInfo.txt';
    end

    % ------------------------------------------------------------------ %
    methods (Static)

        % ---------------------------------------------------------- %
        function meta = BuildMetadata(shotLabel, targetLabel, ...
                etalonLabel, operatorName, ...
                PZTleg, ETAleg, ETAleg2, ...
                isMultiPoint, nScopes)
        % BuildMetadata  Construct a standard shot metadata struct.
        %
        %   meta = DataManager.BuildMetadata(shotLabel, targetLabel, ...
        %              etalonLabel, operatorName, PZTleg, ETAleg, ETAleg2, ...
        %              isMultiPoint, nScopes)
        %
        % Inputs
        %   shotLabel    - char  Shot identifier string
        %   targetLabel  - char  Target material/description
        %   etalonLabel  - char  Etalon description
        %   operatorName - char  Operator name
        %   PZTleg       - float PZT leg VPF (mm/s/fringe)
        %   ETAleg       - float Etalon leg VPF
        %   ETAleg2      - float Second etalon leg VPF (dual VISAR)
        %   isMultiPoint - logical  true = multi-point, false = single-point
        %   nScopes      - int   Number of scopes used
        %
        % The per-scope fields (timeScale, vScale, etc.) are left empty
        % here and populated by the caller for each scope before saving.

            meta.ShotLabel    = shotLabel;
            meta.TargetLabel  = targetLabel;
            meta.EtalonLabel  = etalonLabel;
            meta.OperatorName = operatorName;
            meta.PZTleg       = PZTleg;
            meta.ETAleg       = ETAleg;
            meta.ETAleg2      = ETAleg2;
            meta.Date         = datestr(now, 'yyyy-mm-dd');
            meta.Time         = datestr(now, 'HH:MM:SS');
            meta.IsMultiPoint = isMultiPoint;  % 0=single-point, 1=multi-point
            meta.NumScopes    = nScopes;

            % Per-scope settings — one element per scope.
            % Each element mirrors the ScopeConfig / lissajois structs
            % in VISARsys.h.  Caller fills these in before saving.
            for k = 1:nScopes
                meta.Scope(k).TimeScale     = [];   % s/div
                meta.Scope(k).TimePerPt     = [];   % s/point
                meta.Scope(k).vScale        = [];   % 1x4 V/div
                meta.Scope(k).vPos          = [];   % 1x4 div from centre
                meta.Scope(k).TrigPos       = [];   % trigger position (%)
                meta.Scope(k).AcqPoints     = [];   % horizontal record length

                % Detector characterisation (DetectorResp struct in VISARsys.h)
                meta.Scope(k).DetPzt        = [];   % 1x4 PZT leg responsivity values
                meta.Scope(k).DetEta        = [];   % 1x4 Etalon leg responsivity values
                meta.Scope(k).DetResp       = [];   % 1x4 combined detector responsivity

                % Detector timing (timeShift array in VISARsys.h, 4 channels per scope)
                meta.Scope(k).DetTiming     = [];   % 1x4 time shifts (s)
            end
        end

        % ---------------------------------------------------------- %
        function SaveShotData(traces, meta, filepath)
        % SaveShotData  Save scope trace data with full metadata.
        %
        %   DataManager.SaveShotData(traces, meta, filepath)
        %
        % Saves one file per scope.  When nScopes > 1 a numeric suffix
        % is inserted before the extension (mirrors SaveDataTextformat).
        %
        % Inputs
        %   traces   - 1 x nScopes cell array.
        %              traces{i} is an N x 4 numeric matrix of raw ADC
        %              counts (or voltage, depending on scope class config)
        %              for scope i, channels 1-4.
        %   meta     - struct produced by BuildMetadata (with Scope fields
        %              populated for each connected scope)
        %   filepath - full path including extension, e.g. 'C:\...\Shot.txt'
        %              The extension is split off and re-applied per scope.

            [baseDir, baseName, ext] = fileparts(filepath);
            if isempty(ext), ext = '.txt'; end

            for i = 1:meta.NumScopes
                if isempty(traces{i}), continue; end

                % Build per-scope filename (suffix only when nScopes > 1)
                if meta.NumScopes > 1
                    saveName = fullfile(baseDir, ...
                        sprintf('%s%d%s', baseName, i, ext));
                else
                    saveName = fullfile(baseDir, [baseName ext]);
                end

                fid = fopen(saveName, 'w');
                if fid == -1
                    error('DataManager:SaveShotData', ...
                          'Cannot open file for writing: %s', saveName);
                end

                % ---- header (mirrors SaveDataTextformat fprintf block) ----
                DataManager.WriteHeader(fid, meta, i);
                fprintf(fid, 'acqPoints = \n%d\n', meta.Scope(i).AcqPoints);

                % ---- detector characterisation ----
                DataManager.WriteDetectorInfo(fid, meta, i);

                % ---- trace data ----
                fprintf(fid, 'ch1,ch2,ch3,ch4\n');
                data = traces{i};
                nPts = size(data, 1);
                for j = 1:nPts
                    fprintf(fid, '%d,%d,%d,%d\n', ...
                        data(j,1), data(j,2), data(j,3), data(j,4));
                end

                fclose(fid);
                fprintf('DataManager: saved trace data -> %s\n', saveName);
            end
        end

        % ---------------------------------------------------------- %
        function SaveLissajous(lisData, meta, filepath)
        % SaveLissajous  Save Lissajous pattern data with full metadata.
        %
        %   DataManager.SaveLissajous(lisData, meta, filepath)
        %
        % Mirrors SaveLis() in DataSave.c.  The per-scope Lissajous file
        % uses the lissajois struct fields (timeScale, timePerPt, etc.)
        % stored inside meta.Scope(i).
        %
        % Inputs
        %   lisData  - 1 x nScopes cell array.
        %              lisData{i} is an M x 4 matrix of integer Lissajous
        %              sample values (ch1..ch4, where pairs 1-2 and 3-4
        %              form the two Lissajous figures for each scope).
        %   meta     - struct produced by BuildMetadata
        %   filepath - full path, e.g. 'C:\...\Shot.lis'

            [baseDir, baseName, ext] = fileparts(filepath);
            if isempty(ext), ext = '.lis'; end

            for i = 1:meta.NumScopes
                if isempty(lisData{i}), continue; end

                if meta.NumScopes > 1
                    saveName = fullfile(baseDir, ...
                        sprintf('%s%d%s', baseName, i, ext));
                else
                    saveName = fullfile(baseDir, [baseName ext]);
                end

                fid = fopen(saveName, 'w');
                if fid == -1
                    error('DataManager:SaveLissajous', ...
                          'Cannot open file for writing: %s', saveName);
                end

                % ---- header ----
                DataManager.WriteHeader(fid, meta, i);
                % Lissajous files record lisPoints count, not acqPoints
                fprintf(fid, 'point in lissajous = \n%d\n', size(lisData{i}, 1));

                % ---- detector characterisation ----
                DataManager.WriteDetectorInfo(fid, meta, i);

                % ---- Lissajous data ----
                fprintf(fid, 'ch1,ch2,ch3,ch4\n');
                data = lisData{i};
                nPts = size(data, 1);
                for j = 1:nPts
                    fprintf(fid, '%d,%d,%d,%d\n', ...
                        data(j,1), data(j,2), data(j,3), data(j,4));
                end

                fclose(fid);
                fprintf('DataManager: saved Lissajous data -> %s\n', saveName);
            end
        end

        % ---------------------------------------------------------- %
        function SaveMatFormat(traces, lisData, meta, filepath)
        % SaveMatFormat  Save all data in MATLAB .mat format.
        %
        %   DataManager.SaveMatFormat(traces, lisData, meta, filepath)
        %
        % This is the primary binary format replacing the never-completed
        % .vsr format in SaveDataVSRformat().  A single .mat file is
        % written containing all scopes, all channels, Lissajous data,
        % and the full metadata struct.
        %
        % Inputs
        %   traces   - 1 x nScopes cell of N x 4 trace matrices
        %   lisData  - 1 x nScopes cell of M x 4 Lissajous matrices
        %              (pass {} or empty cells if not available)
        %   meta     - struct produced by BuildMetadata
        %   filepath - full path; extension is forced to .mat

            [baseDir, baseName, ~] = fileparts(filepath);
            saveName = fullfile(baseDir, [baseName '.mat']);

            % Package everything for a clean, self-describing .mat file
            saveData.traces  = traces;    %#ok<STRNU>
            saveData.lisData = lisData;   %#ok<STRNU>
            saveData.meta    = meta;      %#ok<STRNU>
            saveData.SavedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS'); %#ok<STRNU>

            save(saveName, '-struct', 'saveData', '-v7.3');
            fprintf('DataManager: saved .mat binary -> %s\n', saveName);
        end

        % ---------------------------------------------------------- %
        function SaveTextFormat(traces, lisData, meta, baseDir, baseName)
        % SaveTextFormat  Convenience wrapper: save both trace and Lissajous
        %                 text files in one call.
        %
        %   DataManager.SaveTextFormat(traces, lisData, meta, baseDir, baseName)
        %
        % Inputs
        %   baseDir  - directory string, e.g. 'C:\Data'
        %   baseName - filename stem without extension, e.g. 'Shot001'

            traceFile = fullfile(baseDir, [baseName '.txt']);
            lisFile   = fullfile(baseDir, [baseName '.lis']);

            DataManager.SaveShotData(traces, meta, traceFile);

            if ~isempty(lisData) && ~all(cellfun(@isempty, lisData))
                DataManager.SaveLissajous(lisData, meta, lisFile);
            end
        end

        % ---------------------------------------------------------- %
        function meta = LoadShotInfo(filepath)
        % LoadShotInfo  Read the ShotInfo.txt persistence file that the
        %               legacy DataSaveCB used to pre-populate the GUI.
        %
        % Returns a partial metadata struct with label/leg fields only.
        % Returns empty struct if the file does not exist.
        %
        % File format (one item per line, matching DataSaveDoneCB output):
        %   Line 1: ShotLabel
        %   Line 2: TargetLabel
        %   Line 3: EtalonLabel
        %   Line 4: OperatorName
        %   Line 5: DefaultDir
        %   Line 6: PZTleg  (numeric)
        %   Line 7: ETAleg  (numeric)
        %   Line 8: ETAleg2 (numeric)

            if nargin < 1
                filepath = DataManager.ShotInfoFile;
            end

            meta = struct();
            if ~isfile(filepath)
                return;
            end

            fid = fopen(filepath, 'r');
            if fid == -1, return; end

            meta.ShotLabel    = strtrim(fgetl(fid));
            meta.TargetLabel  = strtrim(fgetl(fid));
            meta.EtalonLabel  = strtrim(fgetl(fid));
            meta.OperatorName = strtrim(fgetl(fid));
            meta.DefaultDir   = strtrim(fgetl(fid));
            meta.PZTleg       = str2double(strtrim(fgetl(fid)));
            meta.ETAleg       = str2double(strtrim(fgetl(fid)));
            meta.ETAleg2      = str2double(strtrim(fgetl(fid)));

            fclose(fid);
        end

        % ---------------------------------------------------------- %
        function SaveShotInfo(meta, filepath)
        % SaveShotInfo  Write the ShotInfo.txt persistence file so that
        %               label and leg values survive between sessions.
        %
        %   DataManager.SaveShotInfo(meta)
        %   DataManager.SaveShotInfo(meta, filepath)
        %
        % Mirrors the fprintf block in the legacy DataSaveDoneCB.

            if nargin < 2
                filepath = DataManager.ShotInfoFile;
            end

            fid = fopen(filepath, 'w');
            if fid == -1
                warning('DataManager:SaveShotInfo', ...
                        'Cannot write ShotInfo file: %s', filepath);
                return;
            end

            fprintf(fid, '%s\n', meta.ShotLabel);
            fprintf(fid, '%s\n', meta.TargetLabel);
            fprintf(fid, '%s\n', meta.EtalonLabel);
            fprintf(fid, '%s\n', meta.OperatorName);

            defaultDir = '';
            if isfield(meta, 'DefaultDir'), defaultDir = meta.DefaultDir; end
            fprintf(fid, '%s\n', defaultDir);

            fprintf(fid, '%g\n', meta.PZTleg);
            fprintf(fid, '%g\n', meta.ETAleg);
            fprintf(fid, '%g\n', meta.ETAleg2);

            fclose(fid);
        end

    end  % methods (Static)

    % ------------------------------------------------------------------ %
    methods (Static, Access = private)

        function WriteHeader(fid, meta, scopeIdx)
        % WriteHeader  Write the common text-format file header block.
        %              Used by both SaveShotData and SaveLissajous.
        %
        % Mirrors the fprintf block shared between SaveDataTextformat()
        % and SaveLis() in DataSave.c.

            sc = meta.Scope(scopeIdx);

            fprintf(fid, '%s\n', meta.ShotLabel);
            fprintf(fid, '%s\n', meta.TargetLabel);
            fprintf(fid, '%s\n', meta.EtalonLabel);
            fprintf(fid, '%s\n', meta.OperatorName);
            fprintf(fid, 'PZTleg = %g\n',  meta.PZTleg);
            fprintf(fid, 'ETAleg = %g\n',  meta.ETAleg);
            fprintf(fid, 'ETAleg2 = %g\n', meta.ETAleg2);
            fprintf(fid, 'Date = %s\n',    meta.Date);
            fprintf(fid, 'Time = %s\n',    meta.Time);
            fprintf(fid, 'single-point OR multi-point = \n%d\n', ...
                    double(meta.IsMultiPoint));
            fprintf(fid, 'Number of Scopes Used = \n%d\n', meta.NumScopes);

            fprintf(fid, 'Settings for Scope #\n%d\n', scopeIdx);
            fprintf(fid, 'timeScale = \n%g\n',   sc.TimeScale);
            fprintf(fid, 'timePerPt = \n%g\n',   sc.TimePerPt);

            fprintf(fid, 'vScale[ch1-4] = \n%g,%g,%g,%g\n', ...
                    sc.vScale(1), sc.vScale(2), sc.vScale(3), sc.vScale(4));
            fprintf(fid, 'vPos[ch1-4] = \n%g,%g,%g,%g\n', ...
                    sc.vPos(1), sc.vPos(2), sc.vPos(3), sc.vPos(4));
            fprintf(fid, 'trigPos = \n%g\n', sc.TrigPos);
        end

        function WriteDetectorInfo(fid, meta, scopeIdx)
        % WriteDetectorInfo  Write detector responsivity and timing lines.
        %                    Used by both SaveShotData and SaveLissajous.
        %
        % Mirrors the "combine responsivity values" block in DataSave.c.

            sc = meta.Scope(scopeIdx);

            fprintf(fid, 'PZT leg detector values= \n%g,%g,%g,%g\n', ...
                    sc.DetPzt(1), sc.DetPzt(2), sc.DetPzt(3), sc.DetPzt(4));
            fprintf(fid, 'ETA leg detector values= \n%g,%g,%g,%g\n', ...
                    sc.DetEta(1), sc.DetEta(2), sc.DetEta(3), sc.DetEta(4));
            fprintf(fid, 'detector responsivity= \n%g,%g,%g,%g\n', ...
                    sc.DetResp(1), sc.DetResp(2), sc.DetResp(3), sc.DetResp(4));
            fprintf(fid, 'detector Timing = \n%g,%g,%g,%g\n', ...
                    sc.DetTiming(1), sc.DetTiming(2), ...
                    sc.DetTiming(3), sc.DetTiming(4));
        end

    end  % methods (Static, Access = private)

end  % classdef DataManager