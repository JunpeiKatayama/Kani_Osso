require 'byebug'
require 'discordrb'
require 'time'
require 'json'
require 'uri'
require 'net/http'

require './slot_machine'

bot = Discordrb::Commands::CommandBot.new token: ENV['DBOT_KANI_OSSO_TOKEN'],client_id: ENV['DBOT_KANI_OSSO_ID'], prefix: '/'

# 遅刻時間の変数
late_time_default = 0
# パーティメンバーの配列
members = []
# 部活開始時間の変数
promised_time = nil

#~をプレイ中
bot.ready do |event|
  bot.game = "天安門事件"
  sleep 5

  # 現在のパーティメンバー数
  if members.any?
    bot.game = "#{members.length}人パーティ"
    sleep 5
  else
    bot.game = "パーティはありません"
    sleep 5
  end
  
  # 部活予定時間
  if promised_time != nil
    bot.game = "#{promised_time.strftime("%H時%M分")}開始予定"
    sleep 5
  end

  # かにさんの累計遅刻時間
  bot.game = "累計遅刻時間：#{late_time_default}分"
  sleep 5
  redo
end

# helpコマンド
bot.command :ko_help do |event|
  event.respond "コマンド一覧
  /late 時間 ...遅刻時間を入力（負の値も設定可）
  /promise 24:59 ...部活開始時間を入力
  /arrive ...部活に参加した時間を宣言
  /party   ...現在のパーティの状態を確認
  /join    ...パーティに参加
  /join 名前 ...指定した人をパーティに参加
  /remove  ...パーティを脱退
  /remove 名前 ...指定した人をパーティから脱退
  /neru    ...パーティを解散
  /sin ...かにさんの罪深さを表示
  /slot ...かにスロットをプレイ
  /slot_help ...スロットの説明を表示
  /add_slot 名前 ...スロットの絵柄を追加
  /delete_slot 名前 ...該当の絵柄を削除
  -----------------------
  かに(蟹)おっそ ...botが代りに謝罪
  炊飯器        ...炊飯器運用の正常化を促す"
end

# 遅刻時間を読み込み
File.open("late_time_default.txt", "r") do |f|
  late_time_default = f.read.to_i
end

# 遅刻時間を加算
bot.command :late do |event,time|
  late_time = late_time_default + time.to_i
  late_time_default = late_time
  event.respond "かにさんは合計#{late_time}分遅刻しています"
  File.open("late_time_default.txt", "w+") do |f|
    f.puts(late_time_default)
  end
end

# 部活の開始時間を約束
bot.command :promise do |event,time|
  promised_time = Time.parse(time)
  event.respond "部活は#{promised_time.strftime("%H時%M分")}に開始予定です"
end

# 部活に到着する
bot.command :arrive do |event|
  diff = promised_time - Time.now
  # 表示用変数
  diff_min = (diff / 60).to_f
  if diff.to_f > 0
    event.respond "#{event.user.name}が到着！#{diff_min.to_i}分前だ！"
  elsif diff.to_f < 0
    event.respond "#{event.user.name}が到着！#{diff_min.to_i.abs}分遅刻だ！"
    # ユーザがかにさんの場合のみ遅刻合計時間を保存・出力する
    if event.user.name == "Kani"
      late_time_default += diff_min.to_i.abs
      event.respond "かにさんは合計#{late_time_default}分遅刻しています"
      File.open("late_time_default.txt", "w+") do |f|
        f.puts(late_time_default)
      end
    end
  elsif diff.to_f == 0
    event.respond "#{event.user.name}が到着！時間ぴったり！アメイジング！"
  else
    event.respond "例外を発生させるのは、ユーザーの知識不足である。"
  end
end

# かにさんの代りに謝罪
kani_list = ["かにおっそ", "蟹おっそ"]
bot.message(containing: kani_list) do |event|
  # respondメソッドは空白・インデント・改行込みで出力するため注意
  event.respond "こんにちは!#{event.user.name}さん。遅れて申し訳ございません。
かにさんは琉球時間で生活しているため、もう少々お待ちください。
悪気はありません。
遅刻時間の入力は「/late 3」のように入力できます。"
end

# 炊飯器の運用を正常化
bot.message(containing: "炊飯器") do |event|
  suihanki_list = ["炊飯器の保温を切りなさい!!!!", "炊飯器にバナナ入れるな!!!!", "水道代忘れるな!!!!","かに!!!!かに!!!!かに!!!!",
                   "香港に謝罪しろ!!!!", "すき・・・♡", "お父さんとLoLさせろ", "弟DJ!!!!!!!!"]
  event.respond "<@!394789332881244160>かに!!!!!#{suihanki_list.sample}"
end

# パーティメンバーを追加
bot.command :join do |event,name|
  # 名前を渡された場合その人をパーティに追加
  if name
    members << name
    event.respond "現在#{members.length}名がパーティでプレイ中です
メンバーは以下の通りです
#{members}"
  # 名前情報がない場合は発言者をパーティに追加
  else
    members << event.user.name
    event.respond "現在#{members.length}名がパーティでプレイ中です
メンバーは以下の通りです
#{members}"
  end
end

# パーティメンバーを削除
bot.command :remove do |event,name|
  if name
    members.delete(name)
    event.respond "#{name}がパーティから脱退しました。
現在#{members.length}名がパーティでプレイ中です"
  else
  members.delete(event.user.name)
  event.respond "#{event.user.name}がパーティから脱退しました。
現在#{members.length}名がパーティでプレイ中です"
  end
end

# パーティの状態を確認
bot.command :party do |event|
  if members.any?
    event.respond "現在#{members.length}名がパーティでプレイ中です
メンバーは以下の通りです
#{members}"
  else
    event.respond "現在プレイ中のパーティはありません"
  end
end

# パーティを削除
bot.command :neru do |event|
  members = []
  event.respond "パーティは解散しました。"
end

# かにさんの罪を数値化
# 口座も持ってないのにやばいかもしれないのでコマンド時のみJSON取得
bot.command :sin do |event|
uri = URI.parse('https://www.gaitameonline.com/rateaj/getrate')
json = Net::HTTP.get(uri)
result = JSON.parse(json)
# JSONのUSD/JPY部を取得
doll_yen = result["quotes"][20]["ask"]
# 罪を㌦に変換
sin_dollar = (late_time_default / doll_yen.to_f).round(2)

event.respond "かにさんの罪
総遅刻時間：#{late_time_default}分
日本円で支払う：#{late_time_default}円
米国ドルで支払う：#{sin_dollar}ドル(#{Time.now.strftime("%m月%d日")}現在)"
end

# 俺の面接予定
mensetu_yotei = {}
bot.command :mensetu do |event,day,place|
  mensetu_yotei.store(day,place)
  event.respond "直近の面接予定"
  mensetu_yotei.each do |key,value|
    event.respond "#{key}：#{value}"
  end
end

# 就活stats
matchs = 6
wins = 0
bot.command :syuukatu_stats do |event,match,win|
  event.respond "僕の就活は#{matchs + match.to_i}戦・#{wins + win.to_i}勝です"
end

# かにスロット
# eventが１つもない場合例外になるようなのでスロット表示部分はメソッドに切り分けずそのまま残してあります
bot.command :slot do |event|
  if SlotMachine.is_kakuhen?
    SlotMachine.kakuhen
    event.respond "| #{SlotMachine.result[0]} | #{SlotMachine.result[1]} | #{SlotMachine.result[2]} |
#{SlotMachine.club} #{SlotMachine.club_count}"
    if SlotMachine.is_ooatari?
      event.respond "大当たりだ〜〜〜〜〜!!!!
<@!394789332881244160>かに!!!!!#{event.user.name}に500円払え!!!!!
回転数：#{SlotMachine.count}"
      SlotMachine.count_reset
      SlotMachine.reset_result
    elsif SlotMachine.is_atari?
      event.respond "当たりだ〜〜〜〜〜!!!!
#{event.user.name}ナイスぅ~~!!!!!
回転数：#{SlotMachine.count}"
      SlotMachine.count_reset
      SlotMachine.reset_result
    end
  else
    SlotMachine.roll
    SlotMachine.add_club
    event.respond "| #{SlotMachine.result[0]} | #{SlotMachine.result[1]} | #{SlotMachine.result[2]} |
#{SlotMachine.club}"
    if SlotMachine.is_ooatari?
      event.respond "大当たりだ〜〜〜〜〜!!!!
<@!394789332881244160>かに!!!!!#{event.user.name}に500円払え!!!!!
回転数：#{SlotMachine.count}"
      SlotMachine.count_reset
      SlotMachine.reset_result
    elsif SlotMachine.is_atari?
      event.respond "当たりだ〜〜〜〜〜!!!!
#{event.user.name}ナイスぅ~~!!!!!
回転数：#{SlotMachine.count}"
      SlotMachine.count_reset
      SlotMachine.reset_result
    end
  end
end

# スロットに絵柄を追加
bot.command :add_slot do |event,name|
  SlotMachine.add_slot(name)
  event.respond "現在の役"
  event.respond "#{SlotMachine.slot_list}"
end

# スロットの絵柄を削除
bot.command :delete_slot do |event,name|
  if SlotMachine.slot_list.include?(name)
    SlotMachine.delete_slot(name)
    event.respond "現在の役"
    event.respond "#{SlotMachine.slot_list}"
  else
    event.respond "なんか間違ってない？"
    event.respond "現在の役"
    event.respond "#{SlotMachine.slot_list}"
  end
end

bot.command :slot_help do |event|
  event.respond "スロットの説明
  絵柄が３つ揃うと当たり！
  ７７７で蟹さんから500円もらえるぞ！
  🦀が５つ揃うと確変！当選確率5倍だ！！！
  確変は50回転続くぞ〜〜〜〜！！！！！"
end

bot.command :wifi_fix do |event|
  event.respond "Wifiを直しました"
end

bot.command :fight_kinpei do |event|
  event.respond "ありがとう！結構大変だけど内政頑張る〜！"
end

bot.command :kinpei_marry_me do |event|
  event.respond "良いよ・・・💖"
end

sisiza_count = 0
constellation = ["牡羊座","牡牛座","双子座","蟹座","獅子座","乙女座","天秤座","蠍座","射手座","山羊座","水瓶座","魚座"]
bot.message(containing: "星占い") do |event|
  saikou = constellation.sample
  event.respond "今日の運勢
#{saikou}：最高
その他：ゴミ"
  if saikou == "獅子座"
    sisiza_count += 1
   event.respond "また獅子座に忖度してしまいました
獅子座の当選回数： #{sisiza_count}"
  end
end

bot.message(containing: "料金") do |event|
  event.respond "蟹エンジニア塾の料金システム
基本料金　　　500/h
冬季限定割引 -200/h
悪魔        *0
-------------------------------
合計         0円(+教材費)"
end

bot.run