<%
  bias = NetInfo['bias']
  cogctrl = NetInfo['cogctrl']
%>

addNet lexdec -i 6 -t 3 CONTINUOUS

addGroup orthinp 104 INPUT
addGroup attrctrorth 50
addGroup orth 104 OUTPUT CROSS_ENTROPY -BIASED
addGroup hidden 300 -BIASED
addGroup sem 100 OUTPUT CROSS_ENTROPY -BIASED
addGroup attrctrsem 50
addGroup seminp 100 INPUT
addGroup cogctrlorth 1 INPUT
addGroup cogctrlsem 1 INPUT
addGroup cogctrlhid 1 INPUT


connectGroups orthinp orth -p  ONE_TO_ONE -m 2.5 -r 0
connectGroups orth attrctrorth -bi
connectGroups attrctrorth attrctrorth
connectGroups orth hidden -bi
connectGroups sem hidden -bi
connectGroups seminp sem -p ONE_TO_ONE -m 2.5 -r 0
connectGroups sem attrctrsem -bi
connectGroups attrctrsem attrctrsem
connectGroups bias orth -m ${bias} -r 0
connectGroups bias sem -m ${bias} -r 0
connectGroups bias hidden -m ${bias} -r 0
connectGroups cogctrlorth orth -m ${cogctrl} -r 0
connectGroups cogctrlsem sem -m ${cogctrl} -r 0
connectGroups cogctrlhid hidden -m ${cogctrl} -r 0
