require 'discordrb'
require 'time'
require 'json'
require 'uri'
require 'net/http'

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
  /late 時間...遅刻時間を入力する（負の値も設定可）
  /promise 24:59 ...部活開始時間を入力する
  /arrive ...部活に参加した時間を宣言する
  /party   ...現在のパーティの状態を確認する
  /join    ...パーティに参加する
  /join 名前 ...指定した人をパーティに参加させる
  /remove  ...パーティを脱退する
  /remove 名前 ...指定した人をパーティから脱退させる
  /neru    ...パーティを解散する
  /sin ...かにさんの罪深さを表示
  -----------------------
  かに(蟹)おっそ ...botが代りに謝罪する
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
  suihanki_list = ["炊飯器の保温を切りなさい!!!!", "炊飯器にバナナ入れるな!!!!", "水道代忘れるな!!!!","かに!!!!かに!!!!かに!!!!", "香港に謝罪しろ!!!!", "すき・・・♡"]
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

bot.run