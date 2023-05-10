function NofDigits=fu_Digits(input)
input = abs(input); %in case of negative numbers
NofDigits=0;
while (floor(input*10^NofDigits)<=0)
NofDigits=NofDigits+1;
end