<%
  bias = NetInfo['bias']
  cogctrl = NetInfo['cogctrl']
%>

addNet lexdec -i 6 -t 3 CONTINUOUS

addGroup orthoinp 104 INPUT
addGroup attrctrortho 50
addGroup ortho 104 OUTPUT CROSS_ENTROPY -BIASED
addGroup hidden 300 -BIASED
addGroup sem 100 OUTPUT CROSS_ENTROPY -BIASED
addGroup attrctrsem 50
addGroup seminp 100 INPUT
addGroup cogctrlortho 1 INPUT
addGroup cogctrlsem 1 INPUT
addGroup cogctrlhid 1 INPUT


connectGroups orthoinp ortho -p  ONE_TO_ONE -m 2.5 -r 0
connectGroups ortho attrctrortho -bi
connectGroups attrctrortho attrctrortho
connectGroups ortho hidden -bi
connectGroups sem hidden -bi
connectGroups seminp sem -p ONE_TO_ONE -m 2.5 -r 0
connectGroups sem attrctrsem -bi
connectGroups attrctrsem attrctrsem
connectGroups bias ortho -m ${bias} -r 0
connectGroups bias sem -m ${bias} -r 0
connectGroups bias hidden -m ${bias} -r 0
connectGroups cogctrlortho ortho -m ${cogctrl} -r 0
connectGroups cogctrlsem sem -m ${cogctrl} -r 0
connectGroups cogctrlhid hidden -m ${cogctrl} -r 0
