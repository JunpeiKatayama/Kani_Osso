require 'discordrb'
require "time"
bot = Discordrb::Commands::CommandBot.new token: ENV['DBOT_KANI_OSSO_TOKEN'],client_id: ENV['DBOT_KANI_OSSO_ID'], prefix: '/'

# helpコマンド
bot.command :ko_help do |event|
  event.respond "コマンド一覧
  /late 時間...遅刻時間を入力（負の値も設定可）
  /promise 24:59 ...部活開始時間を入力
  /arrive ...部活に参加した時間を宣言
  /party   ...現在のパーティの状態を確認します
  /join    ...パーティに参加する
  /remove  ...パーティを脱退します
  /neru    ...パーティを解散します
  -----------------------
  かに(蟹)おっそ ...botが代りに謝罪します
  炊飯器        ...炊飯器運用の正常化を促します"
end

# 遅刻時間を読み込み
late_time_default = 0
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
promised_time = nil
bot.command :promise do |event,time|
  promised_time = Time.parse(time)
  event.respond "部活は#{promised_time.strftime("%H時%M分")}に開始予定です"
end

# 部活に到着する
bot.command :arrive do |event|
  time = Time.now
  diff = promised_time - time
  # 表示用変数
  diff_min = (diff.to_f / 60).to_i
  if diff.to_f > 0
    event.respond "#{event.user.name}が到着！#{diff_min}分前だ！"
  elsif diff.to_f < 0
    event.respond "#{event.user.name}が到着！#{diff_min.abs}分遅刻だ！"
    # ユーザがかにさんの場合のみ遅刻合計時間を保存・出力する
    if event.user.name == "Kani"
      late_time_default += diff_min
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
  suihanki_list = ["炊飯器の保温を切りなさい!!!!","炊飯器にバナナ入れるな!!!!"]
  event.respond "<@!394789332881244160>かに!!!!!#{suihanki_list.sample}"
end

# パーティメンバーを追加
members = []
bot.command :join do |event,name|
  members << event.user.name
  event.respond "現在#{members.length}名がパーティでプレイ中です
メンバーは以下の通りです
#{members}"
end

# パーティメンバーを削除
bot.command :remove do |event,name|
  members.delete(event.user.name)
  event.respond "#{event.user.name}がパーティから脱退しました。
現在#{members.length}名がパーティでプレイ中です"
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

bot.run