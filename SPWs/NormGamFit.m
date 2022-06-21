%% How to make a normfit and gamfit

x =1:11;
y=[0.5 1 3 4 5 7 5 4 3 1 0.5];
y = y/sum(y);
bar(x,y);
[muHat,sigmaHat] = normfit(x);
y = normpdf(Nnorm,muHat,sigmaHat);

hold on;
plot(x,normpdf(x,muHat),'y','Linewidth',2);
hold off;

