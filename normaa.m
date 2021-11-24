%tabela=table2cell(readtable(strcat("wse stocks/wig20.txt"),'PreserveVariableNames',true));
tabela2=tabela1;
tabela_bench2=tabela_bench;
[roz,~]=size(tabela_bench2);

j=0;

for i=1:1:roz
    
    norma(i,1)=tabela_bench2(i,1);
    norma(i,2)=tabela_bench2(i,3);
    if string(tabela2(i,3))==string(tabela_bench2(i,3))
        norma(i,3)=tabela2(i,8);
        j++;
    elseif string(tabela2(i,3))>string(tabela_bench2(i,3))
        
        norma(i,3)=tabela2(i-1,8);
       
    end
    
    
end
