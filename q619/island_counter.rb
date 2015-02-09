# -*- coding: utf-8 -*-
require "csv"

# IslandCounter.calc_island_groups("AegeanSea/AegeanSea1.csv").size == 3
# 詳細はテストを

class IslandCounter
  def calc_island_groups(file_path)
    arr_of_arrs = read_csv(file_path)
    map = Map.new(arr_of_arrs)
    map.search_island_groups
  end

  # csv 取り出して 数値化
  def read_csv(path)
    arr_of_arrs = CSV.read(path)
    arr_of_arrs.map{|arr| arr.map(&:to_i)}
  end
end

class Map
  # マップ探索
  def initialize(arr_of_arrs)
    @map = arr_of_arrs.map.with_index do |arr, row|
      arr.map.with_index{|spot, col| Spot.new(spot, row, col) }
    end
  end

  # マップを探索
  def search_island_groups
    @island_groups = []
    @map.each.with_index do |arr, row|
      arr.each.with_index do |spot, col|
        if spot.island?
          if spot.searched?
            next
          else
            # まだ出会っていない島グループの始まりの島
            # TODO island_group に副作用を必要とするのが良くない
            island_group = []
            @island_groups << collect_same_group(island_group, row, col)
          end
        end
      end
    end
    @island_groups
  end

  # ヒットした島の前後左右を検索。再帰
  def collect_same_group(island_group, row, col)
    return island_group if @map[row][col].sea?
    store_searched_island!(island_group, @map[row][col]) if !@map[row][col].searched?
    collect_same_group(island_group, row - 1, col) if row - 1 >= 0 && !@map[row - 1][col].searched?
    collect_same_group(island_group, row + 1, col) if @map[row + 1] && !@map[row + 1][col].searched?
    collect_same_group(island_group, row, col - 1) if col - 1 >= 0 && !@map[row][col - 1].searched?
    collect_same_group(island_group, row, col + 1) if @map[row][col + 1] && !@map[row][col + 1].searched?
    island_group
  end

  # 検索済みフラグ。島グループに追加
  def store_searched_island!(island_group, spot)
    spot.searched!
    island_group << spot
  end
end



class Spot
  def initialize(spot, row, col)
    @spot = spot.nonzero?
    @row = row
    @col = col
  end

  def island?
    @spot
  end

  def sea?
    !island?
  end

  def searched?
    @searched
  end

  def searched!
    @searched = true
  end

  def position
    [@row, @col]
  end
end

require 'minitest'
if __FILE__ == $0
  require 'minitest/autorun'
end

class IslandCounterTest < MiniTest::Test
  def test_read_csv
    arr_of_arrs = IslandCounter.new.read_csv("AegeanSea/AegeanSea1.csv")
    assert_equal 0, arr_of_arrs[0][0]
    assert_equal 1, arr_of_arrs[1][1]
  end

  def test_calc_island_groups
    assert_equal 3, IslandCounter.new.calc_island_groups("AegeanSea/AegeanSea1.csv").size
    assert_equal 28, IslandCounter.new.calc_island_groups("AegeanSea/AegeanSea2.csv").size
    assert_equal 69, IslandCounter.new.calc_island_groups("AegeanSea/AegeanSea3.csv").size
  end
end

class MapTest < MiniTest::Test
  def test_search_island
    map = [
      [0, 1, 0, 0],
      [0, 1, 1, 0],
      [1, 0, 1, 0],
      [1, 0, 0, 1],
    ]
    map = Map.new(map)
    island_groups = map.search_island_groups
    assert_equal 3, island_groups.size
    assert_equal [[0, 1], [1, 1], [1, 2], [2, 2]], island_groups[0].map(&:position)
    assert_equal [[2, 0], [3, 0]], island_groups[1].map(&:position)
    assert_equal [[3, 3]], island_groups[2].map(&:position)
  end
end
