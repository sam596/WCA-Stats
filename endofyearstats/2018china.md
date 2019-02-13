## End of Year Stats for WCT

*Last updated using WCA Developer Export from Wed Feb 13 at 0159UTC*

*The [World Cube Association](https://www.worldcubeassociation.org) is the source and owner of this information. This published information is not actual information, the actual information can be found [here](https://www.worldcubeassociation.org/results).*

#	Most solves
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE value > 0 AND YEAR(date) = 2018 GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;
```

|personId|personName|personCountryId|COUNT(*)|  
|--|--|--|--|  
|2007YUNQ01|Yunqi Ouyang (欧阳韵奇)|China|2181|  
|2010WANG53|Jiayu Wang (王佳宇)|China|1754|  
|2009ZHEN11|Ming Zheng (郑鸣)|China|1190|  
|2013WANG67|Xuming Wang (王旭明)|China|1157|  
|2014CHEN08|Boxi Chen (陈博希)|China|1157|  
|2008DONG06|Baiqiang Dong (董百强)|China|1130|  
|2017CHEN36|Xinyun Chen (陈新运)|China|1009|  
|2017LIUC11|Chunhao Liu (柳春浩)|China|954|  
|2015DUYU01|Yusheng Du (杜宇生)|China|949|  
|2017YINX01|Xingkai Yin (尹星凯)|China|927|  


#	Most countries competed in (excludes Multiple-Country comps)
```sql
SELECT personId, personName, personCountryId, COUNT(DISTINCT compCountryId) FROM results_extra WHERE YEAR(date) = 2018 AND compCountryId NOT LIKE 'X_' GROUP BY personId ORDER BY COUNT(DISTINCT compCountryId) DESC LIMIT 10;
```

|personId|personName|personCountryId|COUNT(DISTINCT compCountryId)|  
|--|--|--|--|  
|2013LINK01|Kaijun Lin (林恺俊)|China|6|  
|2013ZHEN11|Yuyang Zhen (甄禹扬)|China|4|  
|2018SHEN07|Mengfei Shen (沈梦非)|China|4|  
|2015CHEN49|Yucheng Chen (陈裕铖)|China|4|  
|2014HEYO01|Young He (何嘉炀)|China|4|  
|2009YINM01|Mulun Yin (阴目仑)|China|4|  
|2014ZHAO12|Tianyu Zhao (赵天愉)|China|3|  
|2017FENG33|Mohan Feng (冯莫涵)|China|3|  
|2016DAIM01|Mingmin Dai (戴铭民)|China|3|  
|2014HUZE01|Zeyu Hu (胡泽宇)|China|3|  


#	Most golds
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 1 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;
```

|personId|personName|personCountryId|COUNT(*)|  
|--|--|--|--|  
|2013WANG67|Xuming Wang (王旭明)|China|55|  
|2010WANG53|Jiayu Wang (王佳宇)|China|35|  
|2011CAOS01|Sheng Cao (曹晟)|China|34|  
|2013LINK01|Kaijun Lin (林恺俊)|China|30|  
|2015DUYU01|Yusheng Du (杜宇生)|China|27|  
|2012ZHAN08|Anyu Zhang (张安宇)|China|26|  
|2009YINM01|Mulun Yin (阴目仑)|China|25|  
|2013FENG02|Zijia Feng (冯子甲)|China|20|  
|2012PANJ02|Jiekang Pan (潘杰康)|China|19|  
|2015XION03|Max Xiong (熊锐明)|China|17|  


#	Most silvers
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 2 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;
```

|personId|personName|personCountryId|COUNT(*)|  
|--|--|--|--|  
|2010WANG53|Jiayu Wang (王佳宇)|China|41|  
|2015DUYU01|Yusheng Du (杜宇生)|China|21|  
|2011CAOS01|Sheng Cao (曹晟)|China|21|  
|2016FANG01|Shenghai Fang (方胜海)|China|20|  
|2012ZHAN08|Anyu Zhang (张安宇)|China|16|  
|2013WANG67|Xuming Wang (王旭明)|China|15|  
|2016ZHAO28|Junze Zhao (赵俊泽)|China|14|  
|2009YINM01|Mulun Yin (阴目仑)|China|13|  
|2015XION03|Max Xiong (熊锐明)|China|9|  
|2014CHEN08|Boxi Chen (陈博希)|China|9|  


#	Most bronzes
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos = 3 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;
```

|personId|personName|personCountryId|COUNT(*)|  
|--|--|--|--|  
|2007YUNQ01|Yunqi Ouyang (欧阳韵奇)|China|19|  
|2015DUYU01|Yusheng Du (杜宇生)|China|18|  
|2010WANG53|Jiayu Wang (王佳宇)|China|18|  
|2011CAOS01|Sheng Cao (曹晟)|China|18|  
|2010WANG07|Yinghao Wang (王鹰豪)|China|14|  
|2016ZHAO28|Junze Zhao (赵俊泽)|China|12|  
|2012QIUR01|Ruohan Qiu (邱若寒)|China|11|  
|2015XION03|Max Xiong (熊锐明)|China|9|  
|2013WANG69|Bo Wang (王擘)|China|9|  
|2012LIUY03|Yiwei Liu (刘伊玮)|China|8|  


#	Most podiums
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM results_extra WHERE YEAR(date) = 2018 AND roundTypeId IN ('c','f') AND pos <= 3 AND best > 0 GROUP BY personID ORDER BY COUNT(*) DESC LIMIT 10;
```

|personId|personName|personCountryId|COUNT(*)|  
|--|--|--|--|  
|2010WANG53|Jiayu Wang (王佳宇)|China|94|  
|2013WANG67|Xuming Wang (王旭明)|China|78|  
|2011CAOS01|Sheng Cao (曹晟)|China|73|  
|2015DUYU01|Yusheng Du (杜宇生)|China|66|  
|2012ZHAN08|Anyu Zhang (张安宇)|China|46|  
|2009YINM01|Mulun Yin (阴目仑)|China|44|  
|2013LINK01|Kaijun Lin (林恺俊)|China|38|  
|2013FENG02|Zijia Feng (冯子甲)|China|37|  
|2016ZHAO28|Junze Zhao (赵俊泽)|China|36|  
|2015XION03|Max Xiong (熊锐明)|China|35|  


#	Most competitions organized
```sql
SELECT u.name, COUNT(*) FROM wca_dev.competition_organizers co JOIN wca_dev.users u ON co.organizer_id = u.id WHERE competition_id LIKE '%2018' GROUP BY co.organizer_id ORDER BY COUNT(*) DESC LIMIT 10;
```

|name|COUNT(*)|  
|--|--|  
|Baiqiang Dong (董百强)|3|  
|Zhijun Li (李芷筠)|2|  
|Zengchu Wu (吴增初)|2|  
|Qingbin Chen (陈庆斌)|2|  
|Junjie Fu (傅俊杰)|2|  
|Wenjie Cao (曹文杰)|2|  
|Joy Liou Liu (刘丽欧)|2|  
|Xi'an Cube Association (西安魔方协会)|2|  
|Bodun Zhu (朱博楯)|2|  
|Xiaobin Rui (芮晓彬)|2|  


#	New countries in WCA this year
```sql
SELECT countryId FROM competitions_extra GROUP BY countryId HAVING MIN(YEAR(endDate)) = 2018;
```

|countryId|  
|--|  
|Albania|  
|Armenia|  
|Bulgaria|  
|Kosovo|  
|Liechtenstein|  
|Luxembourg|  
|Macedonia|  
|Mauritius|  
|Pakistan|  
|Tajikistan|  


#	Cities with the most competitions
```sql
SELECT cityName, COUNT(*) FROM competitions_extra WHERE YEAR(endDate) = 2018 GROUP BY cityName ORDER BY COUNT(*) DESC LIMIT 10;
```

|cityName|COUNT(*)|  
|--|--|  
|Beijing|6|  
|Shanghai|5|  
|Wuhan, Hubei|5|  
|Guangzhou, Guangdong|3|  
|Nanchang, Jiangxi|3|  
|Shenzhen, Guangdong|2|  
|Zhongshan, Guangdong|2|  
|Zhuhai, Guangdong|2|  
|Lanzhou, Gansu|2|  
|Suzhou|2|  


#	Countries with the most competitions
```sql
SELECT countryId, COUNT(*) FROM competitions_extra WHERE YEAR(endDate) = 2018 GROUP BY countryId ORDER BY COUNT(*) DESC LIMIT 10;
```

|countryId|COUNT(*)|  
|--|--|  
|China|97|  


#	Most DNFs
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE value = -1 AND YEAR(date) = 2018 GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;
```

|personId|personName|personCountryId|COUNT(*)|  
|--|--|--|--|  
|2007YUNQ01|Yunqi Ouyang (欧阳韵奇)|China|124|  
|2010WANG53|Jiayu Wang (王佳宇)|China|101|  
|2017CHEN36|Xinyun Chen (陈新运)|China|97|  
|2017WANY29|Yifan Wang (王逸帆)|China|97|  
|2008DONG06|Baiqiang Dong (董百强)|China|89|  
|2016FANG01|Shenghai Fang (方胜海)|China|82|  
|2013LINK01|Kaijun Lin (林恺俊)|China|71|  
|2015KANY01|Yikuan Kan (阚亦宽)|China|71|  
|2014HANJ02|Jiachi Han (韩佳池)|China|67|  
|2012LIUY03|Yiwei Liu (刘伊玮)|China|65|  


#	Most 3x3 blindfolded successes
```sql
SELECT personId, personName, personCountryId, COUNT(*) FROM all_attempts WHERE value > 0 AND YEAR(date) = 2018 AND eventId = '333bf' GROUP BY personId ORDER BY COUNT(*) DESC LIMIT 10;
```

|personId|personName|personCountryId|COUNT(*)|  
|--|--|--|--|  
|2013LINK01|Kaijun Lin (林恺俊)|China|67|  
|2016FANG01|Shenghai Fang (方胜海)|China|62|  
|2007YUNQ01|Yunqi Ouyang (欧阳韵奇)|China|61|  
|2015KANY01|Yikuan Kan (阚亦宽)|China|53|  
|2012LIUY03|Yiwei Liu (刘伊玮)|China|49|  
|2015CHEN49|Yucheng Chen (陈裕铖)|China|44|  
|2017WANY29|Yifan Wang (王逸帆)|China|41|  
|2010SHIX01|Xin Shi (石欣)|China|35|  
|2009QIAO03|Zhi Qiao (乔智)|China|32|  
|2014HANJ02|Jiachi Han (韩佳池)|China|27|  


#	Most 3x3 Blindfolded successes in a row
```sql
SET @a = 0, @p = ''; SELECT personId, personName, personCountryId, MAX(streak) FROM (SELECT *, @a := IF(@p = personId AND value > 0, @a + 1, 1) streak, @p := personId FROM (SELECT personId, personName, personCountryId, value, id FROM all_attempts WHERE YEAR(date) = 2018 AND eventId = '333bf' ORDER BY personId, id) a ORDER BY personId, id) b GROUP BY personId ORDER BY MAX(streak) DESC LIMIT 10;
```

|personId|personName|personCountryId|MAX(streak)|  
|--|--|--|--|  
|2015KANY01|Yikuan Kan (阚亦宽)|China|16|  
|2017ZHOU44|Yumeng Zhou (周雨萌)|China|14|  
|2015CHEN49|Yucheng Chen (陈裕铖)|China|14|  
|2012LIYA01|Yang Li (李扬)|China|11|  
|2017SHIM06|Minyang Shi (时旻扬)|China|11|  
|2012LIUY03|Yiwei Liu (刘伊玮)|China|10|  
|2013LINK01|Kaijun Lin (林恺俊)|China|10|  
|2016FANG01|Shenghai Fang (方胜海)|China|9|  
|2013ZHAN41|Lanshi Zhang (张岚石)|China|8|  
|2013TANG07|Feilong Tang (唐飞龙)|China|8|  


#	Most competitions competed in 
```sql
SELECT personId, personName, personCountryId, COUNT(DISTINCT competitionId) FROM results_extra WHERE YEAR(date) = 2018 GROUP BY personId ORDER BY COUNT(DISTINCT competitionId) DESC LIMIT 10;
```

|personId|personName|personCountryId|COUNT(DISTINCT competitionId)|  
|--|--|--|--|  
|2009ZHEN11|Ming Zheng (郑鸣)|China|35|  
|2007YUNQ01|Yunqi Ouyang (欧阳韵奇)|China|34|  
|2010WANG53|Jiayu Wang (王佳宇)|China|33|  
|2013WANG67|Xuming Wang (王旭明)|China|28|  
|2008DONG06|Baiqiang Dong (董百强)|China|26|  
|2016FANG01|Shenghai Fang (方胜海)|China|25|  
|2016FEIJ02|Jun Fei (费俊)|China|24|  
|2014WANG22|Wenjing Wang (王文静)|China|24|  
|2015KANY01|Yikuan Kan (阚亦宽)|China|24|  
|2014CHEN08|Boxi Chen (陈博希)|China|24|  


#	Potentially seen world records
```sql
SELECT pce.personId, pce.personName, pce.personCountryId, SUM(ce.WRs) FROM person_comps_extra pce JOIN competitions_extra ce ON pce.competitionId = ce.id WHERE YEAR(ce.endDate) = 2018 GROUP BY pce.personId ORDER BY SUM(ce.WRs) DESC LIMIT 10;
```

|personId|personName|personCountryId|SUM(ce.WRs)|  
|--|--|--|--|  
|2008DONG06|Baiqiang Dong (董百强)|China|10|  
|2007YUNQ01|Yunqi Ouyang (欧阳韵奇)|China|10|  
|2015CHEN49|Yucheng Chen (陈裕铖)|China|10|  
|2012LIUY03|Yiwei Liu (刘伊玮)|China|9|  
|2013FENG02|Zijia Feng (冯子甲)|China|9|  
|2012PANJ02|Jiekang Pan (潘杰康)|China|8|  
|2011WANG33|Yi Wang (王旖)|China|8|  
|2013ZHON04|Tairan Zhong (钟泰然)|China|7|  
|2014WANG22|Wenjing Wang (王文静)|China|7|  
|2010WUYU02|Yulun Wu (吴宇伦)|China|7|  


#	New Platinum/Gold/Silver members
```sql
SELECT a.id, a.name, a.countryId, b.membership `2017`, a.membership `2018` FROM persons_extra a INNER JOIN persons_extra_2017 b ON a.id = b.id WHERE a.membership <> b.membership ORDER BY FIELD(a.membership,'Platinum','Gold','Silver','Bronze','None'), FIELD(b.membership,'Platinum','Gold','Silver','Bronze','None'), a.id;
```

|id|name|countryId|2017|2018|  
|--|--|--|--|--|  
|2010WANG53|Jiayu Wang (王佳宇)|China|None|Gold|  
|2017LOUY01|Yunhao Lou (娄云皓)|China|None|Gold|  
|2009ZHAN24|Junhe Zhang (张钧鹤)|China|None|Silver|  
|2013TANG07|Feilong Tang (唐飞龙)|China|None|Silver|  
|2015DAIS01|Shifei Dai (代时飞)|China|None|Silver|  
|2015MUZO01|Zongwen Mu (牟宗文)|China|None|Silver|  
|2016DING05|Tianping Ding (丁天平)|China|None|Silver|  
|2016XIZH01|Zhifang Xi (席之枋)|China|None|Silver|  
|2017YUZH03|Yu Zhou (周煜)|China|None|Silver|  
|2017ZHUX01|Xiaoliang Zhu (朱校良)|China|None|Silver|  
|2018FANG10|Weijie Fang (方伟杰)|China|None|Silver|  
|2018LIUL05|Lichao Liu (刘立超)|China|None|Silver|  
|2007YUNQ01|Yunqi Ouyang (欧阳韵奇)|China|Gold|Bronze|  
|2010SHIX01|Xin Shi (石欣)|China|Silver|Bronze|  
|2010WUJI01|Jiawen Wu (吴嘉文)|China|Silver|Bronze|  
|2016FANG01|Shenghai Fang (方胜海)|China|Silver|Bronze|  
|2012SUNL03|Liudi Sun (孙柳笛)|China|None|Bronze|  
|2015KANY01|Yikuan Kan (阚亦宽)|China|None|Bronze|  
|2015XION03|Max Xiong (熊锐明)|China|None|Bronze|  
|2016XUWE02|Wenjie Xu (徐文杰)|China|None|Bronze|  
|2017WANY29|Yifan Wang (王逸帆)|China|None|Bronze|  


#	Smallest competitions
```sql
SELECT name, competitors FROM competitions_extra WHERE YEAR(endDate) = 2018 AND competitors > 0 ORDER BY competitors ASC LIMIT 10;
```

|name|competitors|  
|--|--|  
|Peking University 2018|33|  
|More Than One Cube 2018|39|  
|Please Be Quiet Beijing 2018|45|  
|Maoming Open 2018|55|  
|Jiujiang Open 2018|63|  
|Huizhou Open 2018|72|  
|You May Open 2018|73|  
|Lanzhou Open 2018|73|  
|Xiamen Open 2018|74|  
|Wuhan University Open 2018|76|  


#	PB streaks (only 2018 comps)
```sql
SELECT p.id, p.name, p.countryId, MAX(pbStreak) FROM (SELECT a.*, @val := IF(a.PBs = 0, 0, IF(a.personId = @pid, @val + 1, 1)) pbStreak, @scomp := IF(@val = 0, NULL, IF(@val = 1, competitionId, @scomp)) startComp, @ecomp := IF(@val = 0, NULL, competitionId) endComp, @pid := personId pidhelp FROM (SELECT * FROM competition_PBs WHERE competitionId LIKE '%2018' ORDER BY id ASC) a GROUP BY a.personId, a.competitionId ORDER BY a.id ASC) pbs JOIN persons_extra p ON pbs.personid = p.id GROUP BY p.id ORDER BY MAX(pbStreak) DESC LIMIT 10;
```

|id|name|countryId|MAX(pbStreak)|  
|--|--|--|--|  
|2017CHEN36|Xinyun Chen (陈新运)|China|21|  
|2017WANY29|Yifan Wang (王逸帆)|China|18|  
|2013LIZO01|Zongyang Li (李宗阳)|China|18|  
|2015KANY01|Yikuan Kan (阚亦宽)|China|16|  
|2016ZHUB01|Bodun Zhu (朱博楯)|China|15|  
|2011YUAN05|Lang Yuan (袁朗)|China|15|  
|2017MAZH04|Zhiyuan Ma (马之元)|China|14|  
|2014XUDI01|Diwen Xu (许帝文)|China|14|  
|2016FANG01|Shenghai Fang (方胜海)|China|14|  
|2017LOUY01|Yunhao Lou (娄云皓)|China|14|  


#	Most PBs at a single competition
```sql
SELECT p.id, p.name, p.countryId, pbs.pbs, pbs.competitionId FROM competition_pbs pbs JOIN persons_extra p ON pbs.personId = p.id WHERE competitionId IN (SELECT id FROM competitions_extra WHERE YEAR(endDate) = 2018) ORDER BY PBs DESC LIMIT 10;
```

|id|name|countryId|pbs|competitionId|  
|--|--|--|--|--|  
|2018LIUL05|Lichao Liu (刘立超)|China|31|HangzhouOpen2018|  
|2018FANG10|Weijie Fang (方伟杰)|China|28|GuangdongOpen2018|  
|2017MACH03|Chenhao Ma (马晨皓)|China|28|ChinaChampionship2018|  
|2018LIUJ06|Jiaqi Liu (刘家奇)|China|25|NanjingSpring2018|  
|2016SHIK02|Kanting Shi (史勘霆)|China|25|NanjingSpring2018|  
|2017FENG09|Yu Feng (冯煜)|China|25|ChinaChampionship2018|  
|2013QIAO01|Disheng Qiao (乔涤生)|China|24|NanjingAutumn2018|  
|2016ZHUY04|Yunzhou Zhu (朱云舟)|China|24|TaiyuanWinter2018|  
|2018LIUC07|Chunxi Liu (柳淳曦)|China|24|BeijingOpen2018|  
|2017ZHAX02|Xuechao Zhang (张学超)|China|23|NanjingSpring2018|  


#	Most competitions delegated
```sql
SELECT u.name, COUNT(*) FROM wca_dev.competition_delegates co JOIN wca_dev.users u ON co.delegate_id = u.id WHERE competition_id LIKE '%2018' GROUP BY co.delegate_id ORDER BY COUNT(*) DESC LIMIT 10;
```

|name|COUNT(*)|  
|--|--|  
|Ming Zheng (郑鸣)|30|  
|Baiqiang Dong (董百强)|25|  
|Fangyuan Chang (常方圆)|25|  
|Xiaobo Jin (金晓波)|17|  
|Baocheng Wu (吴宝城)|14|  
|Donglei Li (李冬雷)|10|  
|Chenxi Shan (单晨曦)|8|  
|Danyang Chen (陈丹阳)|4|  
|Zhou Yichen (周奕臣)|2|  


#	Biggest percentage improvement on 3x3 Average
```sql
SELECT p.id, p.name, p.countryId, CENTISECONDTOTIME(a.average) `2017`, CENTISECONDTOTIME(b.result) `2018`, 100*(a.average-b.result)/a.average percentImproved FROM (SELECT personId, MIN(average) average FROM results_extra WHERE average > 0 AND eventId = '333' AND YEAR(date) < 2018 GROUP BY personId) a JOIN (SELECT * FROM ranks_all WHERE eventId = '333' AND succeeded = 1 AND format = 'a') b ON a.personid = b.personId JOIN persons_extra p ON a.personId = p.id ORDER BY percentImproved DESC LIMIT 10;
```

|id|name|countryId|2017|2018|percentImproved|  
|--|--|  
|2016LIUZ07|Ziyi Liu (刘子逸)|China|1:09.07|17.48|74.6923|  
|2015FENG09|Yuan Feng (冯源)|China|59.97|15.71|73.8036|  
|2017ZHUL02|Lianhao Zhu (褚连皓)|China|41.33|12.38|70.0460|  
|2017HANL04|Leixinyu Han (韩雷薪豫)|China|42.98|14.13|67.1242|  
|2017WANC10|Chenjin Wang (王晨锦)|China|1:01.07|20.97|65.6624|  
|2017SHIM06|Minyang Shi (时旻扬)|China|1:17.39|26.79|65.3831|  
|2016LIUZ05|Zixi Liu (刘子熙)|China|1:30.25|31.42|65.1856|  
|2016SUYU02|Yunpeng Su (苏云鹏)|China|45.09|15.81|64.9368|  
|2017HERU01|Runqi He (何润锜)|China|1:06.79|23.46|64.8750|  
|2017LICH04|Chengyang Li (李承洋)|China|59.75|21.59|63.8661|  


