function matrix = bb2matrix(file,cols)
% Extracts data from a CSV file (from Bloomberg), selects the columns given 
% by the vector COLS and flips it up/down. Notice the first row in the CSV 
% file has the headers and it is not read.

A = csvread(file,2,0);
matrix = A(:,cols);