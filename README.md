# vrp_stockmarket (ENG)
Adds a full featured stock trading app to your FiveM server. It fully intergrates with vRP!

There’s also an API so you can add your own stocks to the app.

## Installation
- Download latest release
- Make sure vRP and mysql-async is up and running
- Import vrp_stockmarket.sql into your database
- Add 'ensure vrp_stockmarket' to your configuration file for startup
- Start your server

You can open the window by clicking the STOCK menu in the vRP menu in the game.

## Developer information

To add a stock you can use the following event in your script:

`TriggerEvent("vrp_stockmarket:addStock", "Abbreviation", "Full name", baseWorth)`

Parameter 1 and 2 are strings, the third is an integer what the “base” value is for the stock.
Server owner information

There are config options that are available for your configuration file. These are the following:

```
-- Time in MS to update the stock market prices
set vrp_stockmarket_pricingTimer 30000

-- The lowest possible randomizer
set vrp_stockmarket_minRandom 2

-- The highest possible randomizer
set vrp_stockmarket_maxRandom 20

-- The divider that is used to calculate the new prices
set vrp_stockmarket_divider 10

-- The lowest possible percentage of the base worth that the value of a stock can be
set vrp_stockmarket_lowestBasePercent 70

-- The highest possible percentage of the base worth that the value of a stock can be
set vrp_stockmarket_highestBasePercent 200
```

# vrp_stockmarket (KOR)
vRP와 완벽히 호환되는 주식 스크립트 입니다.

## 적용 방법
- 최종 릴리즈 버전을 다운로드 받으세요.
- vRP와 mysql-async가 정상 작동중인지 확인하세요.
- vrp_stockmarket.sql 을(를) 본인 서버의 데이터베이스에 import 하세요.
- 'ensure vrp_stockmarket' 을(를) server.cfg에 추가하세요.
- 서버를 키세요!

인게임의 핸드폰 메뉴에서 주식 메뉴를 열 수 있습니다.

## 추가 정보

주식을 추가하고 싶다면 아래 코드를 스크립트 서버 코드에 추가하세요!

`TriggerEvent("vrp_stockmarket:addStock", "주식 코드", "주식 풀네임", 주가)`

아래 코드들을 server.cfg에 추가하여 추가 설정을 할 수 있습니다.

```
-- Time in MS to update the stock market prices
set vrp_stockmarket_pricingTimer 30000

-- The lowest possible randomizer
set vrp_stockmarket_minRandom 2

-- The highest possible randomizer
set vrp_stockmarket_maxRandom 20

-- The divider that is used to calculate the new prices
set vrp_stockmarket_divider 10

-- The lowest possible percentage of the base worth that the value of a stock can be
set vrp_stockmarket_lowestBasePercent 70

-- The highest possible percentage of the base worth that the value of a stock can be
set vrp_stockmarket_highestBasePercent 200
```

## SCREENSHOT (스크린샷)

![](https://i.imgur.com/d7furrc.png)