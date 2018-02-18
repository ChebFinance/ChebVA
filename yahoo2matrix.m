function matrix = yahoo2matrix(file,cols)
% Extracts data from a CSV file (from Yahoo), selects the columns given by
% the vector COLS and flips it up/down. Notice the first row in the CSV 
% file has the headers and it is not read.

A = csvread(file,1,0);
A = flipud(A);
matrix = A(:,cols);