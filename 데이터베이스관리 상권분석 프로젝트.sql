#년도별 자치구 상주인구수 평균
select SUBSTRING(y.기준_년분기_코드, 1, 4) as 기준년도, l.자치구_코드_명, avg(d.상주인구_수) as 상주인구_수_평균
from 연도분기 y, 인구 d, 자치구 l
where y.기준_년분기_코드=d.기준_년분기_코드 and l.자치구_코드=d.자치구_코드 and SUBSTRING(y.기준_년분기_코드, 1, 4)='2023'
group by 1,2
order by 3 desc;

#행정동별 월평균 소득금액 
select SUBSTRING(y.기준_년분기_코드, 1, 4) as 기준년도, 행정동_코드_명, avg(월_평균_소득_금액) 월평균소득
from 분기별자치구세부정보 i, 연도분기 y
where SUBSTRING(y.기준_년분기_코드, 1, 4)='2023'
group by 1,2
order by 3 desc;

#행정동별 월평균 음식 지출금액  
select SUBSTRING(y.기준_년분기_코드, 1, 4) as 기준년도, 행정동_코드_명, avg(음식_지출_총금액) as 평균음식지출 
from 분기별자치구세부정보 i, 연도분기 y
where i.기준_년분기_코드=y.기준_년분기_코드 and SUBSTRING(y.기준_년분기_코드, 1, 4)='2023'
group by 1,2
order by 3 desc;

#행정동별 월평균 총지출금액  
select 기준년도, 행정동_코드_명, 
		sum(평균음식지출 + 평균식료품지출 + 평균의료비지출 + 평균교통비지출) as 지출총금액
from (select SUBSTRING(y.기준_년분기_코드, 1, 4) as 기준년도, 
			행정동_코드_명, avg(음식_지출_총금액) as 평균음식지출 , 
			avg(식료품_지출_금액) as 평균식료품지출, 
            avg(의료비_지출_금액) as 평균의료비지출, 
            avg(교통_지출_금액) as 평균교통비지출
	from 분기별자치구세부정보 i, 연도분기 y
	where i.기준_년분기_코드=y.기준_년분기_코드 
			and SUBSTRING(y.기준_년분기_코드, 1, 4)=2023
group by 1,2
order by 1 desc,3 desc) as avg_spend
group by 1,2
order by 1, 3 desc;

#업종 별 점포수 평균개업율 평균폐업률
select SUBSTRING(y.기준_년분기_코드, 1, 4) as 기준년도, b.업종_코드_명, avg(j.점포_수) as 점포수평균, avg(j.개업_점포_수)/avg(j.점포_수)*100 as 평균개업율, avg(j.폐업_점포_수)/avg(j.점포_수)*100 as 평균폐업률
from 업종 b, 점포및매출 j, 연도분기 y
where b.업종_코드=j.업종_코드 and y.기준_년분기_코드=j.기준_년분기_코드
group by 1,2
order by 1 desc, 3 desc;

#자치구별 점포 데이터
select l.자치구_코드_명, avg(j.점포_수) as 점포수평균, avg(j.개업_점포_수)/avg(j.점포_수)*100 as 평균개업율, avg(j.폐업_점포_수)/avg(j.점포_수)*100 as 평균폐업률
from 업종 b, 점포및매출 j, 자치구 l
where b.업종_코드=j.업종_코드 and l.자치구_코드=j.자치구_코드
group by 1
order by 2 desc;

#자치구별 점포 데이터 추이
select y.기준_년분기_코드, l.자치구_코드_명, avg(j.점포_수) as 점포수평균, avg(j.개업_점포_수)/avg(j.점포_수)*100 as 평균개업율, avg(j.폐업_점포_수)/avg(j.점포_수)*100 as 평균폐업률
from 업종 b, 점포및매출 j, 자치구 l, 연도분기 y
where b.업종_코드=j.업종_코드 and l.자치구_코드=j.자치구_코드 and y.기준_년분기_코드=j.기준_년분기_코드
group by 1,2
order by 1,3 desc;

#총지출과 점포간 관계
SELECT 
    subquery.자치구_코드_명,
    subquery.평균폐업률,
    RANK() OVER (ORDER BY 평균폐업률 DESC) AS 폐업률_순위,
    subquery.평균총지출,
    RANK() OVER (ORDER BY 평균총지출 DESC) AS 총지출_순위
FROM (
    SELECT 
        avg_spend.자치구_코드_명, 
        sum(avg_spend.점포수평균) as 점포수평균,
        sum(avg_spend.평균개업율) as 평균개업율,
        sum(avg_spend.평균폐업률) as 평균폐업률,
        SUM(avg_spend.평균총지출) AS 평균총지출
    FROM (
        SELECT  
            SUBSTRING(y.기준_년분기_코드, 1, 4) as 기준년도, 
            l.자치구_코드_명, 
            AVG(j.점포_수) AS 점포수평균,
            AVG(j.개업_점포_수) / AVG(j.점포_수) * 100 AS 평균개업율,
            AVG(j.폐업_점포_수) / AVG(j.점포_수) * 100 AS 평균폐업률,
            AVG(음식_지출_총금액 + 식료품_지출_금액 + 의료비_지출_금액 + 교통_지출_금액) as 평균총지출
        FROM 
            분기별자치구세부정보 i
            INNER JOIN 연도분기 y ON i.기준_년분기_코드 = y.기준_년분기_코드
            INNER JOIN 점포및매출 j ON i.자치구_코드 = j.자치구_코드
            INNER JOIN 자치구 l ON l.자치구_코드 = i.자치구_코드
        WHERE 
            SUBSTRING(y.기준_년분기_코드, 1, 4) = '2023'
        GROUP BY 
            1,2
    ) as avg_spend
    GROUP BY 
        1
) AS subquery;

#자치구별로 점포수/평균개업율/평균폐업률이 5위 이하인 업종만 출력
SELECT *
FROM (
    SELECT 
        subquery.자치구_코드_명,
        subquery.업종_코드_명,
        subquery.평균폐업률,
        subquery.폐업률_순위
    FROM (
        SELECT 
            *,
            RANK() OVER (PARTITION BY 자치구_코드_명 ORDER BY 평균폐업률 DESC) AS 폐업률_순위
        FROM (
            SELECT 
                SUBSTRING(y.기준_년분기_코드, 1, 4) AS 기준년도, 
                l.자치구_코드_명, 
                s.업종_코드_명,
                AVG(j.폐업_점포_수) / AVG(j.점포_수) * 100 AS 평균폐업률
            FROM 
                분기별자치구세부정보 i
                INNER JOIN 연도분기 y ON i.기준_년분기_코드 = y.기준_년분기_코드
                INNER JOIN 점포및매출 j ON i.자치구_코드 = j.자치구_코드
                INNER JOIN 자치구 l ON l.자치구_코드 = i.자치구_코드
                INNER JOIN 업종 s ON j.업종_코드 = s.업종_코드
            WHERE 
                SUBSTRING(y.기준_년분기_코드, 1, 4) = '2023'
            GROUP BY 
                1, 2, 3
        ) AS subquery
    ) AS subquery
    WHERE 폐업률_순위 <= 5
) AS subquery2;


#마포구 업종 별 점포수 평균개업율 평균폐업률 추이 
select 	y.기준_년분기, 
		l.자치구_코드_명, 
        b.업종_코드_명, 
        avg(j.점포_수) as 점포수평균, 
        avg(j.개업_점포_수)/avg(j.점포_수)*100 as 평균개업율, 
        avg(j.폐업_점포_수)/avg(j.점포_수)*100 as 평균폐업률
from 업종 b, 점포및매출 j, 연도분기 y, 자치구 l
where 	b.업종_코드=j.업종_코드 
		and l.자치구_코드=j.자치구_코드 
        and l.자치구_코드_명='마포구' 
        and  y.기준_년분기_코드=j.기준_년분기_코드
		and (b.업종_코드_명='호프-간이주점' or b.업종_코드_명='치킨전문점' or b.업종_코드_명='한식음식점' or b.업종_코드_명='커피-음료')
group by 1,2,3
order by 1, 4;

#마포구 특정 업종의 점포수 평균개업율 평균폐업률 추이 
select 	y.기준_년분기_코드 as 연도분기, 
		b.업종_코드_명, 
        l.자치구_코드_명, 
        avg(j.점포_수) as 점포수평균, 
        avg(j.개업_점포_수)/avg(j.점포_수)*100 as 평균개업율, 
        avg(j.폐업_점포_수)/avg(j.점포_수)*100 as 평균폐업률
from 업종 b, 점포및매출 j, 자치구 l, 연도분기 y
where 	b.업종_코드=j.업종_코드 
		and l.자치구_코드=j.자치구_코드 
        and y.기준_년분기_코드=j.기준_년분기_코드 
        and l.자치구_코드_명='마포구' 
        and b.업종_코드_명='커피-음료'
group by 1,2,3
order by 1 desc, 4 desc;