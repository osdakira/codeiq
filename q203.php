<?php

// @入力: 各商品の個数
// @出力: 合計額を出力する
// 顧客はセットメニューを頼むのではなく、単品が条件を満たすと自動的にセットになる店なのか？

class Item{
    // 商品単品
    public $id = 0;
    public $price = 0;
    public function __construct($id, $price){
        $this->id = $id;
        $this->price = $price;
    }
}

class SetMenu{
    // 単品の種類と個数を合わせて、セット価格
    public $id = 0;
    public $items = null;
    public $price = null;
    public function __construct($id, $items, $price){
        $this->id = $id;
        $this->items = $items;
        $this->price = $price;
    }

    public function is_set_enough($items){
        $is_enough = true;
        foreach($this->items as $id => $require_num){
            if( ! array_key_exists($id, $items) || $items[$id] < $require_num){
                $is_enough = false;
                break;
            }
        }
        return $is_enough;
    }
}

class Menu{
    // セットの集合体としてのメニュー
    public $set_menus = [];
    public function __construct($set_menus, $singles){
        $this->set_menus = $set_menus;
        $this->singles = $singles;
    }
}

// BEGIN == 実際は DB に入るデータ
$hamburger = new Item(1, 250);
$potato = new Item(2, 200);
$drink = new Item(3, 150);
$singles = [$hamburger->id => $hamburger,
            $potato->id =>$potato,
            $drink->id => $drink];
$set_menu1 = new SetMenu(4, [$hamburger->id => 1, $potato->id => 1, $drink->id => 1], 550);
$today_menu = new Menu([$set_menu1], $singles);
// END

class Order{
    // 客の注文
    public $total_price = 0;
    public $menu = null;
    public function __construct($menu){
        $this->menu = $menu;
    }

    public function calc($items){
        $no_set_items = $this->calc_set_menus($items);
        $this->calc_single_menus($no_set_items);
        return $this->total_price;
    }

    public function calc_set_menus($items){
        foreach($this->menu->set_menus as $key => $set_menu){
            while($set_menu->is_set_enough($items)){
                $items = $this->decrement_items($set_menu->items, $items);
                $this->total_price += $set_menu->price;
            }
        }
        return $items;
    }

    public function calc_single_menus($items){
        foreach($items as $id => $num){
            $this->total_price += $this->menu->singles[$id]->price * $num;
        }
    }

    function decrement_items($set_items, $items){
        // items を破壊的に減らしていく。
        foreach($set_items as $key => $val){
            $items[$key] -= $val;
            if($items[$key] == 0){
                unset($items[$key]);
            }
        }
        return $items;
    }
}

// 計算呼び出し部分
function calc($hamburger_num, $potato_num, $drink_num)
{
    global $today_menu, $hamburger, $potato, $drink;
    $order = new Order($today_menu);
    return $order->calc([$hamburger->id => $hamburger_num,
                         $potato->id =>$potato_num,
                         $drink->id => $drink_num]);
}
$hamburger_num = 1;
$potato_num = 1;
$drink_num = 1;
printf("合計は %d になります。\n", calc($hamburger_num, $potato_num, $drink_num));

// test
class Test{
    function setUp(){
        global $hamburger, $potato, $drink;
        $this->h_id = $hamburger->id;
        $this->p_id = $potato->id;
        $this->d_id = $drink->id;
        $this->set_menu1 = new SetMenu(4, [$this->h_id => 1, $this->p_id => 1, $this->d_id => 1], 550);
    }

    public function test_set_enough(){
        $set_menu1 = $this->set_menu1;
        assert($set_menu1->is_set_enough([$this->h_id => 1, $this->p_id => 1, $this->d_id => 1]));
        assert($set_menu1->is_set_enough([$this->h_id => 2, $this->p_id => 2, $this->d_id => 2]));
        assert(! $set_menu1->is_set_enough([$this->h_id => 1, $this->p_id => 1, $this->d_id => 0]));
        assert(! $set_menu1->is_set_enough([$this->h_id => 2, $this->p_id => 1, $this->d_id => 0]));
        assert(! $set_menu1->is_set_enough([$this->h_id => 2, $this->d_id => 0]));
    }

    public function test_set_menu1(){
        global $today_menu, $hamburger, $potato, $drink;
        $order = new Order($today_menu);
        assert(550 == $order->calc([$hamburger->id => 1,
                                    $potato->id => 1,
                                    $drink->id => 1]));

        $order = new Order($today_menu);
        assert(1100 == $order->calc([$hamburger->id => 2,
                                    $potato->id => 2,
                                    $drink->id => 2]));
    }

    public function test_menu(){
        global $today_menu, $hamburger, $potato, $drink;
        $order = new Order($today_menu);
        assert(700 == $order->calc([$hamburger->id => 1,
                                    $potato->id => 1,
                                    $drink->id => 2]));

        $order = new Order($today_menu);
        assert(550 == $order->calc([$hamburger->id => 1,
                                    $drink->id => 2]));

        $order = new Order($today_menu);
        assert(0 == $order->calc([]));
    }

    public function test_new_set_menu(){
        global $today_menu, $hamburger, $potato, $drink, $singles, $set_menu1;
        $set_menu2 = new SetMenu(5, [$hamburger->id => 4, $potato->id => 4, $drink->id => 4], 2000);
        $today_menu = new Menu([$set_menu2, $set_menu1], $singles);
        $order = new Order($today_menu);
        assert(2000 == $order->calc([$hamburger->id => 4,
                                    $potato->id => 4,
                                    $drink->id => 4]));

        $order = new Order($today_menu);
        assert(1100 == $order->calc([$hamburger->id => 2,
                                    $potato->id => 2,
                                    $drink->id => 2]));
    }

}

$t = new Test();
$t->setUp();
$t->test_set_enough();
$t->test_set_menu1();
$t->test_menu();
$t->test_new_set_menu();


?>



## どのような点に気をつけてコーディングしたか

* 拡張
1. 商品の追加がデータの修正のみで可能
2. セットの追加がデータの修正のみで可能
3. セットの入替がデータの修正のみで可能

* コーディング
4. メソッドは10行まで（testを除く）
5. ネストは3つまで
