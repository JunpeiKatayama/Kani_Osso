require 'discordrb'
bot = Discordrb::Commands::CommandBot.new token: ENV['DBOT_KANI_OSSO_TOKEN'],
                                      client_id: ENV['DBOT_KANI_OSSO_ID'], prefix: '/'
late_time_default = 21
kani_list = ["かにおっそ", "蟹おっそ"]
bot.message(containing: kani_list) do |event|
  event.respond "こんにちは!#{event.user.name}さん。遅れて申し訳ございません。\nかにさんは琉球時間で生活しているため、もう少々お待ちください。\n悪気はありません。
                \n遅刻時間の入力は「/late 3」のように入力できます。"
end

bot.message(containing: "炊飯器") do |event|
  event.respond "@Kani#0599 炊飯器の保温時間を切りなさい。"
end

bot.command :late do |event,time|
  late_time = late_time_default + time.to_i
  late_time_default = late_time
  event.respond "かにさんは合計#{late_time}分遅刻しています"
end

bot.command :kl_help do |event|
  event.respond "コマンド一覧\n/late...遅刻時間を入力（負の値を指定すると遅刻時間を差し引くことができます）"
end

bot.run