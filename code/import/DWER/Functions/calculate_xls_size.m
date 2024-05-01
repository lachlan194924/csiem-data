function [rows,cols] = calculate_xls_size(filename)

aa = xlsread(filename);
[~,gg] = xlsread(filename,'A2:ZZ2');


[bb,~] = size(aa);
A = length(gg);
%A = A + 6;

rows = bb + 2;

if A < 26
    
    cols = char(64 + A);
    
else
    
    R = floor(A / 26);
    
    L = A - (26 * R);
    
   cols = [char(64+R) char(65+L)];
    
end