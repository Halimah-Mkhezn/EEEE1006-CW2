function temp_monitor(a, tempPin, greenLED, yellowLED, redLED)
% TEMP_MONITOR Real-time temperature monitoring with LED control
%
% Monitors temperature continuously and controls three LEDs:
% - Green LED (constant): 18-24°C (comfort range)
% - Yellow LED (blink 0.5s): below 18°C (too cold)
% - Red LED (blink 0.25s): above 24°C (too hot)
%
% Usage: temp_monitor(a, tempPin, greenLED, yellowLED, redLED)

    % Sensor specs (MCP9700A)
    TC = 0.01;       % 10 mV/°C
    V0C = 0.5;       % 500 mV at 0°C
    
    % Temperature comfort range
    TEMP_MIN = 18;   % Minimum comfort temperature
    TEMP_MAX = 24;   % Maximum comfort temperature
    
    % Data storage for plotting
    timeData = [];
    tempData = [];
    startTime = tic;
    
    % Setup live plot
    figure;
    h = plot(timeData, tempData, 'b-', 'LineWidth', 1.5);
    xlabel('Time (seconds)');
    ylabel('Temperature (°C)');
    title('Real-time Temperature Monitoring');
    grid on;
    hold on;
    yline(TEMP_MIN, 'g--', '18°C Min', 'LineWidth', 1.5);
    yline(TEMP_MAX, 'r--', '24°C Max', 'LineWidth', 1.5);
    hold off;
    
    % LED blink control
    ledState = 0;
    lastBlinkTime = tic;
    
    disp('Time(s)  Temp(°C)  LED Status');
    disp('-------  --------  ----------');
    
    % Main monitoring loop (runs forever)
    while true
        % Read temperature
        elapsedTime = toc(startTime);
        voltage = readVoltage(a, tempPin);
        temperature = (voltage - V0C) / TC;
        
        % Store data for plotting
        timeData = [timeData, elapsedTime];
        tempData = [tempData, temperature];
        
        % Control LEDs based on temperature
        if temperature >= TEMP_MIN && temperature <= TEMP_MAX
            % Temperature in comfort range
            % GREEN LED: constant ON
            writeDigitalPin(a, greenLED, 1);
            writeDigitalPin(a, yellowLED, 0);
            writeDigitalPin(a, redLED, 0);
            ledStatus = 'GREEN (constant)';
            
        elseif temperature < TEMP_MIN
            % Temperature below range (too cold)
            % YELLOW LED: blink every 0.5 seconds
            writeDigitalPin(a, greenLED, 0);
            writeDigitalPin(a, redLED, 0);
            
            if toc(lastBlinkTime) >= 0.5
                ledState = ~ledState;
                writeDigitalPin(a, yellowLED, ledState);
                lastBlinkTime = tic;
            end
            
            if ledState
                ledStatus = 'YELLOW (blink ON)';
            else
                ledStatus = 'YELLOW (blink OFF)';
            end
            
        else
            % Temperature above range (too hot)
            % RED LED: blink every 0.25 seconds
            writeDigitalPin(a, greenLED, 0);
            writeDigitalPin(a, yellowLED, 0);
            
            if toc(lastBlinkTime) >= 0.25
                ledState = ~ledState;
                writeDigitalPin(a, redLED, ledState);
                lastBlinkTime = tic;
            end
            
            if ledState
                ledStatus = 'RED (blink ON)';
            else
                ledStatus = 'RED (blink OFF)';
            end
        end
        
        % Update live plot
        set(h, 'XData', timeData, 'YData', tempData);
        xlim([max(0, elapsedTime-60), elapsedTime+5]);
        
        if ~isempty(tempData)
            ylim([min(tempData)-2, max(tempData)+2]);
        end
        
        drawnow;
        
        % Display status every 5 seconds
        if mod(length(timeData), 5) == 0
            disp([num2str(elapsedTime, '%.1f') '     ' ...
                  num2str(temperature, '%.2f') '     ' ledStatus]);
        end
        
        pause(1);
    end
end
