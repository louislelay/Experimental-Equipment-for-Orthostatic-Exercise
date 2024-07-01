clear all;
a = lowPassFilter([1,1,1],0.5, 1,[[5,4,3],[5,2,5]]);
disp(a);