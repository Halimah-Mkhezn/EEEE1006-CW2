function temp_prediction(a, tempPin, greenLED, yellowLED, redLED)
% TEMP_PREDICTION Temperature prediction and rate monitoring
%
% Calculates temperature change rate and predicts future temperature.
% Controls LEDs based on rate of change:
% - Green LED (constant): stable temperature (|rate| <= 4°C/min)
% - Red LED (constant): rapid increase (rate > +4°C/min)
% - Yellow LED (constant): rapid decrease (rate < -4°C/min)
%
% Usage: temp_prediction(a, tempPin, greenLED, yellowLED, redLED)

    % Sensor specs (MCP9700A)
    TC = 0.01;       % 10 mV/°C
    V0C = 0.5;       % 500 mV at 0°C
    
    % Rate of change threshold
    CRITICAL_RATE = 4.0 / 60;  % 4°C/min converted to °C/s
    
    % Data storage
    tempHistory = [];
    timeHistory = [];
    startTime = tic;
    
    disp('Time(s)  Temp(°C)  Rate(°C/s)  Rate(°C/min)  Predict(°C)  LED Status');
    disp('-------  --------  ----------  ------------  -----------  ----------');
    
    % Main monitoring loop (runs forever)
    while true
        % Read temperature
        elapsedTime = toc(startTime);
        voltage = readVoltage(a, tempPin);
        temperature = (voltage - V0C) / TC;
        
        % Store data
        tempHistory = [tempHistory, temperature];
        timeHistory = [timeHistory, elapsedTime];
        
        % Calculate rate of change after collecting enough data
        if length(tempHistory) >= 10
            % Smooth data with moving average to reduce noise
            smoothTemp = movmean(tempHistory, 10);
            
            % Calculate rate of change (derivative)
            timeDiff = timeHistory(end) - timeHistory(end-1);
            tempDiff = smoothTemp(end) - smoothTemp(end-1);
            rateOfChange = tempDiff / timeDiff;  % °C/s
            ratePerMinute = rateOfChange * 60;   % °C/min
            
            % Predict temperature in 5 minutes (300 seconds)
            predictedTemp = temperature + (rateOfChange * 300);
            
            % Control LEDs based on rate of change
            if rateOfChange > CRITICAL_RATE
                % Rapid temperature INCREASE
                % RED LED: constant ON
                writeDigitalPin(a, greenLED, 0);
                writeDigitalPin(a, yellowLED, 0);
                writeDigitalPin(a, redLED, 1);
                ledStatus = 'RED (increase)';
                
            elseif rateOfChange < -CRITICAL_RATE
                % Rapid temperature DECREASE
                % YELLOW LED: constant ON
                writeDigitalPin(a, greenLED, 0);
                writeDigitalPin(a, yellowLED, 1);
                writeDigitalPin(a, redLED, 0);
                ledStatus = 'YELLOW (decrease)';
                
            else
                % Temperature STABLE
                % GREEN LED: constant ON
                writeDigitalPin(a, greenLED, 1);
                writeDigitalPin(a, yellowLED, 0);
                writeDigitalPin(a, redLED, 0);
                ledStatus = 'GREEN (stable)';
            end
            
            % Display results
            disp([num2str(elapsedTime, '%.1f') '     ' ...
                  num2str(temperature, '%.2f') '      ' ...
                  num2str(rateOfChange, '%.4f') '       ' ...
                  num2str(ratePerMinute, '%.2f') '          ' ...
                  num2str(predictedTemp, '%.2f') '       ' ...
                  ledStatus]);
        else
            % Not enough data yet - turn off all LEDs
            writeDigitalPin(a, greenLED, 0);
            writeDigitalPin(a, yellowLED, 0);
            writeDigitalPin(a, redLED, 0);
            
            disp([num2str(elapsedTime, '%.1f') '     ' ...
                  num2str(temperature, '%.2f') '      Collecting data...']);
        end
        
        % Limit history size (keep last 600 samples = 10 minutes)
        if length(tempHistory) > 600
            tempHistory = tempHistory(end-599:end);
            timeHistory = timeHistory(end-599:end);
        end
        
        pause(1);
    end
end
