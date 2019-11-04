class SlotMachine
  # スロットの絵柄
  @slot_list = []
  File.foreach("slot_list.txt"){|line|
    @slot_list << line.chomp
  }
  # スロットの回転結果の配列
  @result = []
  # スロットの合計回転数
  @count = 0
  #確変ランプの配列
  @club = []
  #確変の残り回転数
  @club_count = 50
  
  # スロットの絵柄一覧のゲッター
  def self.slot_list
    @slot_list
  end

  # スロットの絵柄を追加し、テキストファイルに保存
  def self.add_slot(name)
    @slot_list << name
    File.open("slot_list.txt", "a") do |f|
      f.puts("#{name}\n")
    end
    #重複があった場合削除
    @slot_list.uniq!
  end

  # スロットの絵柄を削除
  def self.delete_slot(name)
    @slot_list.delete(name)
    File.open("slot_list.txt", "w") do |f|
      @slot_list.each do |slot|
        f.puts("#{slot}\n")
      end
    end
  end

  # スロットを回す
  def self.roll
    @result = [@slot_list.sample, @slot_list.sample, @slot_list.sample]
    @count += 1
  end
  
  # 当たりかどうか判定
  def self.is_atari?
    if @result[0] == @result[1] && @result[1] == @result[2]
      true
    end
  end

  # 大当たりかどうかを判定
  def self.is_ooatari?
    if @result[0] == "7" && @result[1] == "7" && @result[2] == "7"
      true
    end
  end

  # スロット結果のゲッター
  def self.result
    @result
  end

  # スロット回転数のゲッター
  def self.count
    @count
  end

  def self.count_reset
    @count = 0
  end
  
  #10%の確率でCLUBを１つ点灯
  def self.add_club
    if rand(10) == 0
      @club << "🦀"
    end
  end
  
  # clubのゲッター
  def self.club
    @club
  end
  
  # CLUB５で確変
  def self.is_kakuhen?
    if @club.length == 5 && @club_count > 0
      true
    end
  end
  
  # clubの数を取得
  def self.club_count
    @club_count
  end

  # 確変時のロール
  def self.kakuhen
    # 5回回転する。当たりが出たらブレイク。
    5.times do |slot|
      if @result[0] == @result[1] && @result[1] == @result[2]
        break
      end
      @result = [@slot_list.sample, @slot_list.sample, @slot_list.sample]
    end
    # 確変は50回転まで
    @club_count -= 1
    # 確変の回転数が０になったらCLUBランプを全て削除
    if @club_count == 0
      @club = []
    end
    @count += 1
  end
end