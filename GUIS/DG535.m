classdef DG535 < handle
    %DG535 Summary of this class goes here
    %This class will controll all the software regarding the DG535 and
    %commands to run.
    %Here is a link to the software https://thinksrs.com/downloads/pdfs/manuals/DG535m.pdf

    properties
        NameOfDD;
        VisaObj;
        %Sets A Default Trigger_rate to 100, Change if you would like
        %higher or to not have a default value.
        Trigger_Rate = 100;
        CurrentTriggerMode = "NULL"
        
    end

    methods
        function obj = DG535(NameOfDDG)
            %DG535 Construct an instance of this class
            %   Detailed explanation goes here
            obj.NameOfDD = NameOfDDG;
            obj.VisaObj = visadev(NameOfDDG);
        end

        %This function clears all settings on the instrument to make sure
        %we have the correct settings everytime
        function ClearInstrument(obj)
            %We will Clear all settings
            fprintf("Running \n")
            fprintf(obj.VisaObj, "CL");

            WriteStringToDisplayOnDDG(obj, "Cleared all Settings")
        end

        %This Function is a default function to write to the DDG screen
        function WriteStringToDisplayOnDDG(obj,stringInput)
            fprintf("Printing The following Message To The DDG: " + stringInput + "\n");
            StringToSend = "DS " + stringInput;
            fprintf(obj.VisaObj, StringToSend);
        end

        %This Function Clears all Display Strings
        function ClearStringsFromDispaly(obj)
            fprintf("Clearing Display on DDG 535  \n")
            fprintf(obj.VisaObj, "DS")
        end
        
        %This function Sets The Internal Trigger Rate
        function InputTrigerRate(obj,TriggerRateInput)
            
            fprintf("Running Trigger Rate Function  \n")

            %Validation Test 
            if TriggerRateInput >= 0 && isnumeric(TriggerRateInput)
                %Eventually this TriggerRateInput will be taken from the
                %GUI. For Right Now The User Just enters the number
                obj.Trigger_Rate = TriggerRateInput;
                fprintf("New Trigger Rate Is " + obj.Trigger_Rate)
                fprintf(obj.VisaObj, "TR 0,%g", obj.Trigger_Rate)
            else
                fprintf("Error: Your User Input Is Either Not >= 0 Or You Did Not Enter A Number in the Trigger Rate Input Field  \n")
            end

        end

        %This Function Will Switch to the Interal Trigger Rate
        %function SendInternalTrigger(obj)
          %  fprintf("Set The Trigger Mode to Internal \n")
         %   fprintf(obj.VisaObj, "TM 0")
        %    WriteStringToDisplayOnDDG(obj, "Internal Mode Selcted")
       % end

        %This Function Will Switch to the External Trigger Mode
        %function SendExternalTrigger(obj)
            %fprintf("Set The Trigger Mode to Internal \n")
           % WriteStringToDisplayOnDDG(obj, "External Mode Selcted")
          %  fprintf(obj.VisaObj, "TM 1")
         %   fprintf("")

        %end
        
        %This function Will switch the
        %set trigger mode
        function SetTheTriggerRate(obj,TriggerMode)
            if TriggerMode == 0
                fprintf("Setting The Triger Mode To Internal \n")
                % set the trigger rate to interal.
                obj.CurrentTriggerMode = "Internal"
                fprintf(obj.VisaObj, "TM 0")
                WriteStringToDisplayOnDDG(obj, "Internal Mode Selcted")

            elseif TriggerMode == 1
                fprintf("Setting The Triger Mode To External\n")
                % set the trigger rate to External.
                fprintf(obj.VisaObj, "TM 1")
                obj.CurrentTriggerMode = "External"
                WriteStringToDisplayOnDDG(obj, "External Mode Selcted")

            elseif TriggerMode == 2
                fprintf("Setting The Triger Mode To SingleShot Mode\n")
                % set the trigger rate to SingleShot Mode.
                fprintf(obj.VisaObj, "TM 2")
                obj.CurrentTriggerMode = "SingleShot"
                WriteStringToDisplayOnDDG(obj, "SingleShot Mode Selcted")

            elseif TriggerMode == 3
                fprintf("Setting The Triger Mode To Burst Trigger Mode\n")
                % set the trigger rate to Burst Trigger Mode.
                fprintf(obj.VisaObj, "TM 3")
                obj.CurrentTriggerMode = "Burst"
                WriteStringToDisplayOnDDG(obj, " Burst Trigger Mode Selcted")

            else
                fprintf("Error You Did Not Select A Valid Trigger Mode\n")
                obj.CurrentTriggerMode = "NULL"
            end             
        end

        %This function sets the delay of a spesfic channel
        function DelayTimeOfChannel(obj, InputA, InputB, InputC)
            fprintf("Set The Delay Time OF Each Channel\n")
            DelayTimeToRun = sprintf("DT %d,%d,%g", InputA, InputB, InputC)
            fprintf(obj.VisaObj,DelayTimeToRun)
            fprintf("")
        end
        
        function SendSingleShotTriggerRate(obj)
            if(obj.CurrentTriggerMode == 'SingleShot')
                fprintf("Sending_A_Single_Shot\n")
                fprintf(obj.VisaObj, "SS")
                WriteStringToDisplayOnDDG(obj,"Sent_A_Single_Shot\n")
            else
                fprintf("Error You Are Not In Single Shot Trigger Mode\n")
            end
        end

        %% NEW METHODS FOR BURST MODE SAFETY
        
        % Query if device is busy
        function isBusy = CheckIfBusy(obj)
            % Query instrument status bit 1 (Busy with timing cycle)
            try
                flush(obj.VisaObj, 'input');
                response = writeread(obj.VisaObj, "IS 1");
                isBusy = str2double(response) == 1;
            catch
                isBusy = false; % Assume not busy if we can't query
            end
        end
        
        % Wait for device to be ready
        function WaitUntilReady(obj, maxWaitSeconds)
            if nargin < 2
                maxWaitSeconds = 5;
            end
            
            fprintf("Waiting for DG535 to be ready...\n");
            startTime = tic;
            
            while toc(startTime) < maxWaitSeconds
                if ~obj.CheckIfBusy()
                    fprintf("DG535 is ready\n");
                    return;
                end
                pause(0.2);
            end
            
            fprintf("Warning: DG535 still busy after %d seconds\n", maxWaitSeconds);
        end
        
        % Safely switch to SingleShot mode before configuration
        function previousMode = EnterConfigMode(obj)
            % Save current mode and switch to SingleShot for safe configuration
            previousMode = obj.CurrentTriggerMode;
            fprintf("Entering config mode (switching to SingleShot)\n");
            
            try
                obj.SetTheTriggerRate(2); % SingleShot mode
                pause(0.1); % Let device finish current cycle
                obj.WaitUntilReady(3);
            catch
                fprintf("Warning: Could not verify device is ready\n");
            end
        end
        
        % Restore previous trigger mode
        function ExitConfigMode(obj, previousMode)
            fprintf("Exiting config mode (restoring %s)\n", previousMode);
            
            switch previousMode
                case "Internal"
                    obj.SetTheTriggerRate(0);
                case "External"
                    obj.SetTheTriggerRate(1);
                case "SingleShot"
                    obj.SetTheTriggerRate(2);
                case "Burst"
                    obj.SetTheTriggerRate(3);
            end
        end

    end
end