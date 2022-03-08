clc
clear all

%paths
%C:\Users\Acer\Desktop\LTSpiceAndMATLAB\practice.net
%C:\Program Files\LTC\LTspiceXVII\XVIIx64.exe

%netlist
% * C:\Users\Acer\Desktop\LTSpiceAndMATLAB\practice.asc
% V1 vin 0 SINE(0 {amp} {freq})
% R1 vout vin {R}
% C1 vout 0 {C}
% .params R=10k C=160p  amp=1 freq=1k
% .tran .1
% .backanno
% .end


netlist = 'C:\\Users\Acer\Desktop\LTSpiceAndMATLAB\practice.net'

%netlist modifications on matlab
%full path is not needed
code = ['C:\\Users\\Acer\\Desktop\\LTSpiceAndMATLAB\\practice.net'...
        '\\Example\\practice.asc\r\n'...
        'XU1 v1 N005 0 N001 NC_01 C3M0065090D\r\n'...
        'V1 N001 0 100\r\n'...
        'V2 N006 0 PWL(500u 0 500.1u 15 750u 15 750.1u 0)\r\n'...
        'V3 N002 0 100\r\n'...
        'L1 N001 N005 1m\r\n'...
        'R1 N007 N006 3'...
        'XU2 N001 N004 N005 N002 NC_02 C3M0065090D'...
        'V4 N003 N005 PWL(750u 0 750.1u 15)'...
        'R2 N004 N003 3'...
        '.lib "C:\\Users\\Acer\\Documents\\LTspiceXVII\\lib\\C3M0065090D.lib"'...
        '.tran 10m'...
        '.backanno\r\n'...
        '.end\r\n']
    
 %create new netlist
 fid = fopen(netlist,'w+');
 fprintf(fid,code);
 fid = fclose(fid);
 
 %launch the batch files and let the ltspice finish the sim
 dos('LTspice_call.bat');
 pause(5)
 dos('LTspice_end.bat')
 
 raw_data = LTspice2Matlab('practice.raw');
 