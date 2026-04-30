function object=showExample1()

x=linspace(-2,2,49);
y=linspace(-2,2,51);
[X,Y]=ndgrid(x,y);
Z=exp(-X.^2/(2*1^2)-Y.^2/(2*0.5^2));


object=SLAM.Sesame.kinterp2(x,y,Z);

end