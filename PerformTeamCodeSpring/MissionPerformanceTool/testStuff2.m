close all; clear; clc;


joe = testStuff(5);
disp(joe.a);
disp(getfield(joe, 'a'));
disp(joe.("a"))

testObjStuff(joe);

disp(joe.a);
disp(getfield(joe, 'a'));
disp(joe.("a"))


function [] = testObjStuff(obj)
    obj.a = 6;
end