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
end