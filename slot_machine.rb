class SlotMachine
  # スロットの絵柄
  @slot_list = ["7"]
  # スロットの回転結果の配列
  @result = []
  # スロットの合計回転数
  @count = 0

  # スロットを回す
  def self.roll
    @result = [@slot_list.sample, @slot_list.sample, @slot_list.sample]
    @count += 1
  end
  
  def self.is_atari?
    if @result[0] == @result[1] && @result[1] == @result[2]
      true
    end
  end

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