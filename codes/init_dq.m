function dq = init_dq

    % Initialization    
    dq{1} = daq("ni");  dq{1}.Rate = 1000; % BR, BL, FR and FN in
    dq{2} = daq("ni");  dq{2}.Rate = 1000; % BR, BL, FR and FN out

    % BR
    addinput(dq{1}, "Right", "ai0", "Voltage"); %Fx
    addinput(dq{1}, "Right", "ai1", "Voltage"); %Fy
    addinput(dq{1}, "Right", "ai2", "Voltage"); %Fz
    
    addoutput(dq{2}, "Right", "ao0", "Voltage"); % 1 右上モータ(BR)
    addoutput(dq{2}, "Right", "port1/line0", "Digital"); % 5 右上側（BR）の回転方向制御
    addoutput(dq{2}, "Right", "port1/line1", "Digital"); % 6 右上側（BR）の制御
    
    % BL
    addinput(dq{1}, "Left", "ai0", "Voltage");%Fx
    addinput(dq{1}, "Left", "ai1", "Voltage");%Fy
    addinput(dq{1}, "Left", "ai2", "Voltage");%Fz
    
    addoutput(dq{2}, "Left",  "ao0", "Voltage"); % 3 左上モータ(BL)
    addoutput(dq{2}, "Left", "port1/line0", "Digital"); % 9  左上側（BL）の制御
    addoutput(dq{2}, "Left", "port1/line1", "Digital"); % 10 左上側（BL）の制御
    
    % FR
    addinput(dq{1}, "Right", "ai4", "Voltage"); %Fx
    addinput(dq{1}, "Right", "ai5", "Voltage"); %Fy
    addinput(dq{1}, "Right", "ai6", "Voltage"); %Fz
    
    addoutput(dq{2}, "Right", "ao1", "Voltage"); % 2 右下モータ(FR)
    addoutput(dq{2}, "Right", "port1/line2", "Digital"); % 7 右下側（FR）の制御
    addoutput(dq{2}, "Right", "port1/line3", "Digital"); % 8 右下側（FR）の制御
    
    % FL
    addinput(dq{1}, "Left", "ai4", "Voltage");%Fx 10
    addinput(dq{1}, "Left", "ai5", "Voltage");%Fy 11
    addinput(dq{1}, "Left", "ai6", "Voltage");%Fz 12

    addoutput(dq{2}, "Left",  "ao1", "Voltage"); % 4 左下モータ(FL)
    addoutput(dq{2}, "Left", "port1/line2", "Digital"); % 11 左下側（FL）の制御
    addoutput(dq{2}, "Left", "port1/line3", "Digital"); % 12 左下側（FL）の制御

    
    for ai = 1:6
        dq{1}.Channels(ai).TerminalConfig = "SingleEnded";
    end
end