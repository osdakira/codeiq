# coding: utf-8

class Item
  attr_reader :name, :price
  def initialize(id, name, price)
    @id = id
    @name = name
    @price = price
  end
end

class SetMenu
  attr_reader :name, :single_counts, :price
  def initialize(id, name, single_counts, price)
    @id = id
    @name = name
    @single_counts = single_counts
    @price = price
  end

  def is_set_menu?(orders)
    is_set_menu = true
    @single_counts.each do | item, require_num |
      if orders[item] < require_num
        is_set_menu = false
        break
      end
    end
    is_set_menu
  end
end

# データ定義
hamburger = Item.new(1, "ハンバーガー", 250)
potato    = Item.new(2, "ポテト", 200)
drink     = Item.new(3, "ドリンク", 150)
set_menu  = SetMenu.new(4, "ハンバーガーセット", {hamburger =>  1, potato => 1, drink =>  1}, 550)
# END

class Order
  attr_reader :total_price
  def initialize(set_menus, single_menus)
    # @TODO メニューを含有した状態で Order クラスを生成したい。
    @set_menus = set_menus
    @single_menus = single_menus
    @orders = {}
    @orders.default = 0
    @total_price = 0
  end

  def set_item(item, num)
    @orders[item] = num
  end

  def calc()
    @consumer_orders = @orders.dup  # 計算を破壊的に行うので、顧客の記録は取っておく
    calc_set_menu
    calc_single_menu
  end

  def calc_set_menu()
    @set_menus.each do | set_menu |
      while set_menu.is_set_menu?(@orders)
        @total_price += set_menu.price
        decrement_num set_menu
      end
    end
  end

  def calc_single_menu()
    @orders.each{ | item, num | @total_price += item.price * num }
  end

  def decrement_num(set_menu)
    set_menu.single_counts.each{ | item, num | @orders[item] -= num }
  end

  def display()
    @consumer_orders.each do | item, num |
      puts "#{item.name}: #{item.price} x #{num}"
    end
    puts "合計金額 :#{@total_price}"
  end
end

require 'minitest/unit'
if __FILE__ == $0
  order = Order.new([set_menu], [hamburger, potato, drink])
  order.set_item(hamburger, ARGV[0].to_i)
  order.set_item(potato, ARGV[1].to_i)
  order.set_item(drink, ARGV[2].to_i)
  order.calc
  order.display
  MiniTest::Unit.autorun
end


class Test < MiniTest::Unit::TestCase
  def setup
    hamburger = Item.new(1, "ハンバーガー", 250)
    potato    = Item.new(2, "ポテト", 200)
    drink     = Item.new(3, "ドリンク", 150)
    set_menu  = SetMenu.new(4, "ハンバーガーセット", {hamburger => 1, potato =>  1, drink => 1}, 550)

    @hamburger = hamburger
    @potato = potato
    @drink = drink
    @set_menu = set_menu
  end

  def set_helper(hamburger_num, potato_num, drink_num)
    order = Order.new([@set_menu], [@hamburger, @potato, @drink])
    order.set_item(@hamburger, hamburger_num)
    order.set_item(@potato, potato_num)
    order.set_item(@drink, drink_num)
    order.calc
    order
  end

  def test_is_set_menu?()
    assert @set_menu.is_set_menu?({@hamburger =>  1, @potato =>  1, @drink => 1})
  end

  def test_set_menu()
    order = set_helper(1, 1, 1)
    assert order.total_price == 550

    order = set_helper(2, 2, 2)
    assert order.total_price == 1100
  end

  def test_set_and_single()
    order = set_helper(1, 1, 2)
    assert order.total_price == 700

    order = set_helper(1, 1, 0)
    assert order.total_price == 450
  end

end


# どのような点に気をつけてコーディングしたか
# 1. 単品の追加、セットの追加がデータ追加のみで拡張可能
