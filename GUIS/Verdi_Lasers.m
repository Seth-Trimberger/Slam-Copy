classdef Verdi_Lasers
    %VERDI_LASERS Hardware control class for the Coherent Verdi V-10 laser
    %
    %Here is the link to the documentation
    %https://github.com/quantumm/user_manual/blob/main/Coherent_VerdiV10_UserManual.pdf

    properties
        NameOfLaser;
        %ASRL4::INSTR
        VisaObj;
    end

    methods
        function obj = Verdi_Lasers(NameOfLaserInput)
            %VERDI_LASERS Construct an instance of this class
            obj.NameOfLaser = NameOfLaserInput;
            obj.VisaObj = visadev(NameOfLaserInput);
            obj.VisaObj.configureTerminator("CR/LF")
        end


        %These functions down here are Commands To Control the Laser

        function ControlTheShutter(obj, Userinput)

            if Userinput == 0
                fprintf("Closing The Shutter\n")
                writeread(obj.VisaObj, "SHUTTER=0");
                pause(0.5);
            elseif Userinput == 1
                fprintf("Opening The Shutter\n")
                writeread(obj.VisaObj, "SHUTTER=1");
                pause(0.5);
            else
                fprintf("Error You Did Not Enter A Valid Command To Control The Shutter\n")
            end

        end

        function SetOutPutPower(obj, Userinput)
            % Check if input is in valid range (0.0001 to 10.9999)
            if Userinput >= 0.0001 && Userinput <= 10.9999
                % Check if input has more than 4 decimal places
                rounded = round(Userinput, 4);
                if abs(Userinput - rounded) > eps
                    fprintf("Error: Power must have 4 or fewer decimal places (nn.nnnn format)\n")
                    return
                end

                % Format and send command
                fprintf("Setting Output Power to %.4f watts\n", Userinput)
                outputLine = sprintf("P=%.4f", Userinput);
                writeread(obj.VisaObj, outputLine);
                pause(0.5);
            else
                fprintf("Error: Power must be in Range of 0.0001 through 10.9999\n")
            end
        end

        
        function FlashEtalon(obj)
            fprintf("Flashing Etalon\n")
            writeread(obj.VisaObj, "FLASH=1");
            pause(0.2);
        end

        function ControlTheEcho(obj, UserInput)
            if UserInput == 0
                fprintf("Turned Off The Echo\n")
                writeread(obj.VisaObj, "ECHO=0");
            elseif UserInput == 1
                fprintf("Turned On The Echo\n")
                writeread(obj.VisaObj, "ECHO=1");
            else
                fprintf("Error You Did Not Enter A Valid Echo Command\n")
            end
        end


        %These functions down here are for the Queries
        %Note: Return values added so the GUI can display results in
        %readback fields. fprintf output is preserved for console logging.

        function power = GetPowerSetpoint(obj)
            fprintf("Querying Power Setpoint\n")
            flush(obj.VisaObj, "input");
            pause(0.05);
            flush(obj.VisaObj, "input");

            response = writeread(obj.VisaObj, "?SP");
            parts = split(strtrim(response), '>');
            powerStr = strtrim(parts(end));
            power = str2double(powerStr);
            fprintf("Power Setpoint: %.4f watts\n", power)
        end

        function power = GetActualLightOutput(obj)
            fprintf("Querying Actual Light Output\n")
            flush(obj.VisaObj, "input");
            pause(0.05);
            flush(obj.VisaObj, "input");

            response = writeread(obj.VisaObj, "?LIGHT");
            parts = split(strtrim(response), '>');
            powerStr = strtrim(parts(end));
            power = str2double(powerStr);
            fprintf("Actual Light Output: %.4f watts\n", power)
        end

        function status = GetTheShutterStatus(obj)
            flush(obj.VisaObj, "input");
            pause(0.05);
            flush(obj.VisaObj, "input");

            currentStatus = writeread(obj.VisaObj, "?S");
            updatedStatus = strtrim(currentStatus);
            % Splits based off Verdi V-10>0
            parts = split(updatedStatus, '>');
            statusStr = strtrim(parts(end));   % should be "0" or "1"

            status = str2double(statusStr);
            if status == 0
                fprintf("The Shutter is Closed\n")
            elseif status == 1
                fprintf("The Shutter is Open\n")
            else
                fprintf("Error The Laser Did Not Return a Shutter Status\n")
                status = -1;
            end
        end


        %Future Commands Down Here That Could Be Implemented If Needed But
        %For VISAR Are Not Needed

        %function LBOHeaterControl(obj, input)
        %end
        %function TurnLaser_ON_OFF(obj, input)
        %end
        %function RunLBOOptimization(obj)
        %end
        %function SetRS232BaudRate(obj, input)
        %end

    end
end